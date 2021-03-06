/****** Object:  StoredProcedure [dbo].[Drives_Insert]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Drives_Insert]
@pUserSKey UNIQUEIDENTIFIER,
@pStartDTM	DATETIMEOFFSET,
@pEndDTM	DATETIMEOFFSET,
@pTopic		NVARCHAR(1000),
@pParent	INT
AS
IF @pEndDTM > @pStartDTM
BEGIN
	INSERT DBO.DRIVES VALUES (@pUserSKey, @pStartDTM, @pEndDTM, @pTopic, @pParent)
	RETURN 0
END
ELSE
BEGIN
	RETURN 1
END



GO
ALTER AUTHORIZATION ON [dbo].[Drives_Insert] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Drives_Select]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Drives_Select]
@pUserSKey UNIQUEIDENTIFIER
AS
;WITH CTE_BASETIME AS (
SELECT A.STARTDTM, A.ENDDTM, DATEDIFF(MINUTE, A.STARTDTM, A.ENDDTM)/60 'HOURS',   
CASE 
	WHEN (DATEDIFF(MINUTE, A.STARTDTM, A.ENDDTM)/60) > 0 THEN ABS(DATEDIFF(HOUR, A.STARTDTM, A.ENDDTM)*60 - (DATEDIFF(MINUTE, A.STARTDTM, A.ENDDTM)))
	ELSE DATEDIFF(MINUTE, A.STARTDTM, A.ENDDTM)
END
'MINUTES', A.TOPIC, B.PARENT
FROM DBO.DRIVES A JOIN DBO.PARENTS B ON A.USERSKEY = B.USERSKEY 
AND A.PARENT = B.PARENTSKEY
WHERE A.USERSKEY = @pUserSKey
)
SELECT STARTDTM, ENDDTM, CONVERT(NVARCHAR, HOURS) + ':' + RIGHT('00'+CAST(MINUTES AS VARCHAR(2)),2) AS 'TIME', TOPIC, PARENT
FROM CTE_BASETIME
ORDER BY STARTDTM

GO
ALTER AUTHORIZATION ON [dbo].[Drives_Select] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Parents_Delete]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Parents_Delete]
@pUserSKey		UNIQUEIDENTIFIER,
@pParentSKey	INT

AS
DELETE dbo.Parents  
WHERE UserSKey = @pUserSKey
AND ParentSKey = @pParentSKey
GO
ALTER AUTHORIZATION ON [dbo].[Parents_Delete] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Parents_Insert]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Parents_Insert]
@pUserSKey uniqueidentifier,
@pParentName nvarchar(50)
AS
IF @pUserSKey = null
BEGIN
	RETURN 1
END

IF @pParentName = null
BEGIN
	RETURN 2
END

DECLARE @pCount INT,
		@pNewParentIndex INT

SET @pCount = (SELECT COUNT(PARENT) FROM DBO.PARENTS WHERE UserSKey = @pUserSKey)  
IF @pCount < 3
BEGIN
	SET @pNewParentIndex = @pCount + 1
	INSERT dbo.parents VALUES (@pUserSKey,@pNewParentIndex, @pParentName)
END
ELSE
BEGIN
	RETURN 3
END
RETURN 0


GO
ALTER AUTHORIZATION ON [dbo].[Parents_Insert] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Parents_Select]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Parents_Select]
@pUserSKey		UNIQUEIDENTIFIER

AS
SELECT Parent
FROM dbo.Parents  
WHERE UserSKey = @pUserSKey
ORDER BY ParentSKey
GO
ALTER AUTHORIZATION ON [dbo].[Parents_Select] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Parents_Update]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[Parents_Update]
@pUserSKey		UNIQUEIDENTIFIER,
@pParentSKey	INT,
@pParent		NVARCHAR(50)
AS
-- ERROR CHECKING

IF @pParentSKey > 3 OR @pParentSKey < 1
BEGIN
	RETURN 2
END

IF @pParent IS NULL
BEGIN
	RETURN 3
END

IF EXISTS (SELECT UserSKey FROM DBO.PARENTS WHERE USERSKEY = @pUserSKEY)
BEGIN
	UPDATE dbo.Parents
	SET PARENT = @pParent
	WHERE UserSKey = @pUserSKey
	AND ParentSKey = @pParentSKey
	RETURN 0
END
ELSE
BEGIN
	RETURN 1
END
GO
ALTER AUTHORIZATION ON [dbo].[Parents_Update] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[TotalHours_Select]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TotalHours_Select]
@pUserSKey	UNIQUEIDENTIFIER
AS
DECLARE @pHOURS INT
DECLARE @pMINUTES INT
SET @pHOURS = (SELECT SUM(DATEDIFF(MINUTE, STARTDTM, ENDDTM)) / 60
				FROM DRIVES
				WHERE USERSKEY = @pUserSKey)
SET @pMINUTES = (SELECT SUM(DATEDIFF(MINUTE, STARTDTM, ENDDTM)) - (@pHOURS * 60)
				FROM DRIVES
				WHERE USERSKEY = @pUserSKey)

SELECT  CONVERT(NVARCHAR, @pHOURS) + ':' + CONVERT(NVARCHAR, @pMINUTES)
GO
ALTER AUTHORIZATION ON [dbo].[TotalHours_Select] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[Users_Insert]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[Users_Insert]
@pStudentName nvarchar(100),
@pStudentEmail nvarchar(256)
AS
DECLARE @pIdentity UNIQUEIDENTIFIER
DECLARE @FailureGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
-- ERROR CHECKING STARTS HERE
-- DETECT IF USERS ARE NULL
IF @pStudentName IS NULL OR @pStudentEmail IS NULL
BEGIN
	SELECT @FailureGuid
END

-- DETECT IF USER ALREADY EXISTS
IF EXISTS (SELECT STUDENTNAME FROM DBO.USERS WHERE STUDENTNAME = @pStudentName)
BEGIN
	SELECT @FailureGuid
END

IF EXISTS (SELECT STUDENTNAME FROM DBO.USERS 
	WHERE STUDENTNAME = @pStudentName
	AND STUDENTEMAIL = @pStudentEmail)
BEGIN
	SELECT @FailureGuid
END

IF EXISTS (SELECT STUDENTNAME FROM DBO.USERS WHERE STUDENTEMAIL = @pStudentEmail)
BEGIN
	SELECT @FailureGuid
END

-- INSERT VALUES
IF NOT EXISTS (SELECT UserSKey from dbo.USERS
	WHERE STUDENTNAME = @pStudentName
	AND STUDENTEMAIL = @pStudentEmail)
BEGIN
	SET @pIdentity = NEWID()
	INSERT dbo.USERS VALUES (@pIdentity, @pStudentName, GETDATE(), 1, @pStudentEmail)
	SELECT @pIdentity
END
ELSE
BEGIN
	SELECT @FailureGuid
END




GO
ALTER AUTHORIZATION ON [dbo].[Users_Insert] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Drives]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Drives](
	[UserSKey] [uniqueidentifier] NOT NULL,
	[DriveSKey] [int] IDENTITY(1,1) NOT NULL,
	[StartDTM] [datetime] NOT NULL,
	[EndDTM] [datetime] NOT NULL,
	[Topic] [nvarchar](1000) NULL,
	[Parent] [int] NOT NULL
)

GO
ALTER AUTHORIZATION ON [dbo].[Drives] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Parents]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parents](
	[UserSKey] [uniqueidentifier] NOT NULL,
	[ParentSKey] [int] NOT NULL,
	[Parent] [nvarchar](100) NOT NULL
)

GO
ALTER AUTHORIZATION ON [dbo].[Parents] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[Users]    Script Date: 9/20/2015 5:29:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserSKey] [uniqueidentifier] NOT NULL,
	[StudentName] [nvarchar](100) NOT NULL,
	[CreateDTM] [datetime] NOT NULL,
	[Active] [bit] NULL,
	[StudentEmail] [nvarchar](256) NULL
)

GO
ALTER AUTHORIZATION ON [dbo].[Users] TO  SCHEMA OWNER 
GO
/****** Object:  Index [Drives_UserSKey]    Script Date: 9/20/2015 5:29:16 PM ******/
CREATE CLUSTERED INDEX [Drives_UserSKey] ON [dbo].[Drives]
(
	[UserSKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [IX_Parents_UserSKey]    Script Date: 9/20/2015 5:29:16 PM ******/
CREATE CLUSTERED INDEX [IX_Parents_UserSKey] ON [dbo].[Parents]
(
	[UserSKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO
/****** Object:  Index [Users_UserSKey]    Script Date: 9/20/2015 5:29:16 PM ******/
CREATE CLUSTERED INDEX [Users_UserSKey] ON [dbo].[Users]
(
	[UserSKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF)
GO

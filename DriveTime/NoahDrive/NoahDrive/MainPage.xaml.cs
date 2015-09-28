using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;
using Microsoft.Phone.Controls;
using Microsoft.Phone.Shell;
using NoahDrive.Resources;

namespace NoahDrive
{
    public partial class MainPage : PhoneApplicationPage
    {
        public MainPage()
        {
            InitializeComponent();
        }

        private void cmdNewDrive_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new Uri("/NewDrive.xaml", UriKind.Relative));
        }

        private void cmdReport_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new Uri("/Report.xaml", UriKind.Relative));
        }

    }
}
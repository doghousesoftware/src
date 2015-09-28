using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Collections.ObjectModel;

namespace WPF_MVVM_Explained
{
    public class TheModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private int indexnumber { get; set; }
        public int IndexNumber {
            get
            {
                return this.indexnumber;
            }
            set
            {
                if (value != this.indexnumber)
                {
                    this.indexnumber = value;
                    NotifyPropertyChanged("IndexNumber");
                }
            }
        }

        private string objectname { get; set; }
        public string ObjectName {
            get
            {
                return this.objectname;
            }
            set
            {
                if (value != this.objectname)
                {
                    this.objectname = value;
                    NotifyPropertyChanged("ObjectName");
                }
            }
        }
        
        private bool isvisible { get; set; }
        public bool IsVisible 
        { 
            get
            {
                return this.isvisible;
            }
            set
            {
                if (value != this.isvisible)
                {
                    this.isvisible = value;
                    NotifyPropertyChanged("IsVisible");
                }
            }
        }

        private void NotifyPropertyChanged(String propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }

    }
}

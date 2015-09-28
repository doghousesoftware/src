using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Collections.ObjectModel;
using System.Windows.Input;

namespace WPF_MVVM_Explained
{
    public class TheViewModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private ObservableCollection<TheModel> theviewmodel { get; set; }
        public ObservableCollection<TheModel> ThisViewModel
        {
            get
            {
                return this.theviewmodel;
            }
            set
            {
                if (this.theviewmodel != value)
                {
                    this.theviewmodel = value;
                    NotifyPropertyChanged("TheViewModel");
                }
            }
        }


        public void MainViewModel()
        {
            LoadViewModel();
            _canExecute = true;
        }

        private void LoadViewModel()
        {
            ObservableCollection<TheModel> xModel = new ObservableCollection<TheModel>();
            TheModel t0 = new TheModel();
            t0.IndexNumber = 0;
            t0.ObjectName = "first object";
            t0.IsVisible = true;
            xModel.Add(t0);
            TheModel t1 = new TheModel();
            t1.IndexNumber = 1;
            t1.ObjectName = "second object";
            t1.IsVisible = false;
            xModel.Add(t1);
            TheModel t2 = new TheModel();
            t2.IndexNumber = 2;
            t2.ObjectName = "third object";
            t2.IsVisible = true;
            xModel.Add(t2);
            this.ThisViewModel = xModel;

        }

        private void NotifyPropertyChanged(string propertyName)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        private ICommand _clickCommand;
        public ICommand ClickCommand
        {
            get
            {
                return _clickCommand ?? (_clickCommand = new CommandHandler(() => MyAction(), _canExecute));
            }
        }
        private bool _canExecute;
        public void MyAction()
        {
            foreach (TheModel item in ThisViewModel)
            {
                if (item.IsVisible)
                {
                    item.IsVisible = false;
                }
                else
                {
                    item.IsVisible = true;
                }
            }
        }


        private ICommand _textCommand;
        public ICommand TextCommand
        {
            get
            {
                return _textCommand ?? (_textCommand = new CommandHandler(() => MyTextCommand(), _canExecute));
            }
        }

        public void MyTextCommand()
        {
            foreach (TheModel item in ThisViewModel)
            {
                item.ObjectName = "i've been massively changed!";
            }
        }
    }
}

using System;

namespace ttalviste.web.Models
{
    public class BaseViewModel
    {
        public BaseViewModel()
        {
            PageTitle = string.Format("{0} - ",common.Configuration.WebSiteName);
        }
        public string PageTitle { get; set; }

        protected void AddToPageTitle(string pageTitle = "")
        {
            PageTitle += pageTitle;
        }
    }
    
}
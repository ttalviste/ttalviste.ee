using System;
using ttalviste.web.Models;
namespace ttalviste.web.Models.Home
{
    public class BaseHomeViewModel : BaseViewModel
    {
        public BaseHomeViewModel() : base()
        {
            AddToPageTitle("Home");
        }

        public BaseHomeViewModel(string actionName) : base()
        {
            AddToPageTitle(actionName);
        }
    }
}
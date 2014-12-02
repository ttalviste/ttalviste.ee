using System;
using System.Threading.Tasks;
using Microsoft.AspNet.Mvc;
using Microsoft.AspNet.Mvc.Razor;
using ttalviste.web.Models.Home;
using System.Threading;

namespace ttalviste.web.Controllers
{
    public class RazorTest : RazorPage
    {
        public override Task ExecuteAsync()
        {
            throw new NotImplementedException();
        }
    }
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            var model = new IndexViewModel();
            return View(model);
        }

        public IActionResult Error()
        {
            return View("~/Views/Shared/Error.cshtml");
        }
    }
}
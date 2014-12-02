using Microsoft.AspNet.Mvc;
using ttalviste.web.Models.Home;
namespace ttalviste.web.Controllers
{
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
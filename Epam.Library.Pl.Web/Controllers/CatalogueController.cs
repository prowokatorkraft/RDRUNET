using Epam.Library.Pl.Web.Models;
using Epam.Library.Pl.Web.ViewModels;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class CatalogueController : Controller
    {
        private CatalogueRepo _catalogue;

        public CatalogueController(CatalogueRepo catalogue)
        {
            _catalogue = catalogue;
        }

        [HttpGet]
        public ActionResult GetAll(int pageNumber = 1)
        {
            var elements = _catalogue.GetAll(pageNumber);

            return View(elements);
        }

        [HttpGet]
        public ActionResult Create(TypeEnumVM typeRadio)
        {
            switch (typeRadio)
            {
                case TypeEnumVM.Book:
                    return RedirectToAction("Create", controllerName: "Book");
                case TypeEnumVM.Patent:
                    break;
                case TypeEnumVM.Newspaper:
                    break;
                default:
                    break;
            }

            return View();
        }
    }
}
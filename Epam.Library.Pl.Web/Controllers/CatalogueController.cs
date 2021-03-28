using AutoMapper;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.DependencyInjection;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Pl.Web.Models;
using Epam.Library.Pl.Web.ViewModels.Catalogue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class CatalogueController : Controller
    {
        private static CatalogueRepo _catalogue;

        static CatalogueController()
        {
            _catalogue = new CatalogueRepo(DependencyInjection.CatalogueBll);
        }

        [HttpGet]
        public ActionResult GetAll(int pageNumber = 1)
        {
            var elements = _catalogue.GetAll(pageNumber);

            return View(elements);
        }
    }
}
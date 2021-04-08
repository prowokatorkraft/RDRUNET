using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Web.Mvc;
using System.Web.Routing;

namespace Epam.Library.Pl.Web.Controllers
{
    public class CatalogueController : Controller
    {
        ICatalogueBll _catalogueBll;
        Mapper _mapper;

        public CatalogueController(ICatalogueBll catalogueBll, Mapper mapper)
        {
            _catalogueBll = catalogueBll;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult GetAll(int pageNumber = 1, string searchLine = null)
        {
            List<ElementVM> elements = new List<ElementVM>();

            var values = new RouteValueDictionary();
            if (searchLine != null)
            {
                values.Add("searchLine", searchLine);
            }

            var page = new PageDataVM<ElementVM>()
            {
                PageInfo = new PageInfoVM()
                {
                    CurrentPage = pageNumber,
                    CountPage = (int)Math.Ceiling(a: _catalogueBll.GetCount(
                                                searchLine is null 
                                                    ? CatalogueSearchOptions.None 
                                                    : CatalogueSearchOptions.Name, 
                                                searchLine
                    ) / 20d),
                    Action = nameof(GetAll),
                    Controller = "Catalogue",
                    Values = values
                },
                Elements = elements
            };

            foreach (var item in _catalogueBll.Search(new SearchRequest<SortOptions, CatalogueSearchOptions>()
            {
                SortOptions = SortOptions.Ascending,
                SearchOptions = searchLine is null ? CatalogueSearchOptions.None : CatalogueSearchOptions.Name,
                SearchLine = searchLine,
                PagingInfo = new PagingInfo(20, pageNumber)
            }))
            {
                switch (item)
                {
                    case Book o:
                        elements.Add(_mapper.Map<ElementVM, Book>(o));
                        break;
                    case Patent o:
                        elements.Add(_mapper.Map<ElementVM, Patent>(o));
                        break;
                    //case Newspaper o:
                    //    yield return MapperConfig.Map<ElementViewModel, Newspaper>(o);
                    //    break;
                    default:
                        break;
                }
            }

            return View(page);
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
            }

            return View();
        }

        [HttpGet]
        public ActionResult Display(int id, TypeEnumVM type)
        {
            switch (type)
            {
                case TypeEnumVM.Book:
                    return RedirectToAction("Display", controllerName: "Book", routeValues: new { id = id });
                case TypeEnumVM.Patent:
                    break;
                case TypeEnumVM.Newspaper:
                    break;
            }

            return View();
        }
    }
}
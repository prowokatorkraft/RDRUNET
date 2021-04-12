using Epam.Common.Entities;
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
        private ICatalogueBll _catalogueBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public CatalogueController(ICatalogueBll catalogueBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _catalogueBll = catalogueBll;
            _accountBll = accountBll;
            _roleBll = roleBll;
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

            var role = GetRoleByCurrentUser();
            var page = new PageDataVM<ElementVM>()
            {
                PageInfo = new PageInfoVM()
                {
                    CurrentPage = pageNumber,
                    CountPage = (int)Math.Ceiling(a: _catalogueBll.GetCount(
                                                searchLine is null 
                                                    ? CatalogueSearchOptions.None 
                                                    : CatalogueSearchOptions.Name, 
                                                searchLine,
                                                role
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
            }, role))
            {
                switch (item)
                {
                    case Book o:
                        elements.Add(_mapper.Map<ElementVM, Book>(o, role));
                        break;
                    case Patent o:
                        elements.Add(_mapper.Map<ElementVM, Patent>(o, role));
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
                    return RedirectToAction("Create", controllerName: "Patent");
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
                    return RedirectToAction("Display", controllerName: "Patent", routeValues: new { id = id });
                case TypeEnumVM.Newspaper:
                    break;
            }

            return View();
        }

        private RoleType GetRoleByCurrentUser()
        {
            string roleName = null;
            if (User.Identity.IsAuthenticated)
            {
                roleName = _roleBll.GetById(_accountBll.GetByLogin(User.Identity.Name).RoleId).Name;
            }

            return GetRole(roleName);
        }
        private RoleType GetRole(string roleName)
        {
            switch (roleName)
            {
                case "admin":
                    return RoleType.admin;
                case "librarian":
                    return RoleType.librarian;
                case "user":
                    return RoleType.user;
                default:
                    return RoleType.None;
            }
        }
    }
}
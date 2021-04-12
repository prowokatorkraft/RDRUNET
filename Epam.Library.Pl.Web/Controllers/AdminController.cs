using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Epam.Library.Pl.Web.Controllers
{
    public class AdminController : Controller
    {
        private readonly IAccountBll _accountBll;
        private readonly IRoleBll _roleBll;
        private readonly Mapper _mapper;

        public AdminController(IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        public ActionResult GetAll(int pageNumber = 1, string searchLine = null)
        {
            var role = GetRoleByCurrentUser();
            List<AccountVM> elements = new List<AccountVM>();

            var values = new RouteValueDictionary();
            if (searchLine != null)
            {
                values.Add("searchLine", searchLine);
            }

            var page = new PageDataVM<AccountVM>()
            {
                PageInfo = new PageInfoVM()
                {
                    CurrentPage = pageNumber,
                    CountPage = (int)Math.Ceiling(a: _accountBll.GetCount(
                                                searchLine is null
                                                    ? AccountSearchOptions.None
                                                    : AccountSearchOptions.Login,
                                                searchLine
                    ) / 20d),
                    Action = nameof(GetAll),
                    Controller = "Admin",
                    Values = values
                },
                Elements = elements
            };

            foreach (var item in _accountBll.Search(new SearchRequest<SortOptions, AccountSearchOptions>()
            {
                SortOptions = SortOptions.Ascending,
                SearchOptions = searchLine is null ? AccountSearchOptions.None : AccountSearchOptions.Login,
                SearchLine = searchLine,
                PagingInfo = new PagingInfo(20, pageNumber)
            }))
            {
                elements.Add(_mapper.Map<AccountVM, Account>(item, role));
            }

            return View(page);
        }

        public ActionResult EditRole(long id)
        {
            var role = GetRoleByCurrentUser();
            var acc = _mapper.Map<AccountVM, Account>(_accountBll.GetById(id), role);

            return View(acc);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EditRole(long id, RoleType roleRadio)
        {
            switch (roleRadio)
            {
                case RoleType.admin:
                    _accountBll.UpdateRole(id, _roleBll.GetByName(RoleType.admin.ToString()).Id.Value);
                    break;
                case RoleType.librarian:
                    _accountBll.UpdateRole(id, _roleBll.GetByName(RoleType.librarian.ToString()).Id.Value);
                    break;
                case RoleType.user:
                    _accountBll.UpdateRole(id, _roleBll.GetByName(RoleType.user.ToString()).Id.Value);
                    break;
            }

            return RedirectToAction("GetAll", controllerName: "Admin");
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
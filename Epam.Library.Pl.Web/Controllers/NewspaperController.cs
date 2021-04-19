using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class NewspaperController : Controller
    {
        private INewspaperBll _newspaperBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public NewspaperController(INewspaperBll newspaperBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _newspaperBll = newspaperBll;
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        [HttpPost]
        public ActionResult Create(CreateEditNewspaperVM newspaper)
        {
            IEnumerable<ErrorValidation> errors;

            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                errors = _newspaperBll.Add(_mapper.Map<Newspaper, CreateEditNewspaperVM>(newspaper, role));

                if (!errors.Any())
                {
                    return Json("");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }
            else
            {
                errors = new List<ErrorValidation>() { new ErrorValidation("Model", "Newspaper is invalid.", null) };
            }

            return Json(errors);
        }

        [HttpGet]
        public ActionResult GetList()
        {
            List<DisplayNewspaperVM> list = new List<DisplayNewspaperVM>();

            var role = GetRoleByCurrentUser();
            foreach (var item in _newspaperBll.Search(null, role))
            {
                list.Add(_mapper.Map<DisplayNewspaperVM, Newspaper>(item, role));
            }

            return Json(list, JsonRequestBehavior.AllowGet);
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
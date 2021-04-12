using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class AuthorController : Controller
    {
        private IAuthorBll _authorBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public AuthorController(IAuthorBll authorBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _authorBll = authorBll;
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        [HttpPost]
        public ActionResult Create(CreateEditAuthorVM author)
        {
            IEnumerable<ErrorValidation> errors;

            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                errors = _authorBll.Add(_mapper.Map<Author, CreateEditAuthorVM>(author, role));

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
                errors = new List<ErrorValidation>() { new ErrorValidation("Model", "Author is invalid.", null) };
            }

            return Json(errors);
        }

        [HttpGet]
        public ActionResult GetList()
        {
            List<DisplayAuthorVM> list = new List<DisplayAuthorVM>();

            var role = GetRoleByCurrentUser();
            foreach (var item in _authorBll.Search(null, role))
            {
                list.Add(_mapper.Map<DisplayAuthorVM, Author>(item, role));
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
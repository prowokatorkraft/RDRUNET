using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class PatentController : Controller
    {
        private IPatentBll _patentBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public PatentController(IPatentBll patentBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _patentBll = patentBll;
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(CreateEditPatentVM patent)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _patentBll.Add(_mapper.Map<Patent, CreateEditPatentVM>(patent, role), role);

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(patent);
        }

        [HttpGet]
        public ActionResult Edit(int id)
        {
            var role = GetRoleByCurrentUser();
            var patent = _mapper.Map<CreateEditPatentVM, Patent>(_patentBll.Get(id, role) as Patent, role);

            return View(patent);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(CreateEditPatentVM patent)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _patentBll.Update(_mapper.Map<Patent, CreateEditPatentVM>(patent, role), role);

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(patent);
        }

        [HttpGet]
        public ActionResult Display(int id)
        {
            var role = GetRoleByCurrentUser();
            var patent = _mapper.Map<DisplayPatentVM, Patent>(_patentBll.Get(id, role) as Patent, role);

            return View(patent);
        }

        [HttpGet]
        public ActionResult Remove(int id)
        {
            var role = GetRoleByCurrentUser();
            var patent = _mapper.Map<ElementVM, Patent>(_patentBll.Get(id, role) as Patent, role);

            return View(patent);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var role = GetRoleByCurrentUser();
            if (_patentBll.Remove(id, role))
            {
                return Redirect("~/");
            }

            return RedirectToAction("Remove", new { id = id });
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
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class BookController : Controller
    {
        private IBookBll _bookBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public BookController(IBookBll bookBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _bookBll = bookBll;
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
        public ActionResult Create(CreateEditBookVM book)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _bookBll.Add(_mapper.Map<Book,CreateEditBookVM>(book, role));

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(book);
        }

        [HttpGet]
        public ActionResult Edit(int id)
        {
            var role = GetRoleByCurrentUser();
            var book = _mapper.Map<CreateEditBookVM, Book>(_bookBll.Get(id, role) as Book, role);

            return View(book);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(CreateEditBookVM book)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _bookBll.Update(_mapper.Map<Book, CreateEditBookVM>(book, role), role);

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(book);
        }

        [HttpGet]
        public ActionResult Display(int id)
        {
            var role = GetRoleByCurrentUser();
            var book = _mapper.Map<DisplayBookVM, Book>(_bookBll.Get(id, role) as Book, role);
            
            return View(book);
        }

        [HttpGet]
        public ActionResult Remove(int id)
        {
            var role = GetRoleByCurrentUser();
            var book = _mapper.Map<ElementVM, Book>(_bookBll.Get(id, role) as Book, role);

            return View(book);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var role = GetRoleByCurrentUser();
            if (_bookBll.Remove(id, role))
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
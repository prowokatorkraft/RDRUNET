using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using System.Web.Routing;

namespace Epam.Library.Pl.Web.Controllers
{
    public class NewspaperIssueController : Controller
    {
        private INewspaperIssueBll _newspaperIssueBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public NewspaperIssueController(INewspaperIssueBll newspaperIssueBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _newspaperIssueBll = newspaperIssueBll;
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
        public ActionResult Create(CreateEditNewspaperIssueVM newspaperIssue)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _newspaperIssueBll.Add(_mapper.Map<NewspaperIssue, CreateEditNewspaperIssueVM>(newspaperIssue, role));

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(newspaperIssue);
        }

        [HttpGet]
        public ActionResult Edit(int id)
        {
            var role = GetRoleByCurrentUser();
            var issue = _mapper.Map<CreateEditNewspaperIssueVM, NewspaperIssue>(_newspaperIssueBll.Get(id, role), role);

            return View(issue);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(CreateEditNewspaperIssueVM issue)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _newspaperIssueBll.Update(_mapper.Map<NewspaperIssue, CreateEditNewspaperIssueVM>(issue, role), role);

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(issue);
        }

        [HttpGet]
        [AllowAnonymous]
        public ActionResult Display(int id, int pageNumber = 1)
        {
            const int sizePage = 10;
            var role = GetRoleByCurrentUser();
            var NewspaperIssue = _mapper.Map<DisplayNewspaperIssueVM, NewspaperIssue>(_newspaperIssueBll.Get(id, role), role);
            List<ElementVM> elements = new List<ElementVM>();

            var values = new RouteValueDictionary();
            values.Add("id", id);

            NewspaperIssue.PageData = new PageDataVM<ElementVM>()
            {
                PageInfo = new PageInfoVM()
                {
                    CurrentPage = pageNumber,
                    CountPage = (int)Math.Ceiling(a: _newspaperIssueBll.GetCountByNewspaper(NewspaperIssue.Newspaper.Id.Value, role) / (double)sizePage),
                    Action = nameof(Display),
                    Controller = "NewspaperIssue",
                    Values = values
                },
                Elements = elements
            };

            foreach (var item in _newspaperIssueBll.GetAllByNewspaper(NewspaperIssue.Newspaper.Id.Value, new PagingInfo(sizePage, pageNumber), SortOptions.Descending, role))
            {
                elements.Add(_mapper.Map<ElementVM, NewspaperIssue>(item, role));
            }

            return View(NewspaperIssue);
        }

        [HttpGet]
        public ActionResult Remove(int id)
        {
            var role = GetRoleByCurrentUser();
            var book = _mapper.Map<ElementVM, NewspaperIssue>(_newspaperIssueBll.Get(id, role), role);

            return View(book);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var role = GetRoleByCurrentUser();
            if (_newspaperIssueBll.Remove(id, role))
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
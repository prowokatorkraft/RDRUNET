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
        private Mapper _mapper;

        public AuthorController(IAuthorBll authorBll, Mapper mapper)
        {
            _authorBll = authorBll;
            _mapper = mapper;
        }

        [HttpPost]
        public ActionResult Create(CreateEditAuthorVM author)
        {
            IEnumerable<ErrorValidation> errors;

            if (ModelState.IsValid)
            {
                errors = _authorBll.Add(_mapper.Map<Author, CreateEditAuthorVM>(author));

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

            foreach (var item in _authorBll.Search(null))
            {
                list.Add(_mapper.Map<DisplayAuthorVM, Author>(item));
            }

            return Json(list, JsonRequestBehavior.AllowGet);
        }
    }
}
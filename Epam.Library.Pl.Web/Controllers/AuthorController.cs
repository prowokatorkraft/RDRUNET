using Epam.Library.Bll.Contracts;
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
        public ActionResult GetList()
        {
            List<GetAuthorVM> list = new List<GetAuthorVM>();

            foreach (var item in _authorBll.Search(null))
            {
                list.Add(_mapper.Map<GetAuthorVM, Author>(item));
            }

            return Json(list);
        }
    }
}
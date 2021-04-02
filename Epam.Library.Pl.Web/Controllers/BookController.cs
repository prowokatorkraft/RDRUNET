using Epam.Library.Bll.Contracts;
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
        IBookBll _bookBll;
        Mapper _mapper;

        public BookController(IBookBll bookBll, Mapper mapper)
        {
            _bookBll = bookBll;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Create(CreateEditBookVM book)
        {
            if (ModelState.IsValid)
            {
                var errors = _bookBll.Add(_mapper.Map<Book,CreateEditBookVM>(book));

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
            var book = _mapper.Map<CreateEditBookVM, Book>(_bookBll.Get(id) as Book);

            return View(book);
        }

        [HttpPost]
        public ActionResult Edit(CreateEditBookVM book)
        {
            if (ModelState.IsValid)
            {
                var errors = _bookBll.Update(_mapper.Map<Book, CreateEditBookVM>(book));

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
            var book = _mapper.Map<DisplayBookVM, Book>(_bookBll.Get(id) as Book);
            
            return View(book);
        }

        [HttpGet]
        public ActionResult Remove(int id)
        {
            var book = _mapper.Map<ElementVM, Book>(_bookBll.Get(id) as Book);

            return View(book);
        }

        [HttpPost]
        public ActionResult Delete(int id)
        {
            if (_bookBll.Remove(id))
            {
                return Redirect("~/");
            }

            return RedirectToAction("Remove", new { id = id });
        }
    }
}
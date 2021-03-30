﻿using Epam.Library.Pl.Web.Models;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class BookController : Controller
    {
        private BookRepo _book;

        public BookController(BookRepo book)
        {
            _book = book;
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Create(CreateBookVM book)
        {
            if (ModelState.IsValid)
            {
                if (_book.Add(book))
                {
                    return Redirect("~/");
                }
            }

            return View(book);
        }
    }
}
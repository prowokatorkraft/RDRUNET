using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Epam.Library.Pl.Web.Models
{
    public class BookRepo
    {
        IBookBll _bookBll;
        Mapper _mapper;

        public BookRepo(IBookBll bookBll, Mapper mapper)
        {
            _bookBll = bookBll;
            _mapper = mapper;
        }

        public bool Add(CreateBookVM book)
        {
            if (!_bookBll.Add(_mapper.Map<Book,CreateBookVM>(book)).Any())
            {
                return true;
            }

            return false;
        }
    }
}
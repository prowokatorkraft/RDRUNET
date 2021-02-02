using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class BookBll : IBookBll
    {
        protected readonly IBookDao _dao;

        protected readonly IValidation<AbstractBook> _validation;

        public BookBll(IBookDao bookDao, IValidation<AbstractBook> validation)
        {
            _dao = bookDao;
            _validation = validation;
        }

        public void AddBook(AbstractBook book)
        {
            try
            {
                _validation.Validate(book);

                _dao.AddBook(book);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
            }
        }

        public void RemoveBook(AbstractBook book)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException("Book is null!");
                }

                _dao.RemoveBook(book);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing element!", ex);
            }
        }

        public IEnumerable<AbstractBook> SearchBooks(SortOptions sortOptions, BookSearchOptions searchOptions, string search)
        {
            foreach (var item in _dao.SearchBooks(sortOptions, searchOptions, search))
            {
                yield return item;
            }
        }

        public IEnumerable<IGrouping<int, AbstractBook>> GetAllBookGroupsByPublishYear()
        {
            foreach (var item in _dao.GetAllBookGroupsByPublishYear())
            {
                yield return item;
            }
        }
    }
}

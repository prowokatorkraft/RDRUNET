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

        protected readonly IAuthorBll _author;

        protected readonly IValidationBll<AbstractBook> _validation;

        public BookBll(IBookDao bookDao, IAuthorBll author, IValidationBll<AbstractBook> validation)
        {
            _dao = bookDao;
            _author = author;
            _validation = validation;
        }

        public ErrorValidation[] Add(AbstractBook book)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException(nameof(book) + " is null");
                }

                if (book.AuthorIDs != null && !_author.Check(book.AuthorIDs))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(book);

                if (errors.Length == 0)
                {
                    _dao.Add(book);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item.", ex);
            }
        }

        public bool Remove(int id)
        {
            try
            {
                return _dao.Remove(id);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing item.", ex);
            }
        }

        public IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            try
            {
                return _dao.Search(searchRequest);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public IEnumerable<IGrouping<int, AbstractBook>> GetAllGroupsByPublishYear()
        {
            try
            {
                return _dao.GetAllGroupsByPublishYear();
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public AbstractBook Get(int id)
        {
            try
            {
                return _dao.Get(id);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }
    }
}

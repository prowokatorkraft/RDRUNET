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

        protected readonly IValidationBll<AbstractBook> _validation;

        public BookBll(IBookDao bookDao, IValidationBll<AbstractBook> validation)
        {
            _dao = bookDao;
            _validation = validation;
        }

        public ErrorValidation[] Add(AbstractBook book)
        {
            try
            {
                var errors = _validation.Validate(book);

                if (errors.Length == 0)
                {
                    _dao.Add(book);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
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
                throw new RemoveException("Error removing item!", ex);
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
                throw new GetException("Error getting item!", ex);
            }
        }

        public IEnumerable<IGrouping<int, AbstractBook>> GetAllGroupsByPublishYear()
        {
            try
            {
                return _dao.GetAllBookGroupsByPublishYear();
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item!", ex);
            }
        }
    }
}

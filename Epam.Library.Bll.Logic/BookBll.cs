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

        public IEnumerable<ErrorValidation> Add(AbstractBook book, RoleType role = RoleType.None)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException(nameof(book) + " is null");
                }

                if (book.AuthorIDs != null && !_author.Check(book.AuthorIDs, role))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(book);

                if (errors.Count() == 0)
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

        public IEnumerable<ErrorValidation> Update(AbstractBook book, RoleType role = RoleType.None)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException(nameof(book) + " is null");
                }
                else if (book.Id is null)
                {
                    throw new ArgumentNullException(nameof(book.Id) + " is null");
                }

                if (book.AuthorIDs != null && !_author.Check(book.AuthorIDs, role))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(book);

                if (errors.Count() == 0)
                {
                    _dao.Update(book);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating item.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Remove(id, role);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing item.", ex);
            }
        }

        public IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetAllGroupsByPublishYear(role: role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetAllGroupsByPublisher(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public AbstractBook Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentOutOfRangeException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetByAuthorId(id, page, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }
    }
}

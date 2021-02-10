using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using Epam.Library.Dal.Contracts;
using System;
using System.Linq;
using System.Collections.Generic;

namespace Epam.Library.Bll
{
    public class AuthorBll : IAuthorBll
    {
        protected readonly IAuthorDao _dao;

        protected readonly ICatalogueBll _catalogueBll;

        protected readonly IValidationBll<Author> _validation;

        public AuthorBll(IAuthorDao dao, ICatalogueBll catalogueBll, IValidationBll<Author> validation)
        {
            _dao = dao;
            _catalogueBll = catalogueBll;
            _validation = validation;
        }

        public IEnumerable<ErrorValidation> Add(Author author)
        {
            try
            {
                var errors = _validation.Validate(author);

                if (errors.Count() == 0)
                {
                    _dao.Add(author);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item.", ex);
            }
        }

        public Author Get(int id)
        {
            try
            {
                return _dao.Get(id) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public bool Check(int[] ids)
        {
            try
            {
                return _dao.Check(ids);
            }
            catch (Exception ex)
            {
                throw new GetException("Error checking item.", ex);
            }
        }

        public bool Remove(int id)
        {
            try
            {
                if (_catalogueBll.GetByAuthorId(id).Count() > 0)
                {
                    return false;
                }

                return _dao.Remove(id);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing item.", ex);
            }
        }

        public IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest)
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
    }
}

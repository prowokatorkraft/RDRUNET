using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
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
                if (author is null)
                {
                    throw new ArgumentNullException(nameof(author) + " is null");
                }

                var errors = _validation.Validate(author);

                if (errors.Count() == 0)
                {
                    _dao.Add(author);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Add), "Error adding item.", ex);
            }
        }

        public IEnumerable<ErrorValidation> Update(Author author)
        {
            try
            {
                if (author is null)
                {
                    throw new ArgumentNullException(nameof(author) + " is null");
                }
                else if (author.Id is null)
                {
                    throw new ArgumentNullException(nameof(author.Id) + $" is null");
                }

                var errors = _validation.Validate(author);

                if (errors.Count() == 0)
                {
                    _dao.Update(author);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Update), "Error updating item.", ex);
            }
        }

        public Author Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Get), "Error getting item.", ex);
            }
        }

        public bool Check(int[] ids, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Check(ids, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Check), "Error getting item.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                if (_catalogueBll.GetByAuthorId(id, role).Count() > 0)
                {
                    return false;
                }

                return _dao.Remove(id, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Remove), "Error removing item.", ex);
            }
        }

        public IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AuthorBll), nameof(Search), "Error getting item.", ex);
            }
        }
    }
}

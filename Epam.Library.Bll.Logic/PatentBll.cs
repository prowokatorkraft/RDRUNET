using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class PatentBll : IPatentBll
    {
        protected readonly IPatentDao _dao;

        protected readonly IAuthorBll _author;

        protected readonly IValidationBll<AbstractPatent> _validation;
        
        public PatentBll(IPatentDao patentDao, IAuthorBll author, IValidationBll<AbstractPatent> validation)
        {
            _dao = patentDao;
            _validation = validation;
            _author = author;
        }

        public IEnumerable<ErrorValidation> Add(AbstractPatent patent)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException(nameof(patent) + " is null");
                }

                if (patent.AuthorIDs != null && !_author.Check(patent.AuthorIDs))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(patent);

                if (errors.Count() == 0)
                {
                    _dao.Add(patent);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item.", ex);
            }
        }

        public AbstractPatent Get(int id)
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

        public IEnumerable<AbstractPatent> GetByAuthorId(int id)
        {
            try
            {
                return _dao.GetByAuthorId(id);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
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

        public IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest)
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

        public Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear()
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
    }
}

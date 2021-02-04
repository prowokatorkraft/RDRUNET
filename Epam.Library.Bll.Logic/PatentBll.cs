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
        protected readonly IPatentBll _dao;

        protected readonly IAuthorBll _author;

        protected readonly IValidationBll<AbstractPatent> _validation;
        
        public PatentBll(IPatentBll patentDao, IAuthorBll author, IValidationBll<AbstractPatent> validation)
        {
            _dao = patentDao;
            _validation = validation;
            _author = author;
        }

        public ErrorValidation[] Add(AbstractPatent patent)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException(nameof(patent) + " is null");
                }

                if (patent.AuthorIDs != null && !_author.Check(patent.AuthorIDs).All(s => s))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(patent);

                if (errors.Length == 0)
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
                return _dao.Get(id);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
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

        public IEnumerable<IGrouping<int, AbstractPatent>> GetAllGroupsByPublishYear()
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

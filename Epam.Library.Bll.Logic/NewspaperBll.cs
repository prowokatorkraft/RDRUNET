using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class NewspaperBll : INewspaperBll
    {
        protected readonly INewspaperDao _dao;

        protected readonly IValidationBll<AbstractNewspaper> _validation;
        
        public NewspaperBll(INewspaperDao newspaperDao, IValidationBll<AbstractNewspaper> validation)
        {
            _dao = newspaperDao;
            _validation = validation;
        }

        public ErrorValidation[] Add(AbstractNewspaper newspaper)
        {
            try
            {
                var errors = _validation.Validate(newspaper);

                if (errors.Length == 0)
                {
                    _dao.Add(newspaper);
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

        public IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
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

        public IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllGroupsByPublishYear()
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
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
    public class NewspaperBll : IOldNewspaperBll
    {
        protected readonly IOldNewspaperDao _dao;

        protected readonly IValidationBll<AbstractOldNewspaper> _validation;
        
        public NewspaperBll(IOldNewspaperDao newspaperDao, IValidationBll<AbstractOldNewspaper> validation)
        {
            _dao = newspaperDao;
            _validation = validation;
        }

        public IEnumerable<ErrorValidation> Add(AbstractOldNewspaper newspaper)
        {
            try
            {
                if (newspaper is null)
                {
                    throw new ArgumentNullException(nameof(newspaper) + " is null");
                }

                var errors = _validation.Validate(newspaper);

                if (errors.Count() == 0)
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

        public IEnumerable<ErrorValidation> Update(AbstractOldNewspaper newspaper)
        {
            try
            {
                if (newspaper is null)
                {
                    throw new ArgumentNullException(nameof(newspaper) + " is null");
                }
                else if (newspaper.Id is null)
                {
                    throw new ArgumentNullException(nameof(newspaper.Id) + " is null");
                }

                var errors = _validation.Validate(newspaper);

                if (errors.Count() == 0)
                {
                    _dao.Update(newspaper);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating item.", ex);
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

        public AbstractOldNewspaper Get(int id)
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

        public IEnumerable<AbstractOldNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
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

        public Dictionary<int, List<AbstractOldNewspaper>> GetAllGroupsByPublishYear()
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
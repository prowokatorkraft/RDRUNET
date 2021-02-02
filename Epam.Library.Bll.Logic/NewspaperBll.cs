using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Logic
{
    public class NewspaperBll : INewspaperBll
    {
        protected readonly INewspaperDao _dao;

        protected readonly IValidation<AbstractNewspaper> _validation;
        
        public NewspaperBll(INewspaperDao newspaperDao, IValidation<AbstractNewspaper> validation)
        {
            _dao = newspaperDao;
            _validation = validation;
        }

        public void AddNewspaper(AbstractNewspaper newspaper)
        {
            try
            {
                _validation.Validate(newspaper);

                _dao.AddNewspaper(newspaper);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
            }
        }

        public void RemoveNewspaper(AbstractNewspaper newspaper)
        {
            try
            {
                if (newspaper is null)
                {
                    throw new ArgumentNullException("Newspaper is null!");
                }

                _dao.RemoveNewspaper(newspaper);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing element!", ex);
            }
        }

        public IEnumerable<AbstractNewspaper> SearchNewspapers(SortOptions sortOptions, BookSearchOptions searchOptions, string search)
        {
            foreach (var item in _dao.SearchNewspapers(sortOptions, searchOptions, search))
            {
                yield return item;
            }
        }

        public IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllNewspaperGroupsByPublishYear()
        {
            foreach (var item in _dao.GetAllNewspaperGroupsByPublishYear())
            {
                yield return item;
            }
        }
    }
}
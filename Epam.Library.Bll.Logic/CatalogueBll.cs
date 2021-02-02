using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Logic
{
    class CatalogueBll : ICatalogueBll
    {
        protected readonly ICatalogueDao _catalogueDao;

        public CatalogueBll(ICatalogueDao catalogueDao)
        {
            _catalogueDao = catalogueDao;
        }

        public IEnumerable<LibraryAbstractElement> SearchElements(SortOptions sortOptions, CatalogueSearchOptions searchOptions, string search)
        {
            foreach (var item in _catalogueDao.SearchElements(sortOptions, searchOptions, search))
            {
                yield return item;
            }
        }
    }
}

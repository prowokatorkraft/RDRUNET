using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using Epam.Library.Common.Entities.AuthorElement;

namespace Epam.Library.Bll
{
    public class CatalogueBll : ICatalogueBll
    {
        protected readonly ICatalogueDao _dao;

        public CatalogueBll(ICatalogueDao catalogueDao)
        {
            _dao = catalogueDao;
        }

        public LibraryAbstractElement Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(CatalogueBll), nameof(Get), "Error getting item.", ex);
            }
        }

        public IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetByAuthorId(id, numberOfPageFilter: numberOfPageFilter, role: role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(CatalogueBll), nameof(GetByAuthorId), "Error getting item.", ex);
            }
        }

        public int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetCount(searchOptions, searchLine, numberOfPageFilter, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(CatalogueBll), nameof(GetCount), "Error getting item.", ex);
            }
        }

        public IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(CatalogueBll), nameof(Search), "Error getting item.", ex);
            }
        }
    }
}

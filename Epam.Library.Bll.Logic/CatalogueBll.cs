using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Common.Entities;

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
                throw new GetException("Error getting value.", ex);
            }
        }

        public IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetByAuthorId(id, role: role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting value.", ex);
            }
        }

        public int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetCount(searchOptions, searchLine, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
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
                throw new GetException("Error getting item.", ex);
            }
        }
    }
}

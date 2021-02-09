using Epam.Library.Common.Entities.Exceptions;
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

        public LibraryAbstractElement Get(int id)
        {
            try
            {
                return _dao.Get(id) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting value.", ex);
            }
        }

        public IEnumerable<AbstractAutorElement> GetByAuthorId(int id)
        {
            try
            {
                return _dao.GetByAuthorId(id) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting value.", ex);
            }
        }

        public IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest)
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

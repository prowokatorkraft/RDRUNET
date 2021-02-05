using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;

namespace Epam.Library.Dal.Memory
{
    public class CatalogueDao : ICatalogueDao
    {
        private readonly HashSet<LibraryAbstractElement> _data;

        private readonly IAuthorDao _authorDao;

        public CatalogueDao(HashSet<LibraryAbstractElement> data, IAuthorDao authorDao)
        {
            _data = data;
            _authorDao = authorDao;
        }

        public LibraryAbstractElement Get(int id)
        {
            try
            {
                return _data.First(a => a.Id.Value.Equals(id));
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest)
        {
            try
            {
                var query = _data.AsQueryable();

                if (searchRequest != null)
                {
                    query = DetermineSearchQuery(searchRequest, query);

                    query = DetermineSortQuery(searchRequest, query);
                }

                return query;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private IQueryable<LibraryAbstractElement> DetermineSortQuery(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, IQueryable<LibraryAbstractElement> query)
        {
            switch (searchRequest.SortOptions)
            {
                case SortOptions.Ascending:

                    query = query.OrderBy(s => s.Name);

                    break;

                case SortOptions.Descending:

                    query = query.OrderByDescending(s => s.Name);

                    break;

                default:
                    break;
            }

            return query;
        }

        private IQueryable<LibraryAbstractElement> DetermineSearchQuery(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, IQueryable<LibraryAbstractElement> query)
        {
            query = query.Where(a => DetermineLineForRequest(a, searchRequest).ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));
            
            return query;
        }

        private string DetermineLineForRequest(LibraryAbstractElement element, SearchRequest<SortOptions, CatalogueSearchOptions> request)
        {
            StringBuilder builder = new StringBuilder();

            if (request.SearchOptions.HasFlag(CatalogueSearchOptions.Name))
            {
                builder.Append(element.Name + " ");
            }

            if (request.SearchOptions.HasFlag(CatalogueSearchOptions.Author))
            {
                var autorElement = element as AbstractAutorElement;

                if (autorElement != null && autorElement.AuthorIDs != null)
                {
                    foreach (var id in autorElement.AuthorIDs)
                    {
                        var author = _authorDao.Get(id);

                        builder.Append(author.FirstName + " " + author.LastName + " "); ;
                    }
                }
            }

            return builder.ToString();
        }
    }
}

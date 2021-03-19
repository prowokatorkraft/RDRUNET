﻿using Epam.Library.Common.Entities;
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

        private int _idCount = 0;

        public CatalogueDao(IAuthorDao authorDao)
        {
            _data = new HashSet<LibraryAbstractElement>();
            _authorDao = authorDao;
        }

        public void Add(LibraryAbstractElement element)
        {
            try
            {
                element.Id = _idCount++;

                _data.Add(element);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public bool Remove(int id)
        {
            try
            {
                return _data.Remove(_data.First(a => a.Id.Value.Equals(id)));
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing data.", ex);
            }
        }

        public IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, PagingInfo page = null)
        {
            try
            {
                return _data.OfType<AbstractAuthorElement>()
                    .Where(e => e.AuthorIDs?.Any(i => i.Equals(id)) ?? false);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public LibraryAbstractElement Get(int id)
        {
            try
            {
                return _data.FirstOrDefault(a => a.Id.Value.Equals(id));
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
            switch (searchRequest.SearchOptions)
            {
                case CatalogueSearchOptions.Name:
                    query = query.Where(e => e.Name.ToLower().Contains(searchRequest.SearchLine.ToLower()));
                    break;

                default:
                    break;
            }

            return query;
        }
    }
}

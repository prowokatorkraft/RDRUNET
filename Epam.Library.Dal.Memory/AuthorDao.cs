using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Linq;
using System.Collections.Generic;

namespace Epam.Library.Dal.Memory
{
    public class AuthorDao : IAuthorDao
    {
        private readonly HashSet<Author> _data;

        private int _idCount = 0;

        public AuthorDao()
        {
            _data = new HashSet<Author>();
        }

        public void Add(Author author)
        {
            try
            {
                author.Id = _idCount++;

                _data.Add(author);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public Author Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _data.FirstOrDefault(a => a.Id.Value.Equals(id))?.Clone() as Author;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool Check(int[] ids, RoleType role = RoleType.None)
        {
            try
            {
                List<bool> list = new List<bool>();

                foreach (var id in ids)
                {
                    list.Add(_data.Any(a => a.Id.Value.Equals(id)));
                }

                return list.All(s => s);
            }
            catch (Exception ex)
            {
                throw new GetException("Error checking data.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
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

        public IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, RoleType role = RoleType.None)
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

        private IQueryable<Author> DetermineSortQuery(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, IQueryable<Author> query)
        {
            switch (searchRequest.SortOptions)
            {
                case SortOptions.Ascending:

                    query = query.OrderBy(s => s.FirstName).ThenBy(s => s.LastName);

                    break;

                case SortOptions.Descending:

                    query = query.OrderByDescending(s => s.FirstName).ThenByDescending(s => s.LastName);

                    break;

                default:
                    break;
            }

            return query;
        }

        private IQueryable<Author> DetermineSearchQuery(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, IQueryable<Author> query)
        {
            switch (searchRequest.SearchOptions)
            {
                case AuthorSearchOptions.FirstName:
                    query = query.Where(a => a.FirstName.ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));
                    break;

                case AuthorSearchOptions.LastName:
                    query = query.Where(a => a.LastName.ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));
                    break;

                default:
                    break;
            }

            return query;
        }

        public void Update(Author autor)
        {
            throw new NotImplementedException();
        }
    }
}

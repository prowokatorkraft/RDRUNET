using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using Epam.Library.Dal.Contracts;
using System;
using System.Linq;
using System.Collections.Generic;

namespace Epam.Library.Dal.Memory
{
    public class AuthorDao : IAuthorDao
    {
        private readonly HashSet<Author> _data;

        public AuthorDao(HashSet<Author> data)
        {
            this._data = data;
        }

        public void Add(Author author)
        {
            try
            {
                author.Id = author.GetHashCode();

                _data.Add(author);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }

        }

        public Author Get(int id)
        {
            try
            {
                return _data.First(a => a.Id.Value.Equals(id)); ////
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool[] Check(int[] ids)
        {
            try
            {
                List<bool> list = new List<bool>();

                foreach (var id in ids)
                {
                    list.Add(_data.Any(a => a.Id.Value.Equals(id)));
                }

                return list.ToArray();
            }
            catch (Exception ex)
            {
                throw new GetException("Error checking data.", ex);
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

        public IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest)
        {
            try
            {
                var query = _data.AsQueryable();

                switch (searchRequest.SearchOptions)
                {
                    case AuthorSearchOptions.FirstName | AuthorSearchOptions.LastName:

                        query = query.Where(a => (a.FirstName + " " + a.LastName).ToLower()
                            .Contains(searchRequest.SearchLine.ToLower()));

                        break;

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

                switch (searchRequest.SortOptions)
                {
                    case SortOptions.Ascending:

                        query = query.OrderBy(s => s.ToString());

                        break;

                    case SortOptions.Descending:

                        query = query.OrderByDescending(s => s.ToString());

                        break;

                    default:
                        break;
                }

                return query;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }
    }
}

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using Epam.Library.Common.Entities.AuthorElement.Patent;

namespace Epam.Library.Dal.Memory
{
    public class PatentDao : IPatentDao
    {
        private readonly HashSet<LibraryAbstractElement> _data;

        private readonly IAuthorDao _authorDao;

        public PatentDao(HashSet<LibraryAbstractElement> data, IAuthorDao authorDao)
        {
            _data = data;
            _authorDao = authorDao;
        }

        public void Add(AbstractPatent patent)
        {
            try
            {
                patent.Id = patent.GetHashCode();

                _data.Add(patent);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractPatent Get(int id)
        {
            try
            {
                return _data.First(a => a.Id.Value.Equals(id)) as AbstractPatent
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<IGrouping<int, AbstractPatent>> GetAllGroupsByPublishYear()
        {
            try
            {
                return _data.OfType<AbstractPatent>().GroupBy(b => b.DateOfPublication.Year);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
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

        public IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest)
        {
            try
            {
                var query = _data.OfType<AbstractPatent>().AsQueryable();

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

        private IQueryable<AbstractPatent> DetermineSortQuery(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, IQueryable<AbstractPatent> query)
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

        private IQueryable<AbstractPatent> DetermineSearchQuery(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, IQueryable<AbstractPatent> query)
        {
            query = query.Where(a => DetermineLineForRequest(a, searchRequest).ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));

            return query;
        }

        private string DetermineLineForRequest(AbstractPatent patent, SearchRequest<SortOptions, PatentSearchOptions> request)
        {
            StringBuilder builder = new StringBuilder();

            if (request.SearchOptions.HasFlag(PatentSearchOptions.Name))
            {
                builder.Append(patent.Name + " ");
            }

            if (request.SearchOptions.HasFlag(PatentSearchOptions.Author))
            {
                if (patent.AuthorIDs != null)
                {
                    foreach (var id in patent.AuthorIDs)
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

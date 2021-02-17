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
        private readonly ICatalogueDao _catalogue;

        public PatentDao(ICatalogueDao catalogue)
        {
            _catalogue = catalogue;
        }

        public void Add(AbstractPatent patent)
        {
            try
            {
                _catalogue.Add(patent);
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
                return _catalogue.Get(id)?.Clone() as AbstractPatent
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<AbstractPatent> GetByAuthorId(int id)
        {
            try
            {
                return _catalogue.GetByAuthorId(id).OfType<AbstractPatent>();
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear()
        {
            try
            {
                Dictionary<int, List<AbstractPatent>> groups = new Dictionary<int, List<AbstractPatent>>();

                foreach (var item in Search(null).GroupBy(b => b.DateOfPublication.Year))
                {
                    groups.Add(item.Key, item.ToList());
                }

                return groups;
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
                return _catalogue.Remove(id);
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
                var query = _catalogue.Search(null).OfType<AbstractPatent>().AsQueryable();

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
            switch (searchRequest.SearchOptions)
            {
                case PatentSearchOptions.Name:
                    query = query.Where(a => a.Name.ToLower()
                        .Contains(searchRequest.SearchLine.ToLower() ?? ""));
                    break;

                default:
                    break;
            }

            return query;
        }
    }
}

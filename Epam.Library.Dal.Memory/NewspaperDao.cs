using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Dal.Memory
{
    public class NewspaperDao : INewspaperDao
    {
        private readonly ICatalogueDao _catalogue;

        public NewspaperDao(ICatalogueDao catalogue)
        {
            _catalogue = catalogue;
        }

        public void Add(AbstractNewspaper newspaper)
        {
            try
            {
                _catalogue.Add(newspaper);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractNewspaper Get(int id)
        {
            try
            {
                return _catalogue.Get(id)?.Clone() as AbstractNewspaper
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractNewspaper>> GetAllGroupsByPublishYear()
        {
            try
            {
                Dictionary<int, List<AbstractNewspaper>> groups = new Dictionary<int, List<AbstractNewspaper>>();

                foreach (var item in Search(null).GroupBy(b => b.PublishingYear))
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

        public IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
        {
            try
            {
                var query = _catalogue.Search(null).OfType<AbstractNewspaper>().AsQueryable();

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

        private IQueryable<AbstractNewspaper> DetermineSortQuery(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, IQueryable<AbstractNewspaper> query)
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

        private IQueryable<AbstractNewspaper> DetermineSearchQuery(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, IQueryable<AbstractNewspaper> query)
        {
            switch (searchRequest.SearchOptions)
            {
                case NewspaperSearchOptions.Name:
                    query = query.Where(a => a.Name.ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));
                    break;

                default:
                    break;
            }

            return query;
        }

        private string DetermineLineForRequest(AbstractNewspaper newspaper, SearchRequest<SortOptions, NewspaperSearchOptions> request)
        {
            StringBuilder builder = new StringBuilder();

            if (request.SearchOptions.HasFlag(NewspaperSearchOptions.Name))
            {
                builder.Append(newspaper.Name + " ");
            }
            
            return builder.ToString();
        }
    }
}

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
        private readonly HashSet<LibraryAbstractElement> _data;

        public NewspaperDao(HashSet<LibraryAbstractElement> data)
        {
            _data = data;
        }

        public void Add(AbstractNewspaper newspaper)
        {
            try
            {
                newspaper.Id = newspaper.GetHashCode();

                _data.Add(newspaper);
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
                return _data.First(a => a.Id.Value.Equals(id)) as AbstractNewspaper
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllGroupsByPublishYear()
        {
            try
            {
                return _data.OfType<AbstractNewspaper>().GroupBy(b => b.PublishingYear);
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

        public IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
        {
            try
            {
                var query = _data.OfType<AbstractNewspaper>().AsQueryable();

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
            query = query.Where(a => DetermineLineForRequest(a, searchRequest).ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));

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

using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using Epam.Library.Common.Entities.AuthorElement.Book;

namespace Epam.Library.Dal.Memory
{
    public class BookDao : IBookDao
    {
        private readonly ICatalogueDao _catalogue;

        public BookDao(ICatalogueDao catalogue)
        {
            _catalogue = catalogue;
        }

        public void Add(AbstractBook book)
        {
            try
            {
                _catalogue.Add(book);
            }
            catch (Exception ex)
            {
                throw new LayerException("Dao", nameof(BookDao), nameof(Add), "Error adding data.", ex);
            }
        }

        public AbstractBook Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _catalogue.Get(id)?.Clone() as AbstractBook
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(Get), "Error getting data.", ex);
            }
        }

        public IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page, RoleType role = RoleType.None)
        {
            try
            {
                return _catalogue.GetByAuthorId(id).OfType<AbstractBook>();
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(GetByAuthorId), "Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                Dictionary<int, List<AbstractBook>> groups = new Dictionary<int, List<AbstractBook>>();

                foreach (var item in Search(null).GroupBy(b => b.PublishingYear))
                {
                    groups.Add(item.Key, item.ToList());
                }

                return groups;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(GetAllGroupsByPublishYear), "Error getting data.", ex);
            }
        }

        public Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                Dictionary<string, List<AbstractBook>> groups = new Dictionary<string, List<AbstractBook>>();

                var temp = Search(searchRequest)
                    .GroupBy(b => b.Publisher);

                foreach (var item in temp)
                {
                    groups.Add(item.Key, item.ToList());
                }

                return groups;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(GetAllGroupsByPublisher), "Error getting data.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _catalogue.Remove(id);
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(Remove), "Error removing data.", ex);
            }
        }

        public IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                var query = _catalogue.Search(null).OfType<AbstractBook>().AsQueryable();

                if (searchRequest != null)
                {
                    query = DetermineSearchQuery(searchRequest, query);

                    query = DetermineSortQuery(searchRequest, query);
                }

                return query;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(BookDao), nameof(Search), "Error getting data.", ex);
            }
        }

        private IQueryable<AbstractBook> DetermineSortQuery(SearchRequest<SortOptions, BookSearchOptions> searchRequest, IQueryable<AbstractBook> query)
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

        private IQueryable<AbstractBook> DetermineSearchQuery(SearchRequest<SortOptions, BookSearchOptions> searchRequest, IQueryable<AbstractBook> query)
        {
            switch (searchRequest.SearchOptions)
            {
                case BookSearchOptions.Name:
                    query = query.Where(a => a.Name.ToLower()
                        .Contains(searchRequest.SearchLine == null ? searchRequest.SearchLine.ToLower() : ""));
                    break;

                case BookSearchOptions.Publisher:
                    query = query.Where(a => a.Publisher.ToLower()
                        .Contains(searchRequest.SearchLine == null ? searchRequest.SearchLine.ToLower() : ""));
                    break;

                default:
                    break;
            }

            return query;
        }

        public void Update(AbstractBook book)
        {
            throw new NotImplementedException();
        }
    }
}

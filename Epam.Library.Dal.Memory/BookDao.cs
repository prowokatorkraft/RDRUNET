using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.SearchOptionsEnum;
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
        private readonly HashSet<LibraryAbstractElement> _data;

        private readonly IAuthorDao _authorDao;

        public BookDao(HashSet<LibraryAbstractElement> data, IAuthorDao authorDao)
        {
            _data = data;
            _authorDao = authorDao;
        }

        public void Add(AbstractBook book)
        {
            try
            {
                book.Id = book.GetHashCode();

                _data.Add(book);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractBook Get(int id)
        {
            try
            {
                return _data.First(a => a.Id.Value.Equals(id)) as AbstractBook
                    ?? throw new ArgumentOutOfRangeException("Incorrect id");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<IGrouping<int, AbstractBook>> GetAllGroupsByPublishYear()
        {
            try
            {
                return _data.OfType<AbstractBook>().GroupBy(b => b.PublishingYear);
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

        public IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            try
            {
                var query = _data.OfType<AbstractBook>().AsQueryable();

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
            query = query.Where(a => DetermineLineForRequest(a, searchRequest).ToLower()
                        .Contains(searchRequest.SearchLine.ToLower()));

            return query;
        }

        private string DetermineLineForRequest(AbstractBook book, SearchRequest<SortOptions, BookSearchOptions> request)
        {
            StringBuilder builder = new StringBuilder();

            if (request.SearchOptions.HasFlag(BookSearchOptions.Name))
            {
                builder.Append(book.Name + " ");
            }

            if (request.SearchOptions.HasFlag(BookSearchOptions.Author))
            {
                if (book.AuthorIDs != null)
                {
                    foreach (var id in book.AuthorIDs)
                    {
                        var author = _authorDao.Get(id);

                        builder.Append(author.FirstName + " " + author.LastName + " "); ;
                    }
                }
            }

            if (request.SearchOptions.HasFlag(BookSearchOptions.Publisher))
            {
                builder.Append(book.Publisher + " ");
            }

            return builder.ToString();
        }
    }
}

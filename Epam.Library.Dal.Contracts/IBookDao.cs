using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;

namespace Epam.Library.Dal.Contracts
{
    public interface IBookDao
    {
        void Add(AbstractBook book);

        void Update(AbstractBook book);

        bool Remove(int id);

        AbstractBook Get(int id);

        IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page = null);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest);

        Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(PagingInfo page = null);

        Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest);
    }
}

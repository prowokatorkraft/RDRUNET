using System.Collections.Generic;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;

namespace Epam.Library.Dal.Contracts
{
    public interface IBookDao
    {
        void Add(AbstractBook book);

        void Update(AbstractBook book);

        bool Remove(int id, RoleType role = RoleType.None);

        AbstractBook Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}

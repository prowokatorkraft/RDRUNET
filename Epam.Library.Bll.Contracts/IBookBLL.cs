using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBll
    {
        IEnumerable<ErrorValidation> Add(AbstractBook book, RoleType role = RoleType.None);

        IEnumerable<ErrorValidation> Update(AbstractBook book, RoleType role = RoleType.None);

        bool Remove(int id, RoleType role = RoleType.None);

        AbstractBook Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}
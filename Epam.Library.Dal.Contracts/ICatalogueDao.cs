using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface ICatalogueDao
    {
        void Add(LibraryAbstractElement element);

        bool Remove(int id, RoleType role = RoleType.None);

        LibraryAbstractElement Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, PagingInfo page = null, RoleType role = RoleType.None);

        IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, RoleType role = RoleType.None);

        int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null, RoleType role = RoleType.None);
    }
}

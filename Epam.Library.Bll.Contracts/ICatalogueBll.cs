using Epam.Common.Entities;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface ICatalogueBll
    {
        LibraryAbstractElement Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, RoleType role = RoleType.None);

        IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, RoleType role = RoleType.None);

        int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null, RoleType role = RoleType.None);
    }
}

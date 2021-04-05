using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface ICatalogueDao
    {
        void Add(LibraryAbstractElement element);

        bool Remove(int id);

        LibraryAbstractElement Get(int id);

        IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, PagingInfo page = null);

        IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest);

        int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null);
    }
}

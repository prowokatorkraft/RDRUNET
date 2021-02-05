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

        IEnumerable<AbstractAutorElement> GetByAuthorId(int id);

        IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest);
    }
}

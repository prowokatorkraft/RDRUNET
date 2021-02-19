using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface ICatalogueBll
    {
        LibraryAbstractElement Get(int id);

        IEnumerable<AbstractAuthorElement> GetByAuthorId(int id);

        IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest);
    }
}

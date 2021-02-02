using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface ICatalogueBll
    {
        IEnumerable<LibraryAbstractElement> SearchElements(SortOptions options, CatalogueSearchOptions searchOptions, string search);
    }
}

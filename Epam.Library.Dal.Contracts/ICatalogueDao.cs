using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface ICatalogueDao
    {
        IEnumerable<LibraryAbstractElement> SearchElements(SortOptions options, CatalogueSearchOptions searchOptions, string search);
    }
}

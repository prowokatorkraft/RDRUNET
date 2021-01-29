﻿using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface ICatalogueDao
    {
        IEnumerable<LibraryAbstractElement> GetAllElements(SortOptions options, CatalogueSearchOptions searchOptions, string search);
    }
}

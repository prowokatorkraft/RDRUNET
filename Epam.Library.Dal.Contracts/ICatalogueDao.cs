using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface ICatalogueDao
    {
        IEnumerable<AbstractElement> GetAllElements();

        IEnumerable<AbstractElement> GetAllElements(SortOptions options);

        IEnumerable<AbstractElement> GetElementsByName(string name);

        IEnumerable<AbstractAutorsElement> GetElementsByAutors(Autor[] autors);
    }
}

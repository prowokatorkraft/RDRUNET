using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface ICatalogueBll
    {
        IEnumerable<AbstractElement> GetAllElements();

        IEnumerable<AbstractElement> GetElementsByName(string name);

        IEnumerable<AbstractAutorsElement> GetElementsByAutors(Autor[] autors);
    }
}

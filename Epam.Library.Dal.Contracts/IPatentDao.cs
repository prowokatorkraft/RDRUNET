using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;

namespace Epam.Library.DaL.Contracts
{
    public interface IPatentDao
    {
        int AddPatent(AbstractPatent patent);

        int RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> GetAllPatents();

        IEnumerable<AbstractPatent> GetAllPatents(SortOptions options);

        ILookup<int, AbstractPatent> GetAllPatentGroupsByPublishYear();

        IEnumerable<AbstractPatent> GetPatentsByName(string name);

        IEnumerable<AbstractPatent> GetPatentsByAutors(Autor[] autors);
    }
}

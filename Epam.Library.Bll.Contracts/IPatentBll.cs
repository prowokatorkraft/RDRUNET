using System.Collections.Generic;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        int AddPatent(AbstractPatent patent);

        int RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> GetAllPatents();

        IEnumerable<AbstractPatent> GetPatentsByName(string name);

        IEnumerable<AbstractPatent> GetPatentsByAutors(Autor[] autors);
    }
}

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        void AddPatent(AbstractPatent patent);

        void RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search);

        ILookup<int, AbstractPatent> GetAllPatentGroupsByPublishYear();
    }
}

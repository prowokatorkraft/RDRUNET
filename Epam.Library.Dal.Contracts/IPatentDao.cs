using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;

namespace Epam.Library.Dal.Contracts
{
    public interface IPatentDao
    {
        void AddPatent(AbstractPatent patent);

        void RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search);

        ILookup<int, AbstractPatent> GetAllPatentGroupsByPublishYear();
    }
}

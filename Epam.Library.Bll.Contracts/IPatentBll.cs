using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        void AddPatent(AbstractPatent patent);

        void RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractPatent>> GetAllPatentGroupsByPublishYear();
    }
}

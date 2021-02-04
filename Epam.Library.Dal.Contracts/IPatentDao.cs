using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;

namespace Epam.Library.Dal.Contracts
{
    public interface IPatentDao
    {
        void Add(AbstractPatent patent);

        bool Remove(int id);

        AbstractPatent Get(int id);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractPatent>> GetAllGroupsByPublishYear();
    }
}

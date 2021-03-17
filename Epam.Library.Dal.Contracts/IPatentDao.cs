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

        IEnumerable<AbstractPatent> GetByAuthorId(int id, PagingInfo page = null);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest);

        Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear(PagingInfo page = null);
    }
}

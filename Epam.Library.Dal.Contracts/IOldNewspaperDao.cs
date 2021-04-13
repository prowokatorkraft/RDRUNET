using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Dal.Contracts
{
    public interface IOldNewspaperDao
    {
        void Add(AbstractOldNewspaper newspaper);

        bool Remove(int id);

        void Update(AbstractOldNewspaper newspaper);

        AbstractOldNewspaper Get(int id);

        IEnumerable<AbstractOldNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        Dictionary<int, List<AbstractOldNewspaper>> GetAllGroupsByPublishYear(PagingInfo page = null);
    }
}

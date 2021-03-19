using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Dal.Contracts
{
    public interface INewspaperDao
    {
        void Add(AbstractNewspaper newspaper);

        bool Remove(int id);

        void Update(AbstractNewspaper newspaper);

        AbstractNewspaper Get(int id);

        IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        Dictionary<int, List<AbstractNewspaper>> GetAllGroupsByPublishYear(PagingInfo page = null);
    }
}

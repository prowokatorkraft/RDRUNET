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

        AbstractNewspaper Get(int id);

        IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllGroupsByPublishYear();
    }
}

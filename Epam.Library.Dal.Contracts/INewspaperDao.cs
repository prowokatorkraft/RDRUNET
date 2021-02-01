using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Dal.Contracts
{
    public interface INewspaperDao
    {
        void AddNewspaper(AbstractNewspaper newspaper);

        void RemoveNewspaper(AbstractNewspaper newspaper);

        IEnumerable<AbstractNewspaper> SearchNewspapers(SortOptions sortOptions, BookSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllNewspaperGroupsByPublishYear();
    }
}

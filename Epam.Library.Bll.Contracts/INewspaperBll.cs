using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperBll
    {
        void AddNewspaper(AbstractNewspaper newspaper);

        void RemoveNewspaper(AbstractNewspaper newspaper);

        IEnumerable<AbstractNewspaper> SearchNewspapers(SortOptions sortOptions, BookSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllNewspaperGroupsByPublishYear();
    }
}

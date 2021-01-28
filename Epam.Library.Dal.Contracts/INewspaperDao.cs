using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Dal.Contracts
{
    public interface INewspaperDao
    {
        int AddNewspaper(AbstractNewspaper newspaper);

        int RemoveNewspaper(AbstractNewspaper newspaper);

        IEnumerable<AbstractNewspaper> GetAllNewspapers();

        IEnumerable<AbstractNewspaper> GetAllNewspapers(SortOptions options);

        ILookup<int, AbstractNewspaper> GetAllNewspaperGroupsByPublishYear();

        IEnumerable<AbstractNewspaper> GetNewspapersByName(string name);
    }
}

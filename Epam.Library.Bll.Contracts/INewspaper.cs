using System.Collections.Generic;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaper
    {
        int AddNewspaper(AbstractNewspaper newspaper);

        int RemoveNewspaper(AbstractNewspaper newspaper);

        IEnumerable<AbstractNewspaper> GetAllNewspapers();

        IEnumerable<AbstractNewspaper> GetNewspapersByName(string name);
    }
}

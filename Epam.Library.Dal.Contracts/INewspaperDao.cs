using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface INewspaperDao
    {
        void Add(Newspaper newspaper);

        bool Remove(int id, RoleType role = RoleType.None);

        void Update(Newspaper newspaper);

        Newspaper Get(int id, RoleType role = RoleType.None);

        IEnumerable<Newspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}

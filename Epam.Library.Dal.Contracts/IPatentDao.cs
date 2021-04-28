using System.Collections.Generic;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;

namespace Epam.Library.Dal.Contracts
{
    public interface IPatentDao
    {
        void Add(AbstractPatent patent);

        bool Remove(int id, RoleType role = RoleType.None);

        void Update(AbstractPatent patent);

        AbstractPatent Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractPatent> GetByAuthorId(int id, PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, RoleType role = RoleType.None);

        int GetCount(PatentSearchOptions searchOptions = PatentSearchOptions.None, string searchLine = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);

        Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear(PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None);
    }
}

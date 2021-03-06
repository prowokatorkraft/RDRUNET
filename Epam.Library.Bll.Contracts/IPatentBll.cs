using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        IEnumerable<ErrorValidation> Add(AbstractPatent patent, RoleType role = RoleType.None);

        IEnumerable<ErrorValidation> Update(AbstractPatent patent, RoleType role = RoleType.None);

        bool Remove(int id, RoleType role = RoleType.None);

        AbstractPatent Get(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractPatent> GetByAuthorId(int id, RoleType role = RoleType.None);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear(RoleType role = RoleType.None);
    }
}

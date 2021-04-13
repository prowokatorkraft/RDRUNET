using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperIssueBll
    {
        IEnumerable<ErrorValidation> Add(NewspaperIssue issue);

        bool Remove(int id, RoleType role = RoleType.None);

        IEnumerable<ErrorValidation> Update(NewspaperIssue issue);

        NewspaperIssue Get(int id, RoleType role = RoleType.None);

        NewspaperIssue GetAllByNewspaper(int newspaperId, RoleType role = RoleType.None);

        IEnumerable<AbstractOldNewspaper> Search(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<AbstractOldNewspaper>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None);
    }
}

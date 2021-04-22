using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperIssueBll
    {
        IEnumerable<ErrorValidation> Add(NewspaperIssue issue, RoleType role = RoleType.None);

        bool Remove(int id, RoleType role = RoleType.None);

        IEnumerable<ErrorValidation> Update(NewspaperIssue issue, RoleType role = RoleType.None);

        NewspaperIssue Get(int id, RoleType role = RoleType.None);

        IEnumerable<NewspaperIssue> GetAllByNewspaper(int newspaperId, PagingInfo paging = null, SortOptions sort = SortOptions.None, RoleType role = RoleType.None);

        int GetCountByNewspaper(int newspaperId, RoleType role = RoleType.None);

        IEnumerable<NewspaperIssue> Search(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<NewspaperIssue>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None);
    }
}

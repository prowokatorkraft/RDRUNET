using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface INewspaperIssueDao
    {
        void Add(NewspaperIssue issue);

        bool Remove(int id, RoleType role = RoleType.None);

        void Update(NewspaperIssue issue);

        NewspaperIssue Get(int id, RoleType role = RoleType.None);

        IEnumerable<NewspaperIssue> GetAllByNewspaper(int newspaperId, RoleType role = RoleType.None);

        IEnumerable<NewspaperIssue> Search(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, RoleType role = RoleType.None);

        Dictionary<int, List<NewspaperIssue>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None);
    }
}

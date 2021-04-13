using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperBll
    {
        IEnumerable<ErrorValidation> Add(Newspaper newspaper);

        bool Remove(int id, RoleType role = RoleType.None);

        IEnumerable<ErrorValidation> Update(Newspaper newspaper);

        Newspaper Get(int id, RoleType role = RoleType.None);

        IEnumerable<Newspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}

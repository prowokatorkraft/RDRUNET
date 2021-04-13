using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IOldNewspaperBll
    {
        IEnumerable<ErrorValidation> Add(AbstractOldNewspaper newspaper);

        IEnumerable<ErrorValidation> Update(AbstractOldNewspaper newspaper);

        bool Remove(int id);

        AbstractOldNewspaper Get(int id);

        IEnumerable<AbstractOldNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        Dictionary<int, List<AbstractOldNewspaper>> GetAllGroupsByPublishYear();
    }
}

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperBll
    {
        IEnumerable<ErrorValidation> Add(AbstractNewspaper newspaper);

        IEnumerable<ErrorValidation> Update(AbstractNewspaper newspaper);

        bool Remove(int id);

        AbstractNewspaper Get(int id);

        IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        Dictionary<int, List<AbstractNewspaper>> GetAllGroupsByPublishYear();
    }
}

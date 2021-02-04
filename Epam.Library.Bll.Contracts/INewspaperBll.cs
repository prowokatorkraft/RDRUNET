using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface INewspaperBll
    {
        ErrorValidation[] Add(AbstractNewspaper newspaper);

        bool Remove(int id);

        AbstractNewspaper Get(int id);

        IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractNewspaper>> GetAllGroupsByPublishYear();
    }
}

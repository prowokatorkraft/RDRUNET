using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        ErrorValidation[] Add(AbstractPatent patent);

        bool Remove(int id);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractPatent>> GetAllGroupsByPublishYear();
    }
}

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IPatentBll
    {
        IEnumerable<ErrorValidation> Add(AbstractPatent patent);

        bool Remove(int id);

        AbstractPatent Get(int id);

        IEnumerable<AbstractPatent> GetByAuthorId(int id);

        IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest);

        Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear();
    }
}

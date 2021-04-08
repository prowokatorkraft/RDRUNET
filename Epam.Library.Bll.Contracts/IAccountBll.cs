using Epam.Common.Entities;
using Epam.Common.Entities.SearchOptionsEnum;
using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IAccountBll
    {
        IEnumerable<ErrorValidation> Add(Account account);

        bool UpdateRole(long accountId, int roleId);

        bool Remove(long id);

        IEnumerable<Account> Search(SearchRequest<SortOptions, AccountSearchOptions> searchRequest);

        Account GetById(long id);

        Account GetByLogin(string login);

        bool Check(long id);
        bool Check(string login);
    }
}

using Epam.Common.Entities;
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

        int GetCount(AccountSearchOptions searchOptions = AccountSearchOptions.None, string searchLine = null);

        Account GetById(long id);

        Account GetByLogin(string login);

        bool Check(long id);
        bool Check(string login);
    }
}

using Epam.Common.Entities;
using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface IAccountDao
    {
        void Add(Account account);

        void UpdateRole(long accountId, int roleId);

        bool Remove(long id);

        IEnumerable<Account> Search(SearchRequest<SortOptions, AccountSearchOptions> searchRequest);
        int GetCount(AccountSearchOptions searchOptions = AccountSearchOptions.None, string searchLine = null);

        Account GetById(long id);
        Account GetByLogin(string login);

        bool Check(long id);
        bool Check(string login);
    }
}

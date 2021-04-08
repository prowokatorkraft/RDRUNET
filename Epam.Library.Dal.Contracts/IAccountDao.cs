using Epam.Common.Entities;
using Epam.Common.Entities.SearchOptionsEnum;
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

        Account GetById(long id);
        Account GetByLogin(string login);

        bool Check(long id);
        bool Check(string login);
    }
}

using Epam.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface IAccountDao
    {
        void Add(Account account);

        void Update(Account account);

        bool Remove(long id);

        IEnumerable<Account> GetAll();

        Account GetById(long id);

        Account GetByLogin(string login);

        bool IsExists(string login);
    }
}

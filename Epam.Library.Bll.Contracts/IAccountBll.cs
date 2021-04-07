using Epam.Common.Entities;
using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IAccountBll
    {
        IEnumerable<ErrorValidation> Add(Account account);

        IEnumerable<ErrorValidation> Update(Account account);

        bool Remove(long id);

        IEnumerable<Account> GetAll();

        Account GetById(long id);

        Account GetByLogin(string login);

        bool IsExists(string login);
    }
}

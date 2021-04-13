using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface IRoleDao
    {
        IEnumerable<Role> GetAll();

        Role GetById(int id);

        Role GetByName(string name);
    }
}

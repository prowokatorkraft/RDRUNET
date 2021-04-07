using Epam.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IRoleBll
    {
        IEnumerable<Role> GetAll();

        Role GetById(long id);

        Role GetByName(string name);
    }
}

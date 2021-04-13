using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IRoleBll
    {
        IEnumerable<Role> GetAll();

        Role GetById(int id);

        Role GetByName(string name);

        bool Check(int id);
    }
}

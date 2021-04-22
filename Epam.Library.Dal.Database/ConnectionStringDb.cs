using Epam.Library.Common.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Library.Dal.Database
{
    public class ConnectionStringDb
    {
        private Dictionary<RoleType, string> _identityConnectionStrings;

        public ConnectionStringDb(Dictionary<RoleType, string> identityConnectionStrings)
        {
            _identityConnectionStrings = identityConnectionStrings;
        }

        public string GetByRole(RoleType role)
        {
            if (role == RoleType.None)
            {
                return _identityConnectionStrings[RoleType.user];
            }

            return _identityConnectionStrings[role];
        }
    }
}

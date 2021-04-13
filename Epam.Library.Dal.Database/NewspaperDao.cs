using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Library.Dal.Database
{
    public class NewspaperDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        public NewspaperDao(ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
        }
    }
}

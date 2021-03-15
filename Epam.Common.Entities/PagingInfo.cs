using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Library.Common.Entities
{
    public class PagingInfo
    {
        public static PagingInfo Default { get; } = new PagingInfo(10000, 1);

        public int SizePage { get; set; }

        public int Page { get; set; }

        public PagingInfo()
        {
        }

        public PagingInfo(int sizePage, int page)
        {
            SizePage = sizePage;
            Page = page;
        }
    }
}

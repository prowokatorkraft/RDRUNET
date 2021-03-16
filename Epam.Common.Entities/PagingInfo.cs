using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Library.Common.Entities
{
    public class PagingInfo
    {
        public int SizePage { get; set; } = 10000;

        public int PageNumber { get; set; } = 1;

        public PagingInfo()
        {
        }

        public PagingInfo(int sizePage, int page)
        {
            SizePage = sizePage;
            PageNumber = page;
        }
    }
}

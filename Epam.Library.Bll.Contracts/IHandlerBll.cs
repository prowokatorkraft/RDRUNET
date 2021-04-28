using Epam.Library.Common.Entities.ApiQuery;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IHandlerBll<TElement>
    {
        int GetPageCount(Request request);
        
        IEnumerable<TElement> Search(Request request);
    }
}

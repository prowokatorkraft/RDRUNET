using Epam.Library.Common.Entities.ApiQuery;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IPageHandlerBll<TElement, TRequest> : IHandlerBll<TElement, TRequest>
    {
        int GetPageCount(TRequest request);
    }
}

using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class CatalogueHandler : IHandlerBll<LibraryAbstractElement>
    {
        private ICatalogueBll _catalogueBll;
        public CatalogueHandler(ICatalogueBll catalogueBll)
        {
            _catalogueBll = catalogueBll;
        }

        public int GetPageCount(Request request)
        {
            NumberOfPageFilter filter = new NumberOfPageFilter()
            {
                MinNumberOfPages = request.MinNumberOfPages,
                MaxNumberOfPages = request.MaxNumberOfPages
            };
            int count = _catalogueBll.GetCount(searchOptions: GetSearchOption(request.SearchOption), searchLine: request.SearchLine, numberOfPageFilter: filter, role: RoleType.externalClient);

            return (int)Math.Ceiling(a: count / (double)request.SizePage);
        }
        public IEnumerable<LibraryAbstractElement> Search(Request request)
        {
            var searchRequest = GetSearchRequest(request);

            return _catalogueBll.Search(searchRequest, RoleType.externalClient);
        }

        private CatalogueSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "Name":
                    return CatalogueSearchOptions.Name;
                default:
                    return CatalogueSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, CatalogueSearchOptions> GetSearchRequest(Request request)
        {
            return new SearchRequest<SortOptions, CatalogueSearchOptions>()
            {
                SortOptions = request.IsDescending ? SortOptions.Descending : SortOptions.Ascending,
                SearchOptions = GetSearchOption(request.SearchOption),
                SearchLine = request.SearchLine,
                NumberOfPageFilter = new NumberOfPageFilter()
                {
                    MinNumberOfPages = request.MinNumberOfPages,
                    MaxNumberOfPages = request.MaxNumberOfPages
                },
                PagingInfo = new PagingInfo(request.SizePage, request.CurrentPage)
            };
        }
    }
}

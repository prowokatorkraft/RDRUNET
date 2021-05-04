using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class PatentHandler : IPageHandlerBll<AbstractPatent, PageRequest>
    {
        private IPatentBll _patentBll;
        public PatentHandler(IPatentBll patentBll)
        {
            _patentBll = patentBll;
        }

        public int GetPageCount(PageRequest request)
        {
            NumberOfPageFilter filter = new NumberOfPageFilter()
            {
                MinNumberOfPages = request.MinNumberOfPages,
                MaxNumberOfPages = request.MaxNumberOfPages
            };
            int count = _patentBll.GetCount(searchOptions: GetSearchOption(request.SearchOption), searchLine: request.SearchLine, numberOfPageFilter: filter, role: RoleType.externalClient);

            return (int)Math.Ceiling(a: count / (double)request.SizePage);
        }

        public IEnumerable<AbstractPatent> Search(PageRequest request)
        {
            var searchRequest = GetSearchRequest(request);

            return _patentBll.Search(searchRequest, RoleType.externalClient);
        }

        private PatentSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "Name":
                    return PatentSearchOptions.Name;
                default:
                    return PatentSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, PatentSearchOptions> GetSearchRequest(PageRequest request)
        {
            return new SearchRequest<SortOptions, PatentSearchOptions>()
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

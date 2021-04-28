using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.Newspaper;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class NewspaperIssueHandler : IHandlerBll<NewspaperIssue>
    {
        private INewspaperIssueBll _newspaperIssueBll;
        public NewspaperIssueHandler(INewspaperIssueBll newspaperIssueBll)
        {
            _newspaperIssueBll = newspaperIssueBll;
        }

        public int GetPageCount(Request request)
        {
            NumberOfPageFilter filter = new NumberOfPageFilter()
            {
                MinNumberOfPages = request.MinNumberOfPages,
                MaxNumberOfPages = request.MaxNumberOfPages
            };
            int count = _newspaperIssueBll.GetCount(searchOptions: GetSearchOption(request.SearchOption), searchLine: request.SearchLine, numberOfPageFilter: filter, role: RoleType.externalClient);

            return (int)Math.Ceiling(a: count / (double)request.SizePage);
        }
        public IEnumerable<NewspaperIssue> Search(Request request)
        {
            var searchRequest = GetSearchRequest(request);

            return _newspaperIssueBll.Search(searchRequest, RoleType.externalClient);
        }

        private NewspaperIssueSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "Name":
                    return NewspaperIssueSearchOptions.Name;
                default:
                    return NewspaperIssueSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, NewspaperIssueSearchOptions> GetSearchRequest(Request request)
        {
            return new SearchRequest<SortOptions, NewspaperIssueSearchOptions>()
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

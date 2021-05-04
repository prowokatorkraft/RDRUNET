using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.Newspaper;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class NewspaperHandler : IHandlerBll<Newspaper, GetRequest>
    {
        private INewspaperBll _newspaperBll;
        public NewspaperHandler(INewspaperBll newspaperBll)
        {
            _newspaperBll = newspaperBll;
        }

        public IEnumerable<Newspaper> Search(GetRequest request)
        {
            var searchRequest = GetSearchRequest(request);

            return _newspaperBll.Search(searchRequest, RoleType.externalClient);
        }

        private NewspaperSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "Name":
                    return NewspaperSearchOptions.Name;
                default:
                    return NewspaperSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, NewspaperSearchOptions> GetSearchRequest(GetRequest request)
        {
            return new SearchRequest<SortOptions, NewspaperSearchOptions>()
            {
                SortOptions = request.IsDescending ? SortOptions.Descending : SortOptions.Ascending,
                SearchOptions = GetSearchOption(request.SearchOption),
                SearchLine = request.SearchLine
            };
        }
    }
}

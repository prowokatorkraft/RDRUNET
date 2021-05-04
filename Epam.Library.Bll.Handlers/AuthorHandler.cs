using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class AuthorHandler : IHandlerBll<Author, GetRequest>
    {
        private IAuthorBll _authorBll;
        public AuthorHandler(IAuthorBll authorBll)
        {
            _authorBll = authorBll;
        }

        public IEnumerable<Author> Search(GetRequest request)
        {
            var searchRequest = GetSearchRequest(request);

            return _authorBll.Search(searchRequest, RoleType.externalClient);
        }

        private AuthorSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "FirstName":
                    return AuthorSearchOptions.FirstName;
                case "LastName":
                    return AuthorSearchOptions.LastName;
                default:
                    return AuthorSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, AuthorSearchOptions> GetSearchRequest(GetRequest request)
        {
            return new SearchRequest<SortOptions, AuthorSearchOptions>()
            {
                SortOptions = request.IsDescending ? SortOptions.Descending : SortOptions.Ascending,
                SearchOptions = GetSearchOption(request.SearchOption),
                SearchLine = request.SearchLine
            };
        }
    }
}

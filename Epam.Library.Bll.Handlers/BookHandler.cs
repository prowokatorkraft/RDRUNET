using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Handlers
{
    public class BookHandler : IPageHandlerBll<AbstractBook, PageRequest>
    {
        private IBookBll _bookBll;
        public BookHandler(IBookBll bookBll)
        {
            _bookBll = bookBll;
        }

        public int GetPageCount(PageRequest request)
        {
            NumberOfPageFilter filter = new NumberOfPageFilter()
            {
                MinNumberOfPages = request.MinNumberOfPages,
                MaxNumberOfPages = request.MaxNumberOfPages
            };
            int count = _bookBll.GetCount(searchOptions: GetSearchOption(request.SearchOption), searchLine: request.SearchLine, numberOfPageFilter: filter, role: RoleType.externalClient);

            return (int)Math.Ceiling(a: count / (double)request.SizePage);
        }
        public IEnumerable<AbstractBook> Search(PageRequest request)
        {
            var searchRequest = GetSearchRequest(request);

            return _bookBll.Search(searchRequest, RoleType.externalClient);
        }

        private BookSearchOptions GetSearchOption(string searchOption)
        {
            switch (searchOption)
            {
                case "Name":
                    return BookSearchOptions.Name;
                case "Publisher":
                    return BookSearchOptions.Publisher;
                default:
                    return BookSearchOptions.None;
            }
        }
        private SearchRequest<SortOptions, BookSearchOptions> GetSearchRequest(PageRequest request)
        {
            return new SearchRequest<SortOptions, BookSearchOptions>()
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

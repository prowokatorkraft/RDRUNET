using System;

namespace Epam.Library.Common.Entities
{
    public class SearchRequest<Sort, Search> 
        where Sort: Enum 
        where Search: Enum
    {
        public Sort SortOptions { get; set; }

        public Search SearchOptions { get; set; }

        public string SearchLine { get; set; }

        public PagingInfo PagingInfo { get; set; }

        public SearchRequest()
        {
        }

        public SearchRequest(Sort sortOptions, Search searchOptions, string searchLine = null, PagingInfo pagingInfo = null)
        {
            SortOptions = sortOptions;
            SearchOptions = searchOptions;
            SearchLine = searchLine;
            PagingInfo = pagingInfo;
        }
    }
}

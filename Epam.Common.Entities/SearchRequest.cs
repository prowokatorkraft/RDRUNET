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

        public SearchRequest()
        {
        }

        public SearchRequest(Sort sortOptions, Search searchOptions, string searchLine)
        {
            SortOptions = sortOptions;
            SearchOptions = searchOptions;
            SearchLine = searchLine;
        }
    }
}

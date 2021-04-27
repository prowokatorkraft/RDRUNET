using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Pl.WebApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Epam.Library.Pl.WebApi.Controllers
{
    public class CatalogueController : ApiController
    {
        private ICatalogueBll _catalogueBll;
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public CatalogueController(ICatalogueBll catalogueBll, IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _catalogueBll = catalogueBll;
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        [HttpGet]
        public IHttpActionResult GetAll([FromUri]PageInfoVM pageInfo, [FromUri]SearchFilterVM filter)
        {
            pageInfo.CountPage = (int)Math.Ceiling(a: _catalogueBll.GetCount(role: RoleType.externalClient) / (double)pageInfo.SizePage);
            if (pageInfo.CurrentPage < 1 || pageInfo.CurrentPage > pageInfo.CountPage)
            {
                return BadRequest($"Incorrect current page \"{pageInfo.CurrentPage}\"");
            }

            var searchRequest = GetSearchRequest(pageInfo, filter);
            var elements = _catalogueBll.Search(searchRequest, RoleType.externalClient);
            var page = GetPage(pageInfo, filter, elements);

            return Ok(page);
        }

        private PageDataVM<CatalogueElementVM> GetPage(PageInfoVM pageInfo, SearchFilterVM filter, IEnumerable<LibraryAbstractElement> elements)
        {
            return new PageDataVM<CatalogueElementVM>()
            {
                PageInfo = pageInfo,
                Elements = _mapper.Map<CatalogueElementVM, LibraryAbstractElement>(elements).ToList(),
                SearchFilter = filter
            };
        }
        private SearchRequest<SortOptions, CatalogueSearchOptions> GetSearchRequest(PageInfoVM pageInfo, SearchFilterVM filter)
        {
            CatalogueSearchOptions searchOption;

            switch (filter.SearchOption)
            {
                case "Name":
                    searchOption = CatalogueSearchOptions.Name;
                    break;
                default:
                    searchOption = CatalogueSearchOptions.None;
                    break;
            }

            return new SearchRequest<SortOptions, CatalogueSearchOptions>()
            {
                SortOptions = filter.IsDescending ? SortOptions.Descending : SortOptions.Ascending,
                SearchOptions = searchOption,
                SearchLine = filter.SearchLine,
                NumberOfPageFilter = new NumberOfPageFilter() 
                { 
                    MinNumberOfPages = filter.MinNumberOfPages,
                    MaxNumberOfPages = filter.MaxNumberOfPages
                },
                PagingInfo = new PagingInfo(pageInfo.SizePage, pageInfo.CurrentPage)
            };
        }
    }
}

//{
//  "PageInfo": {
//        "CurrentPage": 1,
//        "CountPage": 1,
//        "SizePage": 20
//  },
//  "SearchFilter": {
//        "TypeElement": "Book",
//        "SearchOption": "Name",
//        "SearchLine": "test",
//        "IsDescending": false,
//        "MinPageNumber": 2,
//        "MaxPageNumber": 15
//  },
//  "Elements": [
//    {
//        "Id": 6065,
//        "Name": "Test book",
//        "NumberOfPages": 14,
//        "Type": "Book"
//    }
//  ]
//}
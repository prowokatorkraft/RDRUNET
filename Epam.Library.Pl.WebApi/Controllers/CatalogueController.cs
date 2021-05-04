using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
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
        private IPageHandlerBll<LibraryAbstractElement, PageRequest> _hendlerBll;
        private Mapper _mapper;
        public CatalogueController(IPageHandlerBll<LibraryAbstractElement, PageRequest> hendlerBll, Mapper mapper)
        {
            _hendlerBll = hendlerBll;
            _mapper = mapper;
        }

        public IHttpActionResult GetAll([FromUri]PageRequest request)
        {
            int countPage = _hendlerBll.GetPageCount(request);
            if (request.CurrentPage < 1 || request.CurrentPage > countPage)
            {
                return BadRequest($"Incorrect current page \"{request.CurrentPage}\"");
            }

            var elements = _hendlerBll.Search(request);

            return Ok(new PageDataVM<CatalogueElementVM>()
            {
                PageInfo = new PageInfoVM() 
                { 
                    CurrentPage = request.CurrentPage,
                    SizePage = request.SizePage,
                    CountPage = countPage
                },
                Elements = _mapper.Map<CatalogueElementVM, LibraryAbstractElement>(elements).ToList()
            });
        }
    }
}

//{
//   "PageInfo": {
//      "CurrentPage": 1,
//      "CountPage": 1,
//      "SizePage": 20
//    },
//  "Elements": [
//    {
//       "Id": 7065,
//      "Name": "New patent",
//      "NumberOfPages": 6,
//      "Type": "Patent"
//    },
//    {
//        "Id": 6065,
//      "Name": "Test book",
//      "NumberOfPages": 14,
//      "Type": "Book"
//    },
//    {
//        "Id": 7066,
//      "Name": "Первые новости",
//      "NumberOfPages": 4,
//      "Type": "NewspaperIssue"
//    }
//  ]
//}
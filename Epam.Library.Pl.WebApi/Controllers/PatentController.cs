using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.WebApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Epam.Library.Pl.WebApi.Controllers
{
    public class PatentController : ApiController
    {
        private IHandlerBll<AbstractPatent> _hendlerBll;
        private Mapper _mapper;
        public PatentController(IHandlerBll<AbstractPatent> hendlerBll, Mapper mapper)
        {
            _hendlerBll = hendlerBll;
            _mapper = mapper;
        }

        [HttpGet]
        public IHttpActionResult GetAll([FromUri] Request request)
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

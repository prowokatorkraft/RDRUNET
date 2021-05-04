using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Pl.WebApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Epam.Library.Pl.WebApi.Controllers
{
    public class AuthorController : ApiController
    {
        private IHandlerBll<Author, GetRequest> _handlerBll;
        private Mapper _mapper;
        public AuthorController(IHandlerBll<Author, GetRequest> hendlerBll, Mapper mapper)
        {
            _handlerBll = hendlerBll;
            _mapper = mapper;
        }

        public IHttpActionResult GetAll([FromUri]GetRequest request)
        {
            var elements = _mapper.Map<AuthorVM, Author>(_handlerBll.Search(request));

            return Ok(elements);
        }
    }
}

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
        private IAuthorBll _bll;
        private IHandlerBll<Author, GetRequest> _handlerBll;
        private Mapper _mapper;
        public AuthorController(IAuthorBll bll, IHandlerBll<Author, GetRequest> handlerBll, Mapper mapper)
        {
            _bll = bll;
            _handlerBll = handlerBll;
            _mapper = mapper;
        }

        public IHttpActionResult GetAll([FromUri] GetRequest request)
        {
            var elements = _mapper.Map<AuthorVM, Author>(_handlerBll.Search(request));

            return Ok(elements);
        }

        public IHttpActionResult Get(int id)
        {
            var element = _mapper.Map<AuthorVM, Author>(_bll.Get(id, role: RoleType.externalClient));

            return Ok(element);
        }

        public IHttpActionResult Post([FromBody] CreateEditAuthorVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var author = _mapper.Map<Author, CreateEditAuthorVM>(request);

            var result = _bll.Add(author);
            if (result.Any())
            {
                foreach (var item in result)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
                return BadRequest(ModelState);
            }

            return Created($"/api/author/{author.Id}", request); ///
        }

        public IHttpActionResult Put([FromBody] CreateEditAuthorVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var author = _mapper.Map<Author, CreateEditAuthorVM>(request);

            var result = _bll.Update(author);
            if (result.Any())
            {
                foreach (var item in result)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
                return BadRequest(ModelState);
            }

            return Ok(request);
        }
    }
}

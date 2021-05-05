using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.ApiQuery;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Pl.WebApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Epam.Library.Pl.WebApi.Controllers
{
    public class NewspaperController : ApiController
    {
        private INewspaperBll _bll;
        private IHandlerBll<Newspaper, GetRequest> _handlerBll;
        private Mapper _mapper;
        public NewspaperController(INewspaperBll bll, IHandlerBll<Newspaper, GetRequest> handlerBll, Mapper mapper)
        {
            _bll = bll;
            _handlerBll = handlerBll;
            _mapper = mapper;
        }

        public IHttpActionResult GetAll([FromUri] GetRequest request)
        {
            var elements = _mapper.Map<ElementVM, Newspaper>(_handlerBll.Search(request));

            return Ok(elements);
        }

        public IHttpActionResult Get(int id)
        {
            var element = _mapper.Map<DisplayNewspaperVM, Newspaper>(_bll.Get(id, role: RoleType.externalClient));

            return Ok(element);
        }

        public IHttpActionResult Post([FromBody] CreateEditNewspaperVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var element = _mapper.Map<Newspaper, CreateEditNewspaperVM>(request);

            var result = _bll.Add(element);
            if (result.Any())
            {
                foreach (var item in result)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
                return BadRequest(ModelState);
            }

            return Created($"/api/newspaper/{element.Id}", request); ///
        }

        public IHttpActionResult Put([FromBody] CreateEditNewspaperVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var element = _mapper.Map<Newspaper, CreateEditNewspaperVM>(request);

            var result = _bll.Update(element);
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

        public IHttpActionResult Delete(int id)
        {
            if (!_bll.Remove(id, RoleType.externalClient))
            {
                return BadRequest($"Element {id} doesn't deleted.");
            }

            return Ok();
        }
    }
}

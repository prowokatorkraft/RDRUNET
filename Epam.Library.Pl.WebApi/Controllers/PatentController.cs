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
        private IPatentBll _bll;
        private IPageHandlerBll<AbstractPatent, PageRequest> _hendlerBll;
        private Mapper _mapper;
        public PatentController(IPatentBll bll, IPageHandlerBll<AbstractPatent, PageRequest> hendlerBll, Mapper mapper)
        {
            _bll = bll;
            _hendlerBll = hendlerBll;
            _mapper = mapper;
        }

        public IHttpActionResult GetAll([FromUri] PageRequest request)
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

        public IHttpActionResult Get(int id)
        {
            var element = _mapper.Map<DisplayPatentVM, AbstractPatent>(_bll.Get(id, role: RoleType.externalClient));

            return Ok(element);
        }

        public IHttpActionResult Post([FromBody] CreateEditPatentVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var element = _mapper.Map<Patent, CreateEditPatentVM>(request);

            var result = _bll.Add(element, RoleType.externalClient);
            if (result.Any())
            {
                foreach (var item in result)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
                return BadRequest(ModelState);
            }

            return Created($"/api/patent/{element.Id}", request); ///
        }

        public IHttpActionResult Put([FromBody] CreateEditPatentVM request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var element = _mapper.Map<Patent, CreateEditPatentVM>(request);

            var result = _bll.Update(element, RoleType.externalClient);
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

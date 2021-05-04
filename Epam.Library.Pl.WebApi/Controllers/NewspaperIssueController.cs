﻿using Epam.Library.Bll.Contracts;
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
    public class NewspaperIssueController : ApiController
    {
        private INewspaperIssueBll _bll;
        private IPageHandlerBll<NewspaperIssue, PageRequest> _hendlerBll;
        private Mapper _mapper;
        public NewspaperIssueController(INewspaperIssueBll bll, IPageHandlerBll<NewspaperIssue, PageRequest> hendlerBll, Mapper mapper)
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
            var element = _mapper.Map<DisplayNewspaperIssueVM, NewspaperIssue>(_bll.Get(id, role: RoleType.externalClient));

            return Ok(element);
        }
    }
}

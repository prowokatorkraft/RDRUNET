using Epam.Library.Bll.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class AdminController : Controller
    {
        private readonly IAccountBll _accountBll;
        private readonly IRoleBll _roleBll;
        private readonly Mapper _mapper;

        public AdminController(IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        public ActionResult GetAll()
        {
            return View();
        }
    }
}
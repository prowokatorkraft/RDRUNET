using Epam.Library.Common.Entities;
using log4net;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class AdminLogAttribute : FilterAttribute, IActionFilter
    {
        private readonly ILog _logger;

        public AdminLogAttribute(ILog logger)
        {
            _logger = logger;
        }

        public void OnActionExecuted(ActionExecutedContext filterContext)
        {
            var user = filterContext.HttpContext.User;

            if (user.Identity.IsAuthenticated && user.IsInRole(RoleType.admin.ToString()))
            {
                var login = user.Identity.Name;

                ThreadContext.Properties["Login"] = login;
                ThreadContext.Properties["Layer"] = "PL";
                ThreadContext.Properties["Class"] = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName + "Controller";
                ThreadContext.Properties["Method"] = filterContext.ActionDescriptor.ActionName;

                _logger.Info($"INFO: Admin: \"{login}\" made the transition in the current direction: {filterContext.HttpContext.Request.RawUrl}.");
            }
        }

        public void OnActionExecuting(ActionExecutingContext filterContext)
        {
            
        }
    }
}
using log4net;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class ForbiddenLogAttribute : AuthorizeAttribute
    {
        private readonly ILog _logger;

        public ForbiddenLogAttribute(ILog logger)
        {
            _logger = logger;
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            if (filterContext.HttpContext.Request.IsAuthenticated)
            {
                var login = filterContext.HttpContext.User.Identity.Name;

                ThreadContext.Properties["User"] = login;
                ThreadContext.Properties["Layer"] = "PL";
                ThreadContext.Properties["Class"] = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName;
                ThreadContext.Properties["Method"] = filterContext.ActionDescriptor.ActionName;

                _logger.Warn($"Warning: user: \"{login}\" was attempted unauthorized access to closed functionality.");

                //filterContext.Result = new HttpStatusCodeResult(403);
            }
            else
            {
                base.HandleUnauthorizedRequest(filterContext);
            }
        }
    }
}
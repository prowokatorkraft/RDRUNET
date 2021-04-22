using log4net;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class LogoutLogAttribute : FilterAttribute
    {

    }

    public class LogoutLoggerAttribute : LogoutLogAttribute, IActionFilter
    {
        private readonly ILog _logger;

        public LogoutLoggerAttribute(ILog logger)
        {
            _logger = logger;
        }

        public void OnActionExecuted(ActionExecutedContext filterContext)
        {

        }

        public void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var user = filterContext.HttpContext.User.Identity;

            if (user.IsAuthenticated)
            {
                ThreadContext.Properties["Login"] = user.Name;
                ThreadContext.Properties["Layer"] = "PL";
                ThreadContext.Properties["Class"] = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName;
                ThreadContext.Properties["Method"] = filterContext.ActionDescriptor.ActionName;

                _logger.Info($"INFO: User:{user.Name} log out.");
            }
        }
    }
}
using log4net;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class LoginLogAttribute : FilterAttribute
    {

    }

    public class LoginLoggerAttribute : LoginLogAttribute, IActionFilter
    {
        private readonly ILog _logger;

        public LoginLoggerAttribute(ILog logger)
        {
            _logger = logger;
        }

        public void OnActionExecuted(ActionExecutedContext filterContext)
        {
            var tempData = filterContext.Controller.TempData;

            if (tempData.ContainsKey("IsAuth") && tempData["IsAuth"] is bool)
            {
                string login = tempData.TryGetValue("UserName", out object username)
                    ? username as string
                    : "anonymous";

                ThreadContext.Properties["Login"] = login;
                ThreadContext.Properties["Layer"] = "PL";
                ThreadContext.Properties["Class"] = filterContext.ActionDescriptor.ControllerDescriptor.ControllerName;
                ThreadContext.Properties["Method"] = filterContext.ActionDescriptor.ActionName;

                _logger.Info($"INFO: User:{login} log in.");
            }
        }

        public void OnActionExecuting(ActionExecutingContext filterContext)
        {

        }
    }
}
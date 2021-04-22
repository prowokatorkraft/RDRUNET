using log4net;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class RegisterLogAttribute : FilterAttribute
    {

    }

    public class RegisterLoggingAttribute : RegisterLogAttribute, IActionFilter
    {
        private readonly ILog _logger;

        public RegisterLoggingAttribute(ILog logger)
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

                _logger.Info($"INFO: new user:{login} register in library.");
            }
        }

        public void OnActionExecuting(ActionExecutingContext filterContext)
        {
            
        }
    }
}
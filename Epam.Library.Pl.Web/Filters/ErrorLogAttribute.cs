using Epam.Library.Common.Entities;
using log4net;
using System;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Filters
{
    public class ErrorLogAttribute : HandleErrorAttribute
    {
        private readonly ILog _logger;

        public ErrorLogAttribute(ILog logger)
        {
            _logger = logger;
        }

        public override void OnException(ExceptionContext filterContext)
        {
            var user = filterContext.HttpContext.User;

            var login = user.Identity.IsAuthenticated
                ? user.Identity.Name
                : "anonymous";

            LogError(filterContext.Exception, login);
        }

        private void LogError(Exception exception, string login)
        {
            var exc = exception as LayerException;
            string message = $"ERROR: {exception.Message}";

            if (exc != null)
            {
                if (exc.InnerException != null)
                {
                    message += $" Reason: {exc.InnerException.Message}";
                    LogError(exc.InnerException, login);
                }

                ThreadContext.Properties["Login"] = login;
                ThreadContext.Properties["Class"] = exc.Class;
                ThreadContext.Properties["Method"] = exc.Method;
                ThreadContext.Properties["Layer"] = exc.Layer;

                _logger.Error(message);
            }
        }
    }
}
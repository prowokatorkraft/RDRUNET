using Epam.Library.Common.Entities;
using Epam.Library.Pl.Web.Controllers;
using Epam.Library.Pl.Web.Filters;
using Ninject.Modules;
using Ninject.Web.Mvc.FilterBindingSyntax;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web
{
    public class FilterBindingModule : NinjectModule
    {
        public override void Load()
        {
            this.BindFilter<ErrorLogAttribute>(FilterScope.Global, null)
                .InRequestScope();

            this.BindFilter<AdminLogAttribute>(FilterScope.Global, null)
                .InRequestScope();

            this.BindFilter<LogoutLoggerAttribute>(FilterScope.Action, null)
                .WhenActionMethodHas<LogoutLogAttribute>();

            this.BindFilter<LoginLoggerAttribute>(FilterScope.Action, null)
                .WhenActionMethodHas<LoginLogAttribute>();

            this.BindFilter<RegisterLoggingAttribute>(FilterScope.Action, null)
                .WhenActionMethodHas<RegisterLogAttribute>();

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<AdminController>()
                .WithPropertyValue("Roles", RoleType.admin.ToString());

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<AuthorController>()
                .WithPropertyValue("Roles", RoleType.librarian.ToString());

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<BookController>()
                .WithPropertyValue("Roles", RoleType.librarian.ToString());

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<NewspaperController>()
                .WithPropertyValue("Roles", RoleType.librarian.ToString());

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<NewspaperIssueController>()
                .WithPropertyValue("Roles", RoleType.librarian.ToString());

            this.BindFilter<ForbiddenLogAttribute>(FilterScope.Controller, null)
                .WhenControllerType<PatentController>()
                .WithPropertyValue("Roles", RoleType.librarian.ToString());
        }
    }
}
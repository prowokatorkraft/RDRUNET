using System.Collections.Generic;
using System.Configuration;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.DependencyInjection.Configuration;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using Epam.Library.Dal.Database;
using Ninject;

namespace Epam.Library.Common.DependencyInjection
{
    public static class NinjectConfig
    {
        private static readonly IDictionary<RoleType, string> _identityConnectionStrings;

        static NinjectConfig()
        {
            _identityConnectionStrings = GetIdentityConnectionStrings();
        }

        public static void RegisterConfig(IKernel kernel)
        {
            #region Connection string
            kernel
                .Bind<ConnectionStringDb>()
                .ToSelf()
                .InSingletonScope()
                .WithConstructorArgument("identityConnectionStrings", _identityConnectionStrings);
            #endregion

            #region Dal
            kernel
                .Bind<IBookDao>()
                .To<Epam.Library.Dal.Database.BookDao>()
                .InSingletonScope();
            kernel
                .Bind<IPatentDao>()
                .To<Epam.Library.Dal.Database.PatentDao>()
                .InSingletonScope();
            kernel
                .Bind<INewspaperDao>()
                .To<Epam.Library.Dal.Database.NewspaperDao>()
                .InSingletonScope();
            kernel
                .Bind<INewspaperIssueDao>()
                .To<Epam.Library.Dal.Database.NewspaperIssueDao>()
                .InSingletonScope();
            kernel
                .Bind<ICatalogueDao>()
                .To<Epam.Library.Dal.Database.CatalogueDao>()
                .InSingletonScope();
            kernel
                .Bind<IAuthorDao>()
                .To<Epam.Library.Dal.Database.AuthorDao>()
                .InSingletonScope();
            kernel
                .Bind<IAccountDao>()
                .To<Epam.Library.Dal.Database.AccountDao>()
                .InSingletonScope();
            kernel
                .Bind<IRoleDao>()
                .To<Epam.Library.Dal.Database.RoleDao>()
                .InSingletonScope();
            #endregion

            #region Validation
            kernel
                .Bind<IValidationBll<AbstractBook>>()
                .To<Epam.Library.Bll.Validation.BookValidation>()
                .InSingletonScope();
            kernel
                .Bind<IValidationBll<AbstractPatent>>()
                .To<Epam.Library.Bll.Validation.PatentValidation>()
                .InSingletonScope();
            kernel
                .Bind<IValidationBll<Newspaper>>()
                .To<Epam.Library.Bll.Validation.NewspaperValidation>()
                .InSingletonScope();
            kernel
                .Bind<IValidationBll<NewspaperIssue>>()
                .To<Epam.Library.Bll.Validation.NewspaperIssueValidation>()
                .InSingletonScope();
            kernel
                .Bind<IValidationBll<Author>>()
                .To<Epam.Library.Bll.Validation.AuthorValidation>()
                .InSingletonScope();
            kernel
                .Bind<IValidationBll<Account>>()
                .To<Epam.Library.Bll.Validation.AccountValidation>()
                .InSingletonScope();
            #endregion

            #region Bll
            kernel
                .Bind<IBookBll>()
                .To<Epam.Library.Bll.BookBll>()
                .InSingletonScope();
            kernel
                .Bind<IPatentBll>()
                .To<Epam.Library.Bll.PatentBll>()
                .InSingletonScope();
            kernel
                .Bind<INewspaperBll> ()
                .To<Epam.Library.Bll.NewspaperBll>()
                .InSingletonScope();
            kernel
                .Bind<INewspaperIssueBll>()
                .To<Epam.Library.Bll.NewspaperIssueBll>()
                .InSingletonScope();
            kernel
                .Bind<ICatalogueBll>()
                .To<Epam.Library.Bll.CatalogueBll>()
                .InSingletonScope();
            kernel
                .Bind<IAuthorBll>()
                .To<Epam.Library.Bll.AuthorBll>()
                .InSingletonScope();
            kernel
                .Bind<IAccountBll>()
                .To<Epam.Library.Bll.AccountBll>()
                .InSingletonScope();
            kernel
                .Bind<IRoleBll>()
                .To<Epam.Library.Bll.RoleBll>()
                .InSingletonScope();
            #endregion

            #region ApiHandlers
            kernel
                .Bind<IHandlerBll<LibraryAbstractElement>>()
                .To<Epam.Library.Bll.Handlers.CatalogueHandler>()
                .InSingletonScope();
            kernel
                .Bind<IHandlerBll<AbstractBook>>()
                .To<Epam.Library.Bll.Handlers.BookHandler>()
                .InSingletonScope();
            kernel
                .Bind<IHandlerBll<AbstractPatent>>()
                .To<Epam.Library.Bll.Handlers.PatentHandler>()
                .InSingletonScope();
            kernel
                .Bind<IHandlerBll<NewspaperIssue>>()
                .To<Epam.Library.Bll.Handlers.NewspaperIssueHandler>()
                .InSingletonScope();
            #endregion
        }

        private static IDictionary<RoleType, string> GetIdentityConnectionStrings()
        {
            var connectionString = ConfigurationManager.ConnectionStrings["Dbase"].ConnectionString;

            var identityConndectionStrings = new Dictionary<RoleType, string>();
            var identityDb = (IdentityDbConfig)ConfigurationManager.GetSection("identityDb");

            var account = identityDb.Accounts[RoleType.admin.ToString()];
            identityConndectionStrings.Add(RoleType.admin, string.Format(connectionString, account.UserID, account.Password));

            account = identityDb.Accounts[RoleType.librarian.ToString()];
            identityConndectionStrings.Add(RoleType.librarian, string.Format(connectionString, account.UserID, account.Password));
            identityConndectionStrings.Add(RoleType.externalClient, identityConndectionStrings[RoleType.librarian]);

            account = identityDb.Accounts[RoleType.user.ToString()];
            identityConndectionStrings.Add(RoleType.user, string.Format(connectionString, account.UserID, account.Password));
            
            return identityConndectionStrings;
        }
    }
}

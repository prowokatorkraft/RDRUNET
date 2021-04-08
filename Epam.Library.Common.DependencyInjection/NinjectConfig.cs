using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using Ninject;

namespace Epam.Library.Common.DependencyInjection
{
    public static class NinjectConfig
    {
        private static readonly string _connectionString;

        static NinjectConfig()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["DB"].ConnectionString;
        }

        public static void RegisterConfig(IKernel kernel)
        {
            #region Dal
            kernel
                .Bind<IBookDao>()
                .To<Epam.Library.Dal.Database.BookDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<IPatentDao>()
                .To<Epam.Library.Dal.Database.PatentDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<INewspaperDao>()
                .To<Epam.Library.Dal.Database.NewspaperDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<ICatalogueDao>()
                .To<Epam.Library.Dal.Database.CatalogueDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<IAuthorDao>()
                .To<Epam.Library.Dal.Database.AuthorDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<IAccountDao>()
                .To<Epam.Library.Dal.Database.AccountDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
            kernel
                .Bind<IRoleDao>()
                .To<Epam.Library.Dal.Database.RoleDao>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", _connectionString);
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
                .Bind<IValidationBll<AbstractNewspaper>>()
                .To<Epam.Library.Bll.Validation.NewspaperValidation>()
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
                .Bind< INewspaperBll> ()
                .To<Epam.Library.Bll.NewspaperBll>()
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
        }
    }
}

using Epam.Library.Bll.Contracts;
using Ninject;
using Epam.Library.Common.DependencyInjection;

namespace Epam.Library.IntegrationTest
{
    public static class NinjectForTests
    {
        public static IAuthorBll AuthorBll { get; private set; }
        public static ICatalogueBll CatalogueBll { get; private set; }
        public static IBookBll BookBll { get; private set; }
        public static IPatentBll PatentBll { get; private set; }
        public static IOldNewspaperBll NewspaperBll { get; private set; }

        static NinjectForTests()
        {
            var kernel = new StandardKernel();
            NinjectConfig.RegisterConfig(kernel);

            AuthorBll = kernel.Get<IAuthorBll>();
            CatalogueBll = kernel.Get<ICatalogueBll>();
            BookBll = kernel.Get<IBookBll>();
            PatentBll = kernel.Get<IPatentBll>();
            NewspaperBll = kernel.Get<IOldNewspaperBll>();
        }
    }
}

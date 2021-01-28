using Epam.Library.Dal.Contracts;
using Epam.Library.Bll.Contracts;

namespace Epam.Library.Common.DependencyInjection
{
    public static class DependencyInjection
    {
        public static  ICatalogueDao CatalogueDao { get; }
        public static IBookDao BookDao { get; }
        public static INewspaperDao NewspaperDao { get; }
        public static IPatentDao PatentDao { get; }

        public static ICatalogueBll CatalogueBll { get; }
        public static IBookBll BookBll { get; }
        public static INewspaperBll NewspaperBll { get; }
        public static IPatentBll PatentBll { get; }

        static DependencyInjection()
        {

        }
    }
}

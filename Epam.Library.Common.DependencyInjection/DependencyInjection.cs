using Epam.Library.Dal.Contracts;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Memory;
using Epam.Library.Bll.Validation;
using Epam.Library.Bll;

namespace Epam.Library.Common.DependencyInjection
{
    public static class DependencyInjection
    {
        public static IAuthorDao AuthorDao { get; }
        public static ICatalogueDao CatalogueDao { get; }
        public static IBookDao BookDao { get; }
        public static INewspaperDao NewspaperDao { get; }
        public static IPatentDao PatentDao { get; }

        public static IValidationBll<Author> AuthorValidation { get; }
        public static IValidationBll<AbstractBook> BookValidation { get; }
        public static IValidationBll<AbstractNewspaper> NewspaperValidation { get; }
        public static IValidationBll<AbstractPatent> PatentValidation { get; }

        public static IAuthorBll AuthorBll { get; }
        public static ICatalogueBll CatalogueBll { get; }
        public static IBookBll BookBll { get; }
        public static INewspaperBll NewspaperBll { get; }
        public static IPatentBll PatentBll { get; }

        static DependencyInjection()
        {
            AuthorDao = new AuthorDao();
            CatalogueDao = new CatalogueDao(AuthorDao);
            BookDao = new BookDao(CatalogueDao);
            NewspaperDao = new NewspaperDao(CatalogueDao);
            PatentDao = new PatentDao(CatalogueDao);

            AuthorValidation = new AuthorValidation();
            BookValidation = new BookValidation();
            NewspaperValidation = new NewspaperValidation();
            PatentValidation = new PatentValidation();

            CatalogueBll = new CatalogueBll(CatalogueDao);
            AuthorBll = new AuthorBll(AuthorDao, CatalogueBll, AuthorValidation);
            BookBll = new BookBll(BookDao, AuthorBll, BookValidation);
            NewspaperBll = new NewspaperBll(NewspaperDao, NewspaperValidation);
            PatentBll = new PatentBll(PatentDao, AuthorBll, PatentValidation);
        }
    }
}

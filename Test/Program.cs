using Epam.Library.Common.DependencyInjection;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            var bookDao = DependencyInjection.BookDao;
            var authorDao = DependencyInjection.AuthorDao;
            var patentDao = DependencyInjection.PatentDao;
            var newspaperDao = DependencyInjection.NewspaperDao;
            var catalogueDao = DependencyInjection.CatalogueDao;
            Book book = new Book(null, "Новая книга", 100, null, false, null, "New Pab", "Saratov", 2020, null);
            //Author author = new Author(9, "My", "Test", false);
            //Patent patent = new Patent(51, "My new Patent", 1, null, false, new int[] { }, "Russia", "123456788", null, DateTime.Now);
            //Newspaper newspaper = new Newspaper(null, "News", 1, "My annotation", false, "News 1", "Saratov", 2021, null, null, DateTime.Now);

            //bookDao.Remove(175);

            //bookDao.Add(book);

            //var m = bookDao.GetAllGroupsByPublisher(new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Name, null));

            var v = bookDao.Search(null);

        }
    }
}

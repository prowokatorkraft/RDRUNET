using Epam.Library.Common.DependencyInjection;
using Epam.Library.Common.Entities.AuthorElement.Book;
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

            Book book = new Book(null, "Новая книга", 100, null, false, new int[] { }, "New Pab", "Saratov", 2020, null);

            //bookDao.Add(book);

            //bookDao.Remove(40);

            //AbstractBook book1 = bookDao.Get(43);
        }
    }
}

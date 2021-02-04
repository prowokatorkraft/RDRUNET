using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Bll.Contracts;
using Epam.Library.Bll;
using Epam.Library.Bll.Logic.Validation;
using Epam.Library.Dal.Contracts;
using Epam.Library.Dal.Memory;

namespace Epam.Pl.ConsoleApplication
{
    class Program
    {
        static void Main(string[] args)
        {
            HashSet<Author> authors = new HashSet<Author>();

            IAuthorDao dao = new AuthorDao(authors);

            var a = new Author(null, "A1", "B2");
            var a1 = new Author(null, "A2", "B2");
            var a2 = new Author(null, "A2", "B1");

            dao.Add(a);
            dao.Add(a1);
            dao.Add(a2);

            var g = dao.Get(a.GetHashCode());

            var b = dao.Check(new int[] { a.GetHashCode(), 444 });

            //dao.Remove(a.GetHashCode());

            var e = dao.Search(new SearchRequest<SortOptions, Library.Common.Entities.SearchOptionsEnum.AuthorSearchOptions>
            (
                SortOptions.Ascending,
                Library.Common.Entities.SearchOptionsEnum.AuthorSearchOptions.LastName,
                "A"
            ));

            foreach (var item in e)
            {
                Console.WriteLine(item);
            }
        }
    }
}

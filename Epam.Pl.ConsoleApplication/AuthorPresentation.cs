using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Library.Pl.ConsoleApplication
{
    class AuthorPresentation
    {
        //
        private readonly IAuthorBll _authorBll;

        private readonly ICatalogueBll _catalogueBll;

        private readonly IBookBll _bookBll;

        private readonly IPatentBll _patentBll;

        public AuthorPresentation(IAuthorBll authorBll, ICatalogueBll catalogueBll, IBookBll bookBll, IPatentBll patentBll)
        {
            _authorBll = authorBll;
            _catalogueBll = catalogueBll;
            _bookBll = bookBll;
            _patentBll = patentBll;
        }

        public void StartMenu()
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Автор\n\n" +
                    "\t1.Посмотреть\n" +
                    "\t2.Поиск по имени\n" +
                    "\t3.Поиск по фамилии\n" +
                    "\t4.Добавить\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                HandleStartMenu(keyInfo);
            }
        }

        private void Get()
        {
            string line = default;

            List<Author> authors;

            IEnumerator<Author> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Авторы\n");

                authors = new List<Author>();

                enumerator = _authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.Ascending, AuthorSearchOptions.None, null)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    authors.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.FirstName} {enumerator.Current.LastName}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= authors.Count)
                {
                    SelectElement(authors[index - 1]);
                }
            }
        }
        private void HandleStartMenu(ConsoleKeyInfo keyInfo)
        {
            switch (keyInfo.Key)
            {
                case ConsoleKey.D1:
                case ConsoleKey.NumPad1:
                    Get();
                    break;

                case ConsoleKey.D2:
                case ConsoleKey.NumPad2:
                    GetByFirstName();
                    break;

                case ConsoleKey.D3:
                case ConsoleKey.NumPad3:
                    GetByLastName();
                    break;

                case ConsoleKey.D4:
                case ConsoleKey.NumPad4:
                    Add();
                    break;

                default:
                    break;
            }
        }

        private void SelectElement(Author author)
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Автор\n\n" +
                    $"\tИмя: {author.FirstName}\n" +
                    $"\tФамилия: {author.LastName}\n\n" +

                    "\t1.Посмотреть произведения автора\n" +
                    "\t2.Посмотреть книги автора\n" +
                    "\t3.Посмотреть патенты автора\n" +
                    "\t4.Удалить автора\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                if (!HandleSelectElement(keyInfo, author.Id.Value))
                {
                    break;
                }
            }
        }
        private bool HandleSelectElement(ConsoleKeyInfo keyInfo, int id)
        {
            switch (keyInfo.Key)
            {
                case ConsoleKey.D1:
                case ConsoleKey.NumPad1:
                    ViewWorksAuthor(id);
                    break;

                case ConsoleKey.D2:
                case ConsoleKey.NumPad2:
                    ViewBooksAuthor(id);
                    break;

                case ConsoleKey.D3:
                case ConsoleKey.NumPad3:
                    ViewPatentsAuthor(id);
                    break;

                case ConsoleKey.D4:
                case ConsoleKey.NumPad4:
                    _authorBll.Remove(id);
                    return false;

                default:
                    break;
            }

            return true;
        }

        private void ViewWorksAuthor(int id)
        {
            Console.Clear();

            foreach (var item in _catalogueBll.GetByAuthorId(id))
            {
                Console.WriteLine("\t" + item.Name);
            }

            Console.ReadKey(true);
        }
        private void ViewBooksAuthor(int id)
        {
            Console.Clear();

            foreach (var item in _bookBll.GetByAuthorId(id))
            {
                Console.WriteLine("\t" + item.Name);
            }

            Console.ReadKey(true);
        }
        private void ViewPatentsAuthor(int id)
        {
            Console.Clear();

            foreach (var item in _patentBll.GetByAuthorId(id))
            {
                Console.WriteLine("\t" + item.Name);
            }

            Console.ReadKey(true);
        }

        private void GetByFirstName()
        {
            string line = default;

            List<Author> authors;

            IEnumerator<Author> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Авторы\n");

                Console.WriteLine("Введите имя:");

                line = Console.ReadLine();

                authors = new List<Author>();

                enumerator = _authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.Ascending, AuthorSearchOptions.FirstName, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    authors.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.FirstName} {enumerator.Current.LastName}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= authors.Count)
                {
                    SelectElement(authors[index - 1]);
                }
            }
        }
        private void GetByLastName()
        {
            string line = default;

            List<Author> authors;

            IEnumerator<Author> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Авторы\n");

                Console.WriteLine("Введите фамилию:");

                line = Console.ReadLine();

                authors = new List<Author>();

                enumerator = _authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.Ascending, AuthorSearchOptions.LastName, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    authors.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.FirstName} {enumerator.Current.LastName}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= authors.Count)
                {
                    SelectElement(authors[index - 1]);
                }
            }
        }

        private void Add()
        {
            Author author = new Author();

            IEnumerable<ErrorValidation> errors = default;

            do
            {
                Console.Clear();

                Console.WriteLine("Добавление автора\n");

                if (errors != null)
                {
                    foreach (var item in errors)
                    {
                        Console.WriteLine("\t" + item.Field + ": " + item.Description + " " + item.Recommendation);
                    }
                }

                Console.WriteLine("Введите имя:");

                author.FirstName = Console.ReadLine();

                Console.WriteLine("Введите фамилию:");

                author.LastName = Console.ReadLine();

            } while ((errors = _authorBll.Add(author)).Count() != 0);
        }
    }
}

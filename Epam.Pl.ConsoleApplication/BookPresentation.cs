using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Epam.Library.Pl.ConsoleApplication
{
    public class BookPresentation
    {
        private readonly IAuthorBll _authorBll;

        private readonly IBookBll _bookBll;

        public BookPresentation(IAuthorBll authorBll, IBookBll bookBll)
        {
            _authorBll = authorBll;
            _bookBll = bookBll;
        }

        public void StartMenu()
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Книга\n\n" +
                    "\t1.Посмотреть\n" +
                    "\t2.Поиск по названию\n" +
                    "\t3.Поиск по издательству\n" +
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

            List<AbstractBook> books;

            IEnumerator<AbstractBook> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Книги\n");

                books = new List<AbstractBook>();

                enumerator = _bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.Ascending, BookSearchOptions.None, null)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    books.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= books.Count)
                {
                    SelectElement(books[index - 1]);
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
                    GetByName();
                    break;

                case ConsoleKey.D3:
                case ConsoleKey.NumPad3:
                    GetByPublisher();
                    break;

                case ConsoleKey.D4:
                case ConsoleKey.NumPad4:
                    Add();
                    break;

                default:
                    break;
            }
        }

        private void SelectElement(AbstractBook book)
        {
            ConsoleKeyInfo keyInfo = default;

            StringBuilder authorBuilder;

            Author author = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                authorBuilder = new StringBuilder();

                foreach (var authorId in book.AuthorIDs)
                {
                    if (author != null)
                    {
                        authorBuilder.Append(", ");
                    }

                    author = _authorBll.Get(authorId);

                    authorBuilder.Append(author.FirstName + " " + author.LastName);
                }

                Console.WriteLine
                (
                    "Автор\n\n" +
                    $"\tНазвание: {book.Name}\n" +
                    $"\tОписание: {book.Annotation}\n" +
                    $"\tКоличество страниц: {book.NumberOfPages}\n" +
                    $"\tАвторы: {authorBuilder.ToString()}\n" +
                    $"\tИздательство: {book.Publisher}\n" +
                    $"\tМесто публикации: {book.PublishingCity}\n" +
                    $"\tГод публикации: {book.PublishingYear}\n" +
                    $"\tISBN: {book.Isbn}\n\n" +

                    "\t1.Удалить книгу\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                if (!HandleSelectElement(keyInfo, book.Id.Value))
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
                    _bookBll.Remove(id);
                    return false;

                default:
                    break;
            }

            return true;
        }

        private void GetByName()
        {
            string line = default;

            List<AbstractBook> books;

            IEnumerator<AbstractBook> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Книги\n");

                Console.WriteLine("Введите название:");

                line = Console.ReadLine();

                books = new List<AbstractBook>();

                enumerator = _bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.Ascending, BookSearchOptions.Name, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    books.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= books.Count)
                {
                    SelectElement(books[index - 1]);
                }
            }
        }
        private void GetByPublisher()
        {
            string line = default;

            List<AbstractBook> books;

            IEnumerator<AbstractBook> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Книги\n");

                Console.WriteLine("Введите издательство:");

                line = Console.ReadLine();

                books = new List<AbstractBook>();

                enumerator = _bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.Ascending, BookSearchOptions.Publisher, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    books.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= books.Count)
                {
                    SelectElement(books[index - 1]);
                }
            }
        }

        private void Add()
        {
            AbstractBook book = new Book();

            IEnumerable<ErrorValidation> errors = default;

            do
            {
                Console.Clear();

                Console.WriteLine("Добавление книги\n");

                if (errors != null)
                {
                    foreach (var item in errors)
                    {
                        Console.WriteLine("\t" + item.Field + ": " + item.Description + " " + item.Recommendation);
                    }
                }

                Console.WriteLine("Введите название:");

                book.Name = Console.ReadLine();

                Console.WriteLine("Введите количество страниц:");

                int numberOfPage;

                book.NumberOfPages = int.TryParse(Console.ReadLine(), out numberOfPage)
                                            ? numberOfPage
                                            : -1;

                Console.WriteLine("Введите описание (не обязательно):");

                book.Annotation = Console.ReadLine();

                book.AuthorIDs = SelectAutors();

                Console.WriteLine("Введите издательсво:");

                book.Publisher = Console.ReadLine();

                Console.WriteLine("Введите место издательсва:");

                book.PublishingCity = Console.ReadLine();

                Console.WriteLine("Введите год публикации:");

                int publishingYear;

                book.PublishingYear = int.TryParse(Console.ReadLine(), out publishingYear)
                                            ? publishingYear
                                            : -1;

                Console.WriteLine("Введите ISBN (не обязательно):");

                if ((book.Isbn = Console.ReadLine()).Equals(string.Empty))
                {
                    book.Isbn = null;
                }

            } while ((errors = _bookBll.Add(book)).Count() != 0);
        }

        private int[] SelectAutors()
        {
            Console.WriteLine("Введите номера авторов через запятую (не обязательно):");

            List<Author> authors = new List<Author>();

            var enumerator = _authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.Ascending, AuthorSearchOptions.None, null)).GetEnumerator();

            for (int i = 1; enumerator.MoveNext(); i++)
            {
                authors.Add(enumerator.Current);

                Console.WriteLine($"\t{i}. {enumerator.Current.FirstName} {enumerator.Current.LastName}");
            }

            string line = Console.ReadLine();

            return GetAutorIDsByLine(authors, line);
        }

        private int[] GetAutorIDsByLine(List<Author> authors, string line)
        {
            string[] lines = line.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            List<int> autorIDs = new List<int>();

            int index;

            foreach (var item in lines)
            {
                if (int.TryParse(item, out index) && index > 0 && index <= authors.Count)
                {
                    autorIDs.Add(index - 1);
                }
            }

            return autorIDs.ToArray();
        }
    }
}

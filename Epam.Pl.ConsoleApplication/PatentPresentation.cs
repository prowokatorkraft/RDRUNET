using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Epam.Library.Pl.ConsoleApplication
{
    public class PatentPresentation
    {
        private readonly IAuthorBll _authorBll;

        private readonly IPatentBll _patentBll;

        public PatentPresentation(IAuthorBll authorBll, IPatentBll patentBll)
        {
            _authorBll = authorBll;
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
                    "Книга\n\n" +
                    "\t1.Посмотреть\n" +
                    "\t2.Поиск по названию\n" +
                    "\t3.Добавить\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                HandleStartMenu(keyInfo);
            }
        }

        private void Get()
        {
            string line = default;

            List<AbstractPatent> patents;

            IEnumerator<AbstractPatent> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Патенты\n");

                patents = new List<AbstractPatent>();

                enumerator = _patentBll.Search(new SearchRequest<SortOptions, PatentSearchOptions>(SortOptions.Ascending, PatentSearchOptions.None, null)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    patents.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= patents.Count)
                {
                    SelectElement(patents[index - 1]);
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
                    Add();
                    break;

                default:
                    break;
            }
        }

        private void SelectElement(AbstractPatent patent)
        {
            ConsoleKeyInfo keyInfo = default;

            StringBuilder authorBuilder;

            Author author = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                authorBuilder = new StringBuilder();

                foreach (var authorId in patent.AuthorIDs)
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
                    $"\tНазвание: {patent.Name}\n" +
                    $"\tОписание: {patent.Annotation}\n" +
                    $"\tКоличество страниц: {patent.NumberOfPages}\n" +
                    $"\tАвторы: {authorBuilder.ToString()}\n" +
                    $"\tСтрана: {patent.Country}\n" +
                    $"\tНомер регистрации: {patent.RegistrationNumber}\n" +
                    $"\tДата подачи заявки: {(patent.ApplicationDate.HasValue ? patent.ApplicationDate.Value.ToString() : null)}\n" +
                    $"\tДата публикации: {patent.DateOfPublication}\n" +

                    "\t1.Удалить патент\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                if (!HandleSelectElement(keyInfo, patent.Id.Value))
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
                    _patentBll.Remove(id);
                    return false;

                default:
                    break;
            }

            return true;
        }

        private void GetByName()
        {
            string line = default;

            List<AbstractPatent> patents;

            IEnumerator<AbstractPatent> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Патенты\n");

                Console.WriteLine("Введите название:");

                line = Console.ReadLine();

                patents = new List<AbstractPatent>();

                enumerator = _patentBll.Search(new SearchRequest<SortOptions, PatentSearchOptions>(SortOptions.Ascending, PatentSearchOptions.Name, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    patents.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= patents.Count)
                {
                    SelectElement(patents[index - 1]);
                }
            }
        }

        private void Add()
        {
            AbstractPatent patent = new Patent();

            IEnumerable<ErrorValidation> errors = default;

            do
            {
                Console.Clear();

                Console.WriteLine("Добавление патента\n");

                if (errors != null)
                {
                    foreach (var item in errors)
                    {
                        Console.WriteLine("\t" + item.Field + ": " + item.Description + " " + item.Recommendation);
                    }
                }

                Console.WriteLine("Введите название:");

                patent.Name = Console.ReadLine();

                Console.WriteLine("Введите количество страниц:");

                int numberOfPage;

                patent.NumberOfPages = int.TryParse(Console.ReadLine(), out numberOfPage)
                                            ? numberOfPage
                                            : -1;

                Console.WriteLine("Введите описание (не обязательно):");

                patent.Annotation = Console.ReadLine();

                patent.AuthorIDs = SelectAutors();

                Console.WriteLine("Введите название страны:");

                patent.Country = Console.ReadLine();

                Console.WriteLine("Введите номер регистрации:");

                patent.RegistrationNumber = Console.ReadLine();

                Console.WriteLine("Введите дату подачи заявки (не обязательно):");

                string tempString = Console.ReadLine();

                DateTime tempData;

                if (tempString.Equals(string.Empty))
                {
                    patent.ApplicationDate = null;
                }
                else if(DateTime.TryParse(tempString, out tempData))
                {
                    patent.ApplicationDate = tempData;
                }

                Console.WriteLine("Введите дату публикации:");

                if (DateTime.TryParse(Console.ReadLine(), out tempData))
                {
                    patent.DateOfPublication = tempData;
                }
                else
                {
                    continue;
                }

            } while ((errors = _patentBll.Add(patent)).Count() != 0);
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

using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Epam.Library.Pl.ConsoleApplication
{
    public class NewspaperPresentation
    {
        private readonly INewspaperBll _newspaperBll;

        public NewspaperPresentation(INewspaperBll newspaperBll)
        {
            _newspaperBll = newspaperBll;
        }

        public void StartMenu()
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Газета\n\n" +
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

            List<AbstractNewspaper> newspapers;

            IEnumerator<AbstractNewspaper> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Книги\n");

                newspapers = new List<AbstractNewspaper>();

                enumerator = _newspaperBll.Search(new SearchRequest<SortOptions, NewspaperSearchOptions>(SortOptions.Ascending, NewspaperSearchOptions.None, null)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    newspapers.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= newspapers.Count)
                {
                    SelectElement(newspapers[index - 1]);
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

        private void SelectElement(AbstractNewspaper newspaper)
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.B)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Автор\n\n" +
                    $"\tНазвание: {newspaper.Name}\n" +
                    $"\tОписание: {newspaper.Annotation}\n" +
                    $"\tКоличество страниц: {newspaper.NumberOfPages}\n" +
                    $"\tИздательство: {newspaper.Publisher}\n" +
                    $"\tМесто публикации: {newspaper.PublishingCity}\n" +
                    $"\tГод публикации: {newspaper.PublishingYear}\n" +
                    $"\tДата выпуска: {newspaper.Date}\n" +
                    $"\tISSN: {newspaper.Issn}\n" +

                    "\t1.Удалить газету\n" +
                    "\nВведите номер (назад b)"
                );

                keyInfo = Console.ReadKey(true);

                if (!HandleSelectElement(keyInfo, newspaper.Id.Value))
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
                    _newspaperBll.Remove(id);
                    return false;

                default:
                    break;
            }

            return true;
        }

        private void GetByName()
        {
            string line = default;

            List<AbstractNewspaper> newspapers;

            IEnumerator<AbstractNewspaper> enumerator;

            while (line != "b")
            {
                Console.Clear();

                Console.WriteLine("Газеты\n");

                Console.WriteLine("Введите название:");

                line = Console.ReadLine();

                newspapers = new List<AbstractNewspaper>();

                enumerator = _newspaperBll.Search(new SearchRequest<SortOptions, NewspaperSearchOptions>(SortOptions.Ascending, NewspaperSearchOptions.Name, line)).GetEnumerator();

                for (int i = 1; enumerator.MoveNext(); i++)
                {
                    newspapers.Add(enumerator.Current);

                    Console.WriteLine($"\t{i}. {enumerator.Current.Name}\n");
                }

                Console.WriteLine("\nВведите номер (назад b)");

                line = Console.ReadLine();

                int index;

                if (int.TryParse(line, out index) && index > 0 && index <= newspapers.Count)
                {
                    SelectElement(newspapers[index - 1]);
                }
            }
        }

        private void Add()
        {
            AbstractNewspaper newspaper = new Newspaper();

            IEnumerable<ErrorValidation> errors = default;

            do
            {
                Console.Clear();

                Console.WriteLine("Добавление газеты\n");

                if (errors != null)
                {
                    foreach (var item in errors)
                    {
                        Console.WriteLine("\t" + item.Field + ": " + item.Description + " " + item.Recommendation);
                    }
                }

                Console.WriteLine("Введите название:");

                newspaper.Name = Console.ReadLine();

                Console.WriteLine("Введите количество страниц:");

                int numberOfPage;

                newspaper.NumberOfPages = int.TryParse(Console.ReadLine(), out numberOfPage)
                                            ? numberOfPage
                                            : -1;

                Console.WriteLine("Введите описание (не обязательно):");

                newspaper.Annotation = Console.ReadLine();

                Console.WriteLine("Введите издательсво:");

                newspaper.Publisher = Console.ReadLine();

                Console.WriteLine("Введите место издательсва:");

                newspaper.PublishingCity = Console.ReadLine();

                Console.WriteLine("Введите год публикации:");

                int publishingYear;

                newspaper.PublishingYear = int.TryParse(Console.ReadLine(), out publishingYear)
                                            ? publishingYear
                                            : -1;

                Console.WriteLine("Введите номер выпуска (не обязательно):");

                if ((newspaper.Number = Console.ReadLine()).Equals(string.Empty))
                {
                    newspaper.Number = null;
                }

                Console.WriteLine("Введите дату выпуска:");

                DateTime tempData;

                if (DateTime.TryParse(Console.ReadLine(), out tempData))
                {
                    newspaper.Date = tempData;
                }
                else
                {
                    continue;
                }

                Console.WriteLine("Введите ISSN (не обязательно):");

                if ((newspaper.Issn = Console.ReadLine()).Equals(string.Empty))
                {
                    newspaper.Issn = null;
                }

            } while ((errors = _newspaperBll.Add(newspaper)).Count() != 0);
        }
    }
}

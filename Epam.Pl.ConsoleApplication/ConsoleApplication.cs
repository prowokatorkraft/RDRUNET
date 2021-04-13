using System;

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Bll.Contracts;
using Epam.Library.Bll;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.DependencyInjection;

namespace Epam.Library.Pl.ConsoleApplication
{
    public class ConsoleApplication
    {
        private readonly IAuthorBll _authorBll;

        private readonly ICatalogueBll _catalogueBll;

        private readonly IBookBll _bookBll;

        private readonly IOldNewspaperBll _newspaperBll;

        private readonly IPatentBll _patentBll;

        private readonly AuthorPresentation _authorPresentation;

        private readonly BookPresentation _bookPresentation;

        private readonly PatentPresentation _patentPresentation;

        private readonly NewspaperPresentation _newspaperPresentation;

        public ConsoleApplication()
        {
            //_authorBll = authorBll;
            //_catalogueBll = catalogueBll;
            //_bookBll = bookBll;
            //_newspaperBll = newspaperBll;
            //_patentBll = patentBll;

            _authorPresentation = new AuthorPresentation(_authorBll, _catalogueBll, _bookBll, _patentBll);
            _bookPresentation = new BookPresentation(_authorBll, _bookBll);
            _patentPresentation = new PatentPresentation(_authorBll, _patentBll);
            _newspaperPresentation = new NewspaperPresentation(_newspaperBll);
        }

        static void Main(string[] args)
        {
            var console = new ConsoleApplication();

            console.StartMenu();
        }

        private void StartMenu()
        {
            ConsoleKeyInfo keyInfo = default;

            while (keyInfo.Key != ConsoleKey.Q)
            {
                Console.Clear();

                Console.WriteLine
                (
                    "Каталог\n\n" +
                    "\t1.Книги\n" +
                    "\t2.Газеты\n" +
                    "\t3.Патенты\n" +
                    "\t4.Авторы\n" +
                    "\nВведите номер (для выхода q)"
                );

                keyInfo = Console.ReadKey(true);

                Handle(keyInfo);
            }
        }

        private void Handle(ConsoleKeyInfo keyInfo)
        {
            switch (keyInfo.Key)
            {
                case ConsoleKey.D1:
                case ConsoleKey.NumPad1:
                    _bookPresentation.StartMenu();
                    break;

                case ConsoleKey.D2:
                case ConsoleKey.NumPad2:
                    _newspaperPresentation.StartMenu();
                    break;

                case ConsoleKey.D3:
                case ConsoleKey.NumPad3:
                    _patentPresentation.StartMenu();
                    break;

                case ConsoleKey.D4:
                case ConsoleKey.NumPad4:
                    _authorPresentation.StartMenu();
                    break;

                default:
                    break;
            }
        }
    }
}

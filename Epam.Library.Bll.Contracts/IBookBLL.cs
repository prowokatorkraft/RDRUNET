using System.Collections.Generic;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBLL
    {
        int AddBook(AbstractBook book);

        int RemoveBook(AbstractBook book);

        IEnumerable<AbstractBook> GetAllBooks();

        IEnumerable<AbstractBook> GetBooksByName(string name);

        IEnumerable<AbstractBook> GetBooksByPublishingHouse(string publishingHouse);

        IEnumerable<AbstractBook> GetBooksByAutors(Autor[] autors);
    }
}

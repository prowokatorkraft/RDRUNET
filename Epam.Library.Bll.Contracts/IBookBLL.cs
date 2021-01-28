using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBll
    {
        int AddBook(AbstractBook book);

        int RemoveBook(AbstractBook book);

        IEnumerable<AbstractBook> GetAllBooks();

        IEnumerable<AbstractBook> GetAllBooks(SortOptions options);

        ILookup<int, AbstractBook> GetAllBookGroupsByPublishYear();

        IEnumerable<AbstractBook> GetBooksByName(string name);

        IEnumerable<AbstractBook> GetBooksByPublishingHouse(string publishingHouse);

        IEnumerable<AbstractBook> GetBooksByAutors(Autor[] autors);
    }
}

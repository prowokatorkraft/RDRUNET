using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;

namespace Epam.Library.Dal.Contracts
{
    public interface IBookDao
    {
        void AddBook(AbstractBook book);

        void RemoveBook(AbstractBook book);

        IEnumerable<AbstractBook> GetAllBooks(SortOptions options, BookSearchOptions searchOptions, string search);

        ILookup<int, AbstractBook> GetAllBookGroupsByPublishYear();
    }
}

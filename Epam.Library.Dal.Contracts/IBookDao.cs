using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;

namespace Epam.Library.Dal.Contracts
{
    public interface IBookDao
    {
        void AddBook(AbstractBook book);

        void RemoveBook(AbstractBook book);

        IEnumerable<AbstractBook> SearchBooks(SortOptions options, BookSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractBook>> GetAllBookGroupsByPublishYear();
    }
}

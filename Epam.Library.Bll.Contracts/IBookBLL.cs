using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBll
    {
        void AddBook(AbstractBook book);

        void RemoveBook(AbstractBook book);

        IEnumerable<AbstractBook> SearchBooks(SortOptions options, BookSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractBook>> GetAllBookGroupsByPublishYear();
    }
}

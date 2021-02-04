using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;

namespace Epam.Library.Dal.Contracts
{
    public interface IBookDao
    {
        void Add(AbstractBook book);

        bool Remove(int id);

        AbstractBook Get(int id);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractBook>> GetAllGroupsByPublishYear();
    }
}

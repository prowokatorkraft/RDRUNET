using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBll
    {
        ErrorValidation[] Add(AbstractBook book);

        bool Remove(int id);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest);

        IEnumerable<IGrouping<int, AbstractBook>> GetAllGroupsByPublishYear();
    }
}

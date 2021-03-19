using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IBookBll
    {
        IEnumerable<ErrorValidation> Add(AbstractBook book);

        IEnumerable<ErrorValidation> Update(AbstractBook book);

        bool Remove(int id);

        AbstractBook Get(int id);

        IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page);

        IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest);

        Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear();

        Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest);
    }
}
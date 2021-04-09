using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IAuthorBll
    {
        IEnumerable<ErrorValidation> Add(Author author);

        IEnumerable<ErrorValidation> Update(Author autor);

        bool Remove(int id);

        Author Get(int id);

        bool Check(int[] ids);

        IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest);
    }
}
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IAuthorBll
    {
        IEnumerable<ErrorValidation> Add(Author author);

        IEnumerable<ErrorValidation> Update(Author autor);

        bool Remove(int id, RoleType role = RoleType.None);

        Author Get(int id, RoleType role = RoleType.None);

        bool Check(int[] ids, RoleType role = RoleType.None);

        IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}
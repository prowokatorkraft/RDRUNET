using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface IAuthorDao
    {
        void Add(Author author);

        bool Remove(int id, RoleType role = RoleType.None);

        void Update(Author author);

        bool Check(int[] ids, RoleType role = RoleType.None);

        Author Get(int id, RoleType role = RoleType.None);

        IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, RoleType role = RoleType.None);
    }
}

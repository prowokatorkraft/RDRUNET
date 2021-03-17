﻿using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System.Collections.Generic;

namespace Epam.Library.Dal.Contracts
{
    public interface IAuthorDao
    {
        void Add(Author author);

        bool Remove(int id);

        void Update(Author autor);

        bool Check(int[] ids);

        Author Get(int id);

        IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest);
    }
}

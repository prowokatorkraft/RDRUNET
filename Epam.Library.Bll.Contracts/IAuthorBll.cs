﻿using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IAuthorBll
    {
        IEnumerable<ErrorValidation> Add(Author author);

        bool Remove(int id);

        Author Get(int id);

        bool Check(int[] ids);

        IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest);
    }
}
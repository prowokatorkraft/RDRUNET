﻿using System.Collections.Generic;
using System.Linq;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;

namespace Epam.Library.Dal.Contracts
{
    public interface IPatentDao
    {
        void AddPatent(AbstractPatent patent);

        void RemovePatent(AbstractPatent patent);

        IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search);

        IEnumerable<IGrouping<int, AbstractPatent>> GetAllPatentGroupsByPublishYear();
    }
}

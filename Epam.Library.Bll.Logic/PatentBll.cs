using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement.Patent;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class PatentBll : IPatentBll
    {
        protected readonly IPatentBll _dao;

        protected readonly IValidation<AbstractPatent> _validation;
        
        public PatentBll(IPatentBll patentDao, IValidation<AbstractPatent> validation)
        {
            _dao = patentDao;
            _validation = validation;
        }

        public void AddPatent(AbstractPatent patent)
        {
            try
            {
                _validation.Validate(patent);

                _dao.AddPatent(patent);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
            }
        }

        public void RemovePatent(AbstractPatent patent)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException("Patent is null!");
                }

                _dao.RemovePatent(patent);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing element!", ex);
            }
        }

        public IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search)
        {
            foreach (var item in _dao.SearchPatents(options, searchOptions, search))
            {
                yield return item;
            }
        }

        public IEnumerable<IGrouping<int, AbstractPatent>> GetAllPatentGroupsByPublishYear()
        {
            foreach (var item in _dao.GetAllPatentGroupsByPublishYear())
            {
                yield return item;
            }
        }
    }
}

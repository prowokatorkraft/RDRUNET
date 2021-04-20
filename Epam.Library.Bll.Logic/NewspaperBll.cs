using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class NewspaperBll : INewspaperBll
    {
        protected readonly INewspaperDao _dao;
        protected readonly IValidationBll<Newspaper> _validation;

        public NewspaperBll(INewspaperDao dao, IValidationBll<Newspaper> validation)
        {
            _dao = dao;
            _validation = validation;
        }

        public IEnumerable<ErrorValidation> Add(Newspaper newspaper)
        {
            try
            {
                if (newspaper is null)
                {
                    throw new ArgumentNullException(nameof(newspaper) + " is null");
                }

                var errors = _validation.Validate(newspaper);

                if (errors.Count() == 0)
                {
                    _dao.Add(newspaper);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperBll), nameof(Add), "Error adding item.", ex);
            }
        }

        public Newspaper Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperBll), nameof(Get), "Error getting item.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Remove(id, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperBll), nameof(Remove), "Error removing item.", ex);
            }
        }

        public IEnumerable<Newspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperBll), nameof(Search), "Error getting item.", ex);
            }
        }

        public IEnumerable<ErrorValidation> Update(Newspaper newspaper)
        {
            try
            {
                if (newspaper is null)
                {
                    throw new ArgumentNullException(nameof(newspaper) + " is null");
                }
                else if (newspaper.Id is null)
                {
                    throw new ArgumentNullException(nameof(newspaper.Id) + " is null");
                }

                var errors = _validation.Validate(newspaper);

                if (errors.Count() == 0)
                {
                    _dao.Update(newspaper);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperBll), nameof(Update), "Error updating item.", ex);
            }
        }
    }
}

using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll
{
    public class PatentBll : IPatentBll
    {
        protected readonly IPatentDao _dao;

        protected readonly IAuthorBll _author;

        protected readonly IValidationBll<AbstractPatent> _validation;
        
        public PatentBll(IPatentDao patentDao, IAuthorBll author, IValidationBll<AbstractPatent> validation)
        {
            _dao = patentDao;
            _validation = validation;
            _author = author;
        }

        public IEnumerable<ErrorValidation> Add(AbstractPatent patent, RoleType role = RoleType.None)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException(nameof(patent) + " is null");
                }

                if (patent.AuthorIDs != null && !_author.Check(patent.AuthorIDs, role))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(patent);

                if (errors.Count() == 0)
                {
                    _dao.Add(patent);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(Add), "Error adding item.", ex);
            }
        }

        public IEnumerable<ErrorValidation> Update(AbstractPatent patent, RoleType role = RoleType.None)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException(nameof(patent) + " is null");
                }
                else if (patent.Id is null)
                {
                    throw new ArgumentNullException(nameof(patent.Id) + " is null");
                }

                if (patent.AuthorIDs != null && !_author.Check(patent.AuthorIDs, role))
                {
                    throw new ArgumentOutOfRangeException("Incorrect AuthorIDs.");
                }

                var errors = _validation.Validate(patent);

                if (errors.Count() == 0)
                {
                    _dao.Update(patent);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(Update), "Error updating item.", ex);
            }
        }

        public AbstractPatent Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(Get), "Error getting item.", ex);
            }
        }

        public IEnumerable<AbstractPatent> GetByAuthorId(int id, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetByAuthorId(id, numberOfPageFilter: numberOfPageFilter, role: role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(GetByAuthorId), "Error getting item.", ex);
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
                throw new LayerException("Bll", nameof(PatentBll), nameof(Remove), "Error removing item.", ex);
            }
        }

        public IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(Search), "Error getting item.", ex);
            }
        }

        public Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear(PagingInfo page = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetAllGroupsByPublishYear(page: page, numberOfPageFilter: numberOfPageFilter, role: role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(PatentBll), nameof(GetAllGroupsByPublishYear), "Error getting item.", ex);
            }
        }

        public int GetCount(PatentSearchOptions searchOptions = PatentSearchOptions.None, string searchLine = null, NumberOfPageFilter numberOfPageFilter = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetCount(searchOptions, searchLine, numberOfPageFilter, role);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(NewspaperIssueBll), nameof(GetCount), "Error getting item.", ex);
            }
        }
    }
}

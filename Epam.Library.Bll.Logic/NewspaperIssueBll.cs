using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Bll.Logic
{
    public class NewspaperIssueBll : INewspaperIssueBll
    {
        protected readonly INewspaperIssueDao _dao;
        protected readonly INewspaperBll _newspaperBll;
        protected readonly IValidationBll<NewspaperIssue> _validation;

        public NewspaperIssueBll(INewspaperIssueDao dao, INewspaperBll newspaperBll, IValidationBll<NewspaperIssue> validation)
        {
            _dao = dao;
            _newspaperBll = newspaperBll;
            _validation = validation;
        }

        public IEnumerable<ErrorValidation> Add(NewspaperIssue issue, RoleType role = RoleType.None)
        {
            try
            {
                if (issue is null)
                {
                    throw new ArgumentNullException(nameof(issue) + " is null");
                }

                if (_newspaperBll.Get(issue.NewspaperId, role) is null)
                {
                    throw new ArgumentOutOfRangeException("Incorrect NewspaperId.");
                }

                var errors = _validation.Validate(issue);

                if (errors.Count() == 0)
                {
                    _dao.Add(issue);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item.", ex);
            }
        }

        public NewspaperIssue Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Get(id, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public IEnumerable<NewspaperIssue> GetAllByNewspaper(int newspaperId, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetAllByNewspaper(newspaperId, role) ?? throw new ArgumentException("Incorrect id.");
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public Dictionary<int, List<NewspaperIssue>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.GetAllGroupsByPublishYear(role: role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
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
                throw new RemoveException("Error removing item.", ex);
            }
        }

        public IEnumerable<NewspaperIssue> Search(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                return _dao.Search(searchRequest, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting item.", ex);
            }
        }

        public IEnumerable<ErrorValidation> Update(NewspaperIssue issue, RoleType role = RoleType.None)
        {
            try
            {
                if (issue is null)
                {
                    throw new ArgumentNullException(nameof(issue) + " is null");
                }
                else if (issue.Id is null)
                {
                    throw new ArgumentNullException(nameof(issue.Id) + " is null");
                }
                if (_newspaperBll.Get(issue.NewspaperId, role) is null)
                {
                    throw new ArgumentOutOfRangeException("Incorrect NewspaperId.");
                }

                var errors = _validation.Validate(issue);

                if (errors.Count() == 0)
                {
                    _dao.Update(issue);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating item.", ex);
            }
        }
    }
}

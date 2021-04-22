using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace Epam.Library.Bll
{
    public class AccountBll : IAccountBll
    {
        protected readonly IAccountDao _dao;
        protected readonly IRoleBll _roleBll;
        protected readonly IValidationBll<Account> _validation;

        public AccountBll(IAccountDao dao, IRoleBll roleDao, IValidationBll<Account> validation)
        {
            _dao = dao;
            _roleBll = roleDao;
            _validation = validation;
        }

        public IEnumerable<ErrorValidation> Add(Account account)
        {
            try
            {
                if (account is null)
                {
                    throw new ArgumentNullException(nameof(account) + " is null");
                }

                var errors = _validation.Validate(account);

                if (errors.Count() == 0)
                {
                    account.RoleId = _roleBll.GetByName("user").Id.Value;
                    account.PasswordHash = GetPasswordHash(account.Password);
                    _dao.Add(account);
                }

                return errors;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(Add),"Error adding item.", ex);
            }
        }

        public IEnumerable<Account> Search(SearchRequest<SortOptions, AccountSearchOptions> searchRequest)
        {
            try
            {
                return _dao.Search(searchRequest);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(Search), "Error getting item.", ex);
            }
        }
        public int GetCount(AccountSearchOptions searchOptions = AccountSearchOptions.None, string searchLine = null)
        {
            try
            {
                return _dao.GetCount(searchOptions, searchLine);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(GetCount), "Error getting item.", ex);
            }
        }

        public Account GetById(long id)
        {
            try
            {
                return _dao.GetById(id);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(GetById), "Error getting item.", ex);
            }
        }

        public Account GetByLogin(string login)
        {
            try
            {
                return _dao.GetByLogin(login);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(GetByLogin), "Error getting item.", ex);
            }
        }

        public bool Check(long id)
        {
            try
            {
                return _dao.Check(id);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(Check), "Error getting item.", ex);
            }
        }
        public bool Check(string login)
        {
            try
            {
                return _dao.Check(login);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(Check), "Error getting item.", ex);
            }
        }

        public bool Remove(long id)
        {
            try
            {
                return _dao.Remove(id);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(Remove), "Error removing item.", ex);
            }
        }

        public bool UpdateRole(long accountId, int roleId)
        {
            try
            {
                if (!Check(accountId))
                {
                    throw new ArgumentOutOfRangeException($"Incorrect {accountId}.");
                }
                else if (!_roleBll.Check(roleId))
                {
                    throw new ArgumentOutOfRangeException($"Incorrect {roleId}.");
                }

                _dao.UpdateRole(accountId, roleId);

                return true;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(AccountBll), nameof(UpdateRole), "Error updating item.", ex);
            }
        }

        private string GetPasswordHash(string password)
        {
            string result;

            using (SHA512 sha512 = new SHA512Managed())
            {
                byte[] data = Encoding.UTF8.GetBytes(password);
                data = sha512.ComputeHash(data);

                result = Encoding.UTF8.GetString(data);
            }

            return result;
        }
    }
}

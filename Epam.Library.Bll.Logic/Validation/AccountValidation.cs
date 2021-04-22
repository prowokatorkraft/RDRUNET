using Epam.Library.Bll.Contracts;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class AccountValidation : IValidationBll<Account>
    {
        private IAccountDao _accountDao;
        private List<ErrorValidation> _errorList;

        public AccountValidation(IAccountDao accountDao)
        {
            _accountDao = accountDao;
        }

        public IEnumerable<ErrorValidation> Validate(Account element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null."));
            }
            _errorList = new List<ErrorValidation>();

            Login(element);
            Password(element);

            return _errorList;
        }

        private void Login(Account element)
        {
            string field = nameof(element.Login);

            element.Login
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.LoginPattern, _errorList)
                .Length.CheckRange(field, ValidationLengths.MinLogin, int.MaxValue, _errorList);

            if (_accountDao.Check(element.Login))
            {
                _errorList.Add(new ErrorValidation
                (
                    field,
                    "Login cannot match password.",
                    null
                ));
            }
        }

        private void Password(Account element)
        {
            string field = nameof(element.Password);

            element.Password
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, ValidationLengths.MinPassword, int.MaxValue, _errorList);

            for (int index = 0; index < element.Password.Length; index++)
            {
                if (char.IsControl(element.Password, index))
                {
                    _errorList.Add(new ErrorValidation
                    (
                        field,
                        "Password not must include in yourself control characters.",
                        null
                    ));
                }
            }

            if (string.Equals(element.Login, element.Password, StringComparison.InvariantCultureIgnoreCase))
            {
                _errorList.Add(new ErrorValidation
                (
                    field,
                    "Login cannot match password.",
                    null
                ));
            }
        }
    }
}

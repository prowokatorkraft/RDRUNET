using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class AuthorValidation : IValidationBll<Author>
    {
        private List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(Author element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null."));
            }

            _errorList = new List<ErrorValidation>();

            FirstName(element);

            LastName(element);

            return _errorList;
        }

        private void LastName(Author element)
        {
            string field = nameof(element.LastName);

            element.LastName
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.LastNamePattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.LastNameLength, _errorList, ValidationLengths.LastNameLength + "");
        }

        private void FirstName(Author element)
        {
            string field = nameof(element.FirstName);

            element.FirstName
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.FirstNamePattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.FirstNameLength, _errorList, ValidationLengths.FirstNameLength + "");
        }
    }
}

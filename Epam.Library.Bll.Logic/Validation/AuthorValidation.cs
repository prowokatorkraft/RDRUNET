﻿using Epam.Library.Bll.Contracts;
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
            string lastNameField = nameof(element.LastName);

            element.LastName
                .CheckNull(lastNameField, _errorList)?
                .CheckMatch(lastNameField, ValidationPatterns.LastNamePattern, _errorList)
                .CheckLength(lastNameField, 0, 200, _errorList, "200");
        }

        private void FirstName(Author element)
        {
            string firstNameField = nameof(element.FirstName);

            element.FirstName
                .CheckNull(firstNameField, _errorList)?
                .CheckMatch(firstNameField, ValidationPatterns.FirstNamePattern, _errorList)
                .CheckLength(firstNameField, 0, 50, _errorList, "50");
        }
    }
}

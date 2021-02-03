using Epam.Library.Bll.Contracts;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Logic.Validation
{
    public class AuthorValidation : IValidationBll<Author>
    {
        public ErrorValidation[] Validate(Author element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null!"));
            }

            List<ErrorValidation> errorList = new List<ErrorValidation>();

            if (element.FirstName is null || !Regex.IsMatch(element.FirstName, ValidationPatterns.FirstNamePattern))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.FirstName),
                    "Incorrect entered value!",
                    null
                ));
            }
            else if (element.FirstName.Length > 50)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.FirstName),
                    "Value exceeds the allowed size!",
                    "50"
                ));
            }

            if (element.LastName is null || !Regex.IsMatch(element.LastName, ValidationPatterns.LastNamePattern))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.LastName),
                    "Incorrect entered value!",
                    null
                ));
            }
            else if (element.LastName.Length > 200)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.LastName),
                    "Value exceeds the allowed size!",
                    "200"
                ));
            }

            return errorList.ToArray();
        }
    }
}

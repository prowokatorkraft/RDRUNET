using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Validation
{
    public class PatentValidation : IValidationBll<AbstractPatent>
    {
        public IEnumerable<ErrorValidation> Validate(AbstractPatent element)
        {
            if (element is null)
            {
                throw new ArgumentNullException(nameof(element) + " is null.");
            }

            List<ErrorValidation> errorList = new List<ErrorValidation>();

            if (element.Name is null)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Name),
                    "Value is null.",
                    null
                ));
            }
            else if (element.Name.Length > 300)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Name),
                    "Value exceeds the allowed size.",
                    "300"
                ));
            }

            if (element.NumberOfPages < 0)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.NumberOfPages),
                    "The value cannot be negative.",
                    null
                ));
            }

            if (element.Annotation != null && element.Annotation.Length > 2000)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Annotation),
                    "Value exceeds the allowed size.",
                    "2000"
                ));
            }

            if (element.Country is null ||
                !Regex.IsMatch(element.Country, ValidationPatterns.CountryPattern) ||
                element.Country.Length > 200)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Country),
                    "Incorrect entered value.",
                    null
                ));
            }

            if (element.RegistrationNumber is null || !Regex.IsMatch(element.RegistrationNumber, ValidationPatterns.RegistrationNumberPattern))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.RegistrationNumber),
                    "Incorrect entered value.",
                    "The value must be no more than 9 digits."
                ));
            }

            if (element.ApplicationDate != null &&
                element.ApplicationDate.Value.Year < 1474 ||
                element.ApplicationDate.Value > DateTime.Now)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.ApplicationDate),
                    "Incorrect entered value.",
                    "Value shouldn't be less than 1474 and more than today."
                ));
            }

            if (element.DateOfPublication <= DateTime.Now &&
                (element.ApplicationDate != null && element.DateOfPublication >= element.ApplicationDate ||
                 element.DateOfPublication.Year >= 1474))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.DateOfPublication),
                    "Incorrect entered value.",
                    "Value shouldn't be less than 1474 or application date and more than today."
                ));
            }

            return errorList;
        }
    }
}

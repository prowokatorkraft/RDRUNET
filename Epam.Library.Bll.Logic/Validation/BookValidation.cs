using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Validation
{
    public class BookValidation : IValidationBll<AbstractBook>
    {
        public IEnumerable<ErrorValidation> Validate(AbstractBook element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null."));
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

            if (element.Publisher is null)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Name),
                    "Value is null.",
                    null
                ));
            }
            else if (element.Publisher.Length > 300)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Name),
                    "Value exceeds the allowed size.",
                    "300"
                ));
            }

            if (element.PublishingCity is null || !Regex.IsMatch(element.PublishingCity, ValidationPatterns.PublishingCityPattern))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.PublishingCity),
                    "Incorrect entered value.",
                    null
                ));
            }

            if (element.PublishingYear < 1400 || element.PublishingYear > DateTime.Now.Year)
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.PublishingYear),
                    "Incorrect entered value.",
                    "The value cannot be less than 1400 and more than today."
                ));
            }

            if (element.Isbn != null &&
                (!Regex.IsMatch(element.Isbn, ValidationPatterns.IsbnPattern) ||
                element.Isbn.Length != 18))
            {
                errorList.Add(new ErrorValidation
                (
                    nameof(element.Isbn),
                    "Incorrect entered value.",
                    "Value should only be 10 digits! Exmble \"ISBN 0-00-000000-0\""
                ));
            }

            return errorList;
        }
    }
}


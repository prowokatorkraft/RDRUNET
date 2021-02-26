using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using System;
using System.Collections.Generic;
using System.Globalization;

namespace Epam.Library.Bll.Validation
{
    public class PatentValidation : IValidationBll<AbstractPatent>
    {
        private List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(AbstractPatent element)
        {
            if (element is null)
            {
                throw new ArgumentNullException(nameof(element) + " is null.");
            }

            _errorList = new List<ErrorValidation>();

            Name(element);

            NumberOfPages(element);

            Annotation(element);

            Country(element);

            RegistrationNumber(element);

            ApplicationDate(element);

            DateOfPublication(element);

            return _errorList;
        }

        private void DateOfPublication(AbstractPatent element)
        {
            string field = nameof(element.DateOfPublication);

            if (element.ApplicationDate != null)
            {
                element.DateOfPublication
                    .CheckRange(
                                field,
                                element.ApplicationDate.Value,
                                DateTime.Now,
                                _errorList,
                                $"Value shouldn't be less than {element.ApplicationDate.Value.Date} and more than today."
                                );
            }
            else
            {
                element.DateOfPublication
                    .CheckRange(
                                field,
                                DateTime.Parse(ValidationLengths.MinDateOfPublicationRange, new CultureInfo("en-US")),
                                DateTime.Now,
                                _errorList,
                                $"Value shouldn't be less than {ValidationLengths.MinDateOfPublicationRange} and more than today."
                                );
            }
        }

        private void ApplicationDate(AbstractPatent element)
        {
            if (element.ApplicationDate != null)
            {
                string field = nameof(element.ApplicationDate);

                element.ApplicationDate.Value
                    .CheckRange(
                                field,
                                DateTime.Parse(ValidationLengths.MinApplicationDateRange, new CultureInfo("en-US")),
                                DateTime.Now, 
                                _errorList,
                                $"Value shouldn't be less than {ValidationLengths.MinApplicationDateRange} and more than today."
                                );
            }
        }

        private void RegistrationNumber(AbstractPatent element)
        {
            string field = nameof(element.RegistrationNumber);

            element.RegistrationNumber
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.RegistrationNumberPattern, _errorList, "The value must be no more than 9 digits.");
        }

        private void Country(AbstractPatent element)
        {
            string field = nameof(element.Country);

            element.Country
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.CountryPattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.CountryLength, _errorList, ValidationLengths.CountryLength + "");
        }

        private void Annotation(AbstractPatent element)
        {
            if (element.Annotation != null)
            {
                string field = nameof(element.Annotation);

                element.Annotation
                    .Length.CheckRange(field, 0, ValidationLengths.AnnotationLength, _errorList, ValidationLengths.AnnotationLength + "");
            }
        }

        private void NumberOfPages(AbstractPatent element)
        {
            string field = nameof(element.NumberOfPages);

            element.NumberOfPages
                .CheckRange(field, 0, int.MaxValue, _errorList);
        }

        private void Name(AbstractPatent element)
        {
            string field = nameof(element.Name);

            element.Name
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.NameLength, _errorList, ValidationLengths.NameLength + "");
        }
    }
}

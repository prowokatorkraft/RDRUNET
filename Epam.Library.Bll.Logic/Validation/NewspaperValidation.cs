using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class NewspaperValidation : IValidationBll<AbstractNewspaper>
    {
        List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(AbstractNewspaper element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null!"));
            }

            _errorList = new List<ErrorValidation>();

            Name(element);

            NumberOfPages(element);

            Annotation(element);

            Publisher(element);

            PublishingCity(element);

            PublishingYear(element);

            Date(element);

            Issn(element);

            return _errorList;
        }

        private void Issn(AbstractNewspaper element)
        {
            if (element.Issn != null)
            {
                string field = nameof(element.Issn);

                element.Issn
                    .CheckMatch(field, ValidationPatterns.IssnPattern, _errorList, "Value should only be 8 digits! Exmble \"ISSN 0000-0000\"");
            }
        }

        private void Date(AbstractNewspaper element)
        {
            string field = nameof(element.Date);

                element.Date.Year
                    .CheckRange(field, element.PublishingYear, element.PublishingYear, _errorList, "The value must match PublishingYear.");
        }

        private void PublishingYear(AbstractNewspaper element)
        {
            string field = nameof(element.PublishingYear);

            element.PublishingYear
                .CheckRange(field,
                            ValidationLengths.MinPublishingYearLength,
                            DateTime.Now.Year,
                            _errorList,
                            "The value cannot be less than " + ValidationLengths.MinPublishingYearLength + " and more than today."
                            );
        }

        private void PublishingCity(AbstractNewspaper element)
        {
            string field = nameof(element.PublishingCity);

            element.PublishingCity
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.PublishingCityPattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.PublishingCityLength, _errorList, ValidationLengths.PublishingCityLength + "");
        }

        private void Publisher(AbstractNewspaper element)
        {
            string field = nameof(element.Publisher);

            element.Publisher
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.PublisherLength, _errorList, ValidationLengths.PublisherLength + "");
        }

        private void Annotation(AbstractNewspaper element)
        {
            if (element.Annotation != null)
            {
                string field = nameof(element.Annotation);

                element.Annotation
                    .Length.CheckRange(field, 0, ValidationLengths.AnnotationLength, _errorList, ValidationLengths.AnnotationLength + "");
            }
        }

        private void NumberOfPages(AbstractNewspaper element)
        {
            string field = nameof(element.NumberOfPages);

            element.NumberOfPages
                .CheckRange(field, 0, int.MaxValue, _errorList);
        }

        private void Name(AbstractNewspaper element)
        {
            string field = nameof(element.Name);

            element.Name
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.NameLength, _errorList, ValidationLengths.NameLength + "");
        }
    }
}

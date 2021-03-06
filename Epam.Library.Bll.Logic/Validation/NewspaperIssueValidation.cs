using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class NewspaperIssueValidation : IValidationBll<NewspaperIssue>
    {
        List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(NewspaperIssue element)
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

            return _errorList;
        }

        private void Date(NewspaperIssue element)
        {
            string field = nameof(element.Date);

            element.Date.Year
                .CheckRange(field, element.PublishingYear, element.PublishingYear, _errorList, "The value must match PublishingYear.");
        }

        private void PublishingYear(NewspaperIssue element)
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

        private void PublishingCity(NewspaperIssue element)
        {
            string field = nameof(element.PublishingCity);

            element.PublishingCity
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.PublishingCityPattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.PublishingCityLength, _errorList, ValidationLengths.PublishingCityLength + "");
        }

        private void Publisher(NewspaperIssue element)
        {
            string field = nameof(element.Publisher);

            element.Publisher
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.PublisherLength, _errorList, ValidationLengths.PublisherLength + "");
        }

        private void Annotation(NewspaperIssue element)
        {
            if (element.Annotation != null)
            {
                string field = nameof(element.Annotation);

                element.Annotation
                    .Length.CheckRange(field, 0, ValidationLengths.AnnotationLength, _errorList, ValidationLengths.AnnotationLength + "");
            }
        }

        private void NumberOfPages(NewspaperIssue element)
        {
            string field = nameof(element.NumberOfPages);

            element.NumberOfPages
                .CheckRange(field, 0, int.MaxValue, _errorList);
        }

        private void Name(NewspaperIssue element)
        {
            string field = nameof(element.Name);

            element.Name
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.NameLength, _errorList, ValidationLengths.NameLength + "");
        }
    }
}

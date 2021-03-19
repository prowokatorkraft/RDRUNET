using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class BookValidation : IValidationBll<AbstractBook>
    {
        private List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(AbstractBook element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null."));
            }
            
            _errorList = new List<ErrorValidation>();

            Name(element);

            NumberOfPages(element);

            Annotation(element);

            Publisher(element);

            PublishingCity(element);

            PublishingYear(element);

            Isbn(element);

            return _errorList;
        }

        private void Isbn(AbstractBook element)
        {
            if (element.Isbn != null)
            {
                string field = nameof(element.Isbn);
                
                element.Isbn
                    .CheckMatch(field, ValidationPatterns.IsbnPattern, _errorList, "Value should only be 10 digits.")
                    .Length.CheckRange(field, ValidationLengths.IsbnLength, ValidationLengths.IsbnLength, _errorList, "Example \"ISBN 0-00-000000-0\"");
            }
        }

        private void PublishingYear(AbstractBook element)
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

        private void PublishingCity(AbstractBook element)
        {
            string field = nameof(element.PublishingCity);

            element.PublishingCity
                .CheckNull(field, _errorList)?
                .CheckMatch(field, ValidationPatterns.PublishingCityPattern, _errorList)
                .Length.CheckRange(field, 0, ValidationLengths.PublishingCityLength, _errorList, ValidationLengths.PublishingCityLength + "");
        }

        private void Publisher(AbstractBook element)
        {
            string field = nameof(element.Publisher);

            element.Publisher
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.PublisherLength, _errorList, ValidationLengths.PublisherLength + "");
        }

        private void Annotation(AbstractBook element)
        {
            if (element.Annotation != null)
            {
                string field = nameof(element.Annotation);

                element.Annotation
                    .Length.CheckRange(field, 0, ValidationLengths.AnnotationLength, _errorList, ValidationLengths.AnnotationLength + "");
            }
        }

        private void NumberOfPages(AbstractBook element)
        {
            string field = nameof(element.NumberOfPages);

            element.NumberOfPages
                .CheckRange(field, 0, int.MaxValue, _errorList);
        }

        private void Name(AbstractBook element)
        {
            string field = nameof(element.Name);

            element.Name
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.NameLength, _errorList, ValidationLengths.NameLength + "");
        }
    }
}


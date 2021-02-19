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
                string IsbnField = nameof(element.Isbn);

                element.Isbn
                    .CheckMatch(IsbnField, ValidationPatterns.IsbnPattern, _errorList, "Value should only be 10 digits.")
                    .CheckLength(IsbnField, 18, 18, _errorList, "Exmble \"ISBN 0-00-000000-0\"");
            }
        }

        private void PublishingYear(AbstractBook element)
        {
            element.PublishingYear
                .CheckSizeNumber(nameof(element.PublishingYear), 1400, DateTime.Now.Year, _errorList, "The value cannot be less than 1400 and more than today.");
        }

        private void PublishingCity(AbstractBook element)
        {
            string publishingCityField = nameof(element.PublishingCity);

            element.PublishingCity
                .CheckNull(publishingCityField, _errorList)?
                .CheckMatch(publishingCityField, ValidationPatterns.PublishingCityPattern, _errorList)
                .CheckLength(publishingCityField, 0, 200, _errorList, "200");
        }

        private void Publisher(AbstractBook element)
        {
            string publisherField = nameof(element.Publisher);

            element.Publisher
                .CheckNull(publisherField, _errorList)?
                .CheckLength(publisherField, 0, 300, _errorList, "300");
        }

        private void Annotation(AbstractBook element)
        {
            if (element.Annotation != null)
            {
                element.Annotation
                    .CheckLength(nameof(element.Annotation), 0, 2000, _errorList, "2000");
            }
        }

        private void NumberOfPages(AbstractBook element)
        {
            element.NumberOfPages
                .CheckSizeNumber(nameof(element.NumberOfPages), 0, null, _errorList);
        }

        private void Name(AbstractBook element)
        {
            string nameField = nameof(element.Name);

            element.Name
                .CheckNull(nameField, _errorList)?
                .CheckLength(nameField, 0, 300, _errorList, "300");
        }
    }
}


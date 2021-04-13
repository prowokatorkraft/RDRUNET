using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll.Validation
{
    public class NewspaperValidation : IValidationBll<Newspaper>
    {
        List<ErrorValidation> _errorList;

        public IEnumerable<ErrorValidation> Validate(Newspaper element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null!"));
            }

            _errorList = new List<ErrorValidation>();

            Name(element);

            Issn(element);

            return _errorList;
        }

        private void Issn(Newspaper element)
        {
            if (element.Issn != null)
            {
                string field = nameof(element.Issn);

                element.Issn
                    .CheckMatch(field, ValidationPatterns.IssnPattern, _errorList, "Value should only be 8 digits! Exmble \"ISSN 0000-0000\"");
            }
        }

        private void Name(Newspaper element)
        {
            string field = nameof(element.Name);

            element.Name
                .CheckNull(field, _errorList)?
                .Length.CheckRange(field, 0, ValidationLengths.NameLength, _errorList, ValidationLengths.NameLength + "");
        }
    }
}

using Epam.Library.Common.Entities;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Validation
{
    public static class ValidationHandler
    {
        public static string CheckNull(this string element, string field, List<ErrorValidation> errorList)
        {
            if (element == null)
            {
                errorList.Add(new ErrorValidation
                (
                    field,
                    "Incorrect entered value.",
                    null
                ));
            }

            return element;
        }

        public static string CheckMatch(this string element, string field, string pattern, List<ErrorValidation> errorList, string recommendation = null)
        {
            if (!Regex.IsMatch(element, pattern))
            {
                errorList.Add(new ErrorValidation
                (
                    field,
                    "Incorrect entered value.",
                    recommendation
                ));
            }

            return element;
        }

        public static string CheckLength(this string element, string field, int min, int max, List<ErrorValidation> errorList, string recommendation = null)
        {
            int lenght = element.Length;

            if (lenght < min || lenght > max)
            {
                errorList.Add(new ErrorValidation
                (
                    field,
                    "Value exceeds the allowed size.",
                    recommendation
                ));
            }

            return element;
        }

        public static int CheckSizeNumber(this int element, string field, int? min, int? max, List<ErrorValidation> errorList, string recommendation = null)
        {
            if (min != null && element < min || max != null && element > max)
            {
                errorList.Add(new ErrorValidation
                (
                    field,
                    "Value exceeds the allowed size.",
                    recommendation
                ));
            }

            return element;
        }

        
    }
}

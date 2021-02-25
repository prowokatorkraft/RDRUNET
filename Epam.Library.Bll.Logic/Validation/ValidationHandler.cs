using Epam.Library.Common.Entities;
using System;
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

        public static T CheckRange<T>(this T element, string field, T min, T max, List<ErrorValidation> errorList, string recommendation = null)
            where T : IComparable<T>
        {
            if (min != null && element.CompareTo(min) < 0 ||
                max != null && element.CompareTo(max) > 0)
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

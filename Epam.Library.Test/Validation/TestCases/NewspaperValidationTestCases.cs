using NUnit.Framework;
using System;
using System.Collections;
using System.Globalization;

namespace Epam.Library.Test.Validation.TestCases
{
    public static class NewspaperValidationTestCases
    {
        public static IEnumerable ValidateIssnTestCases
        {
            get
            {
                yield return new TestCaseData("ISSN 1234-5678").Returns(false);

                yield return new TestCaseData("").Returns(true);
                yield return new TestCaseData("1234-5678").Returns(true);
                yield return new TestCaseData("ISSN-1234-5678").Returns(true);
                yield return new TestCaseData("ISSN 1234 5678").Returns(true);
                yield return new TestCaseData("ISSN 234-05678").Returns(true);
                yield return new TestCaseData("ISSN 01234-678").Returns(true);
                yield return new TestCaseData("ISSN 1234-05678").Returns(true);
                yield return new TestCaseData("ISSN 01234-5678").Returns(true);
            }
        }
    }
}

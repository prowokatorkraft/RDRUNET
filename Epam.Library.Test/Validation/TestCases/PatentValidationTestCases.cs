using NUnit.Framework;
using System;
using System.Collections;
using System.Globalization;

namespace Epam.Library.Test.Validation.TestCases
{
    public static class PatentValidationTestCases
    {
        public static IEnumerable ValidateCountryTestCases
        {
            get
            {
                yield return new TestCaseData("Test").Returns(false);
                yield return new TestCaseData("Te").Returns(false);
                yield return new TestCaseData("TES").Returns(false);
                yield return new TestCaseData("Тест").Returns(false);
                yield return new TestCaseData("ТЕС").Returns(false);

                yield return new TestCaseData(null).Returns(true);
                yield return new TestCaseData("test").Returns(true);
                yield return new TestCaseData("Tesт").Returns(true);
                yield return new TestCaseData("TEST").Returns(true);
                yield return new TestCaseData("тест").Returns(true);
                yield return new TestCaseData("Тесt").Returns(true);
                yield return new TestCaseData("ТЕСТ").Returns(true);
            }
        }

        public static IEnumerable ValidateRegistrationNumberTestCases
        {
            get
            {
                yield return new TestCaseData("123456789").Returns(false);

                yield return new TestCaseData(null).Returns(true);
                yield return new TestCaseData("").Returns(true);
                yield return new TestCaseData("1234567890").Returns(true);
            }
        }

        public static IEnumerable ValidateApplicationDateTestCases
        {
            get
            {
                yield return new TestCaseData(null).Returns(false);
                yield return new TestCaseData(DateTime.Parse("01.01.1474", new CultureInfo("en-US"))).Returns(false);

                yield return new TestCaseData(DateTime.Parse("01.01.1473", new CultureInfo("en-US"))).Returns(true);
            }
        }

        public static IEnumerable ValidateDateOfPublicationTestCases
        {
            get
            {
                yield return new TestCaseData(null, DateTime.Parse("01.01.1474", new CultureInfo("en-US"))).Returns(false);
                yield return new TestCaseData(DateTime.Parse("01.01.1700", new CultureInfo("en-US")), DateTime.Parse("01.01.1700", new CultureInfo("en-US"))).Returns(false);

                yield return new TestCaseData(null, DateTime.Parse("01.01.1473", new CultureInfo("en-US"))).Returns(true);
                yield return new TestCaseData(DateTime.Parse("01.01.1700", new CultureInfo("en-US")), DateTime.Parse("01.01.1699", new CultureInfo("en-US"))).Returns(true);
            }
        }
    }
}
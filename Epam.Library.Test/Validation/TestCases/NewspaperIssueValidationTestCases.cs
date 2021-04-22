using NUnit.Framework;
using System;
using System.Collections;
using System.Globalization;

namespace Epam.Library.Test.Validation.TestCases
{
    public static class NewspaperIssueValidationTestCases
    {
        public static IEnumerable ValidatePublishingCityTestCases
        {
            get
            {
                yield return new TestCaseData("Test").Returns(false);
                yield return new TestCaseData("Test-Test").Returns(false);
                yield return new TestCaseData("Test-test-Test").Returns(false);
                yield return new TestCaseData("Test Test").Returns(false);
                yield return new TestCaseData("Test test").Returns(false);
                yield return new TestCaseData("Тест").Returns(false);
                yield return new TestCaseData("Тест-Тест").Returns(false);
                yield return new TestCaseData("Тест-тест-Тест").Returns(false);
                yield return new TestCaseData("Тест Тест").Returns(false);
                yield return new TestCaseData("Тест тест").Returns(false);

                yield return new TestCaseData(null).Returns(true);
                yield return new TestCaseData("test").Returns(true);
                yield return new TestCaseData("-test").Returns(true);
                yield return new TestCaseData("test-").Returns(true);
                yield return new TestCaseData("test-Test").Returns(true);
                yield return new TestCaseData("Test-test").Returns(true);
                yield return new TestCaseData("Test - Test").Returns(true);
                yield return new TestCaseData("Test-Тест").Returns(true);
                yield return new TestCaseData("Test-Test-Test").Returns(true);
                yield return new TestCaseData("тест").Returns(true);
                yield return new TestCaseData("-тест").Returns(true);
                yield return new TestCaseData("тест-").Returns(true);
                yield return new TestCaseData("тест-Тест").Returns(true);
                yield return new TestCaseData("Тест-тест").Returns(true);
                yield return new TestCaseData("-Тест-Тест").Returns(true);
                yield return new TestCaseData("Тест-Тест-").Returns(true);
                yield return new TestCaseData("Тест-Тест-Тест").Returns(true);
            }
        }

        public static IEnumerable ValidatePublishingYearTestCases
        {
            get
            {
                yield return new TestCaseData(1400).Returns(false);
                yield return new TestCaseData(DateTime.Now.Year).Returns(false);

                yield return new TestCaseData(1399).Returns(true);
                yield return new TestCaseData(DateTime.Now.AddYears(1).Year).Returns(true);
            }
        }

        public static IEnumerable ValidateDateTestCases
        {
            get
            {
                yield return new TestCaseData(2020, DateTime.Parse("01.01.2020", new CultureInfo("en-US"))).Returns(false);

                yield return new TestCaseData(2019, DateTime.Parse("01.01.2020", new CultureInfo("en-US"))).Returns(true);
                yield return new TestCaseData(2021, DateTime.Parse("01.01.2020", new CultureInfo("en-US"))).Returns(true);
            }
        }
    }
}

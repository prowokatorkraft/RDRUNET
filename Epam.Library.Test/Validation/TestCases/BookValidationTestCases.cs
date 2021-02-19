using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.Test.Validation.TestCases
{
    public static class BookValidationTestCases
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

        public static IEnumerable ValidateIsbnCases
        {
            get
            {
                yield return new TestCaseData(null).Returns(false);
                yield return new TestCaseData("ISBN 00000-00-00-0").Returns(false);
                yield return new TestCaseData("ISBN 0-0000000-0-0").Returns(false);
                yield return new TestCaseData("ISBN 0-0-0000000-0").Returns(false);
                yield return new TestCaseData("ISBN 0-00-000000-X").Returns(false);

                yield return new TestCaseData("").Returns(true);
                yield return new TestCaseData("00000-00-00-0").Returns(true);
                yield return new TestCaseData("ISBN 000000-00-0-0").Returns(true);
                yield return new TestCaseData("ISBN 0-000000-0-0").Returns(true);
                yield return new TestCaseData("ISBN 0-0-00000000").Returns(true);
                yield return new TestCaseData("ISBN 0-00-00000-00").Returns(true);
            }
        }
    }
}

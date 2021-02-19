using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.Test.Validation.TestCases
{
    public static class AuthorValidationTestCases
    {
        public static IEnumerable ValidateFirstNameTestCases
        {
            get
            {
                yield return new TestCaseData("Тест").Returns(false);
                yield return new TestCaseData("Тест-Тест").Returns(false);
                yield return new TestCaseData("Test").Returns(false);
                yield return new TestCaseData("Test-Test").Returns(false);

                yield return new TestCaseData("тест").Returns(true);
                yield return new TestCaseData("-тест").Returns(true);
                yield return new TestCaseData("тест-").Returns(true);
                yield return new TestCaseData("Тест-тест").Returns(true);
                yield return new TestCaseData("тест-Тест").Returns(true);
                yield return new TestCaseData("-Test").Returns(true);
                yield return new TestCaseData("Test-").Returns(true);
                yield return new TestCaseData("-Test-Test").Returns(true);
                yield return new TestCaseData("Test-Test-").Returns(true);
                yield return new TestCaseData("Test-Тест").Returns(true);
            }
        }

        public static IEnumerable ValidateLastNameTestCases
        {
            get
            {
                yield return new TestCaseData("Тест").Returns(false);
                yield return new TestCaseData("тест Тест").Returns(false);
                yield return new TestCaseData("Тест-Тест").Returns(false);
                yield return new TestCaseData("Тест'Тест").Returns(false);
                yield return new TestCaseData("Test").Returns(false);
                yield return new TestCaseData("test Test").Returns(false);
                yield return new TestCaseData("Test-Test").Returns(false);
                yield return new TestCaseData("Test'Test").Returns(false);

                yield return new TestCaseData("тест").Returns(true);
                yield return new TestCaseData("-тест").Returns(true);
                yield return new TestCaseData("тест-").Returns(true);
                yield return new TestCaseData("'тест").Returns(true);
                yield return new TestCaseData("тест'").Returns(true);
                yield return new TestCaseData("Тест Тест").Returns(true);
                yield return new TestCaseData("тест-Тест").Returns(true);
                yield return new TestCaseData("Тест-тест").Returns(true);
                yield return new TestCaseData("Тест'тест").Returns(true);
                yield return new TestCaseData("тест'Тест").Returns(true);
                yield return new TestCaseData("test").Returns(true);
                yield return new TestCaseData("-test").Returns(true);
                yield return new TestCaseData("test-").Returns(true);
                yield return new TestCaseData("'test").Returns(true);
                yield return new TestCaseData("test'").Returns(true);
                yield return new TestCaseData("Test Test").Returns(true);
                yield return new TestCaseData("test-Test").Returns(true);
                yield return new TestCaseData("Test-test").Returns(true);
                yield return new TestCaseData("Test'test").Returns(true);
                yield return new TestCaseData("test'Test").Returns(true);
                yield return new TestCaseData("Тест-Test").Returns(true);
            }
        }
    }
}

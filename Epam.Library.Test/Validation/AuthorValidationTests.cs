using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.AuthorElement;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class AuthorValidationTests
    {
        [TestCase("Тест")]
        [TestCase("Тест-Тест")]
        [TestCase("Test")]
        [TestCase("Test-Test")]
        public void ValidateTrueAuthorFirstNameTest(string value)
        {
            Author author = new Author();

            author.FirstName = value;

            var result = new AuthorValidation().Validate(author);

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(author.FirstName))));
        }

        [TestCase("тест")]
        [TestCase("-тест")]
        [TestCase("тест-")]
        [TestCase("Тест-тест")]
        [TestCase("тест-Тест")]
        [TestCase("-Test")]
        [TestCase("Test-")]
        [TestCase("-Test-Test")]
        [TestCase("Test-Test-")]
        [TestCase("Test-Тест")]
        public void ValidateFalseAuthorFirstNameTest(string value)
        {
            Author author = new Author();

            author.FirstName = value;

            var result = new AuthorValidation().Validate(author);

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(author.FirstName))));
        }

        [TestCase('t', 50, ExpectedResult = false)]
        [TestCase('t', 51, ExpectedResult = true)]
        public bool ValidateSizeInAuthorFirstNameTest(char value, int count)
        {
            Author author = new Author();

            author.FirstName = char.ToUpper(value) + new string(value, count - 1);

            var result = new AuthorValidation().Validate(author);

            return result.Any(a => a.Field.Equals(nameof(author.FirstName)));
        }

        [TestCase("Тест")]
        [TestCase("тест Тест")]
        [TestCase("Тест-Тест")]
        [TestCase("Тест'Тест")]
        [TestCase("Test")]
        [TestCase("test Test")]
        [TestCase("Test-Test")]
        [TestCase("Test'Test")]
        public void ValidateTrueAuthorLastNameTest(string value)
        {
            Author author = new Author();

            author.LastName = value;

            var result = new AuthorValidation().Validate(author);

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(author.LastName))));
        }

        [TestCase("тест")]
        [TestCase("-тест")]
        [TestCase("тест-")]
        [TestCase("'тест")]
        [TestCase("тест'")]
        [TestCase("Тест Тест")]
        [TestCase("тест-Тест")]
        [TestCase("Тест-тест")]
        [TestCase("Тест'тест")]
        [TestCase("тест'Тест")]
        [TestCase("test")]
        [TestCase("-test")]
        [TestCase("test-")]
        [TestCase("'test")]
        [TestCase("test'")]
        [TestCase("Test Test")]
        [TestCase("test-Test")]
        [TestCase("Test-test")]
        [TestCase("Test'test")]
        [TestCase("test'Test")]
        [TestCase("Тест-Test")]
        public void ValidateFalseAuthorLastNameTest(string value)
        {
            Author author = new Author();

            author.LastName = value;

            var result = new AuthorValidation().Validate(author);

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(author.LastName))));
        }

        [TestCase('t', 200, ExpectedResult = false)]
        [TestCase('t', 201, ExpectedResult = true)]
        public bool ValidateSizeInAuthorLastNameTest(char value, int count)
        {
            Author author = new Author();

            author.LastName = char.ToUpper(value) + new string(value, count - 1);

            var result = new AuthorValidation().Validate(author);

            return result.Any(a => a.Field.Equals(nameof(author.LastName)));
        }
    }
}

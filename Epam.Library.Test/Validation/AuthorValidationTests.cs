using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Test.Validation.TestCases;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class AuthorValidationTests
    {
        [TestCaseSource(typeof(AuthorValidationTestCases), nameof(AuthorValidationTestCases.ValidateFirstNameTestCases))]
        public bool Validate_FirstName(string value)
        {
            Author author = new Author();

            author.FirstName = value;

            var result = new AuthorValidation().Validate(author);

            return result.Any(a => a.Field.Equals(nameof(author.FirstName)));
        }

        [TestCase('t', 50, ExpectedResult = false)]
        [TestCase('t', 51, ExpectedResult = true)]
        public bool Validate_FirstName_Size(char value, int count)
        {
            Author author = new Author();

            author.FirstName = char.ToUpper(value) + new string(value, count - 1);

            var result = new AuthorValidation().Validate(author);

            return result.Any(a => a.Field.Equals(nameof(author.FirstName)));
        }

        [TestCaseSource(typeof(AuthorValidationTestCases), nameof(AuthorValidationTestCases.ValidateLastNameTestCases))]
        public bool Validate_LastName(string value)
        {
            Author author = new Author();

            author.LastName = value;

            var result = new AuthorValidation().Validate(author);

            return result.Any(a => a.Field.Equals(nameof(author.LastName)));
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

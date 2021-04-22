using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Test.Validation.TestCases;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class NewspaperValidationTests
    {
        [Test]
        public void Validate_Name_Null()
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Name = null;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(newspaper.Name))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Name_Size(char value, int count)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Name = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Name)));
        }

        [TestCaseSource(typeof(NewspaperValidationTestCases), nameof(NewspaperValidationTestCases.ValidateIssnTestCases))]
        public bool Validate_Issn(string value)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Issn = value;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Issn)));
        }
    }
}

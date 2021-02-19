using System;
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

        [Test]
        public void Validate_Annotation_Null()
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Annotation = null;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(newspaper.Annotation))));
        }

        [TestCase('t', 2000, ExpectedResult = false)]
        [TestCase('t', 2001, ExpectedResult = true)]
        public bool Validate_Annotation_Size(char value, int count)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Annotation = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Annotation)));
        }

        [Test]
        public void Validate_NumberOfPages_Negative()
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.NumberOfPages = -3;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(newspaper.NumberOfPages))));
        }

        [Test]
        public void Validate_Publisher_Null()
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Publisher = null;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(newspaper.Publisher))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Publisher_Size(char value, int count)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.Publisher = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Publisher)));
        }

        [TestCaseSource(typeof(NewspaperValidationTestCases), nameof(NewspaperValidationTestCases.ValidatePublishingCityTestCases))]
        public bool Validate_PublishingCity(string value)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.PublishingCity = value;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.PublishingCity)));
        }

        [TestCase('t', 200, ExpectedResult = false)]
        [TestCase('t', 201, ExpectedResult = true)]
        public bool Validate_PublishingCity_Size(char value, int count)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.PublishingCity = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.PublishingCity)));
        }

        [TestCaseSource(typeof(NewspaperValidationTestCases), nameof(NewspaperValidationTestCases.ValidatePublishingYearTestCases))]
        public bool Validate_PublishingYear(int value)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.PublishingYear = value;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.PublishingYear)));
        }

        [TestCaseSource(typeof(NewspaperValidationTestCases), nameof(NewspaperValidationTestCases.ValidateDateTestCases))]
        public bool Validate_DateOfPublication(int publishingYear, DateTime date)
        {
            // Arrange

            Newspaper newspaper = new Newspaper();
            newspaper.PublishingYear = publishingYear;
            newspaper.Date = date;

            // Act

            var result = new NewspaperValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Date)));
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

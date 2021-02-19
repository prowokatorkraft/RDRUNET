using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Test.Validation.TestCases;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class BookValidationTests
    {
        [Test]
        public void Validate_Name_Null()
        {
            // Arrange

            Book book = new Book();
            book.Name = null;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(book.Name))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Name_Size(char value, int count)
        {
            // Arrange

            Book book = new Book();
            book.Name = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.Name)));
        }

        [Test]
        public void Validate_Annotation_Null()
        {
            // Arrange

            Book book = new Book();
            book.Annotation = null;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(book.Annotation))));
        }

        [TestCase('t', 2000, ExpectedResult = false)]
        [TestCase('t', 2001, ExpectedResult = true)]
        public bool Validate_Annotation_Size(char value, int count)
        {
            // Arrange

            Book book = new Book();
            book.Annotation = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.Annotation)));
        }

        [Test]
        public void Validate_NumberOfPages_Negative()
        {
            // Arrange

            Book book = new Book();
            book.NumberOfPages = -3;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(book.NumberOfPages))));
        }

        [Test]
        public void Validate_Publisher_Null()
        {
            // Arrange

            Book book = new Book();
            book.Publisher = null;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(book.Publisher))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Publisher_Size(char value, int count)
        {
            // Arrange

            Book book = new Book();
            book.Publisher = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.Publisher)));
        }

        [TestCaseSource(typeof(BookValidationTestCases), nameof(BookValidationTestCases.ValidatePublishingCityTestCases))]
        public bool Validate_PublishingCity(string value)
        {
            // Arrange

            Book book = new Book();
            book.PublishingCity= value;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.PublishingCity)));
        }

        [TestCase('t', 200, ExpectedResult = false)]
        [TestCase('t', 201, ExpectedResult = true)]
        public bool Validate_PublishingCity_Size(char value, int count)
        {
            // Arrange

            Book book = new Book();
            book.PublishingCity = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.PublishingCity)));
        }

        [TestCaseSource(typeof(BookValidationTestCases), nameof(BookValidationTestCases.ValidatePublishingYearTestCases))]
        public bool Validate_PublishingYear(int value)
        {
            // Arrange

            Book book = new Book();
            book.PublishingYear = value;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.PublishingYear)));
        }

        [TestCaseSource(typeof(BookValidationTestCases), nameof(BookValidationTestCases.ValidateIsbnCases))]
        public bool Validate_Isbn(string value)
        {
            // Arrange

            Book book = new Book();
            book.Isbn = value;

            // Act

            var result = new BookValidation().Validate(book);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(book.Isbn)));
        }
    }
}

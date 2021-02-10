using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class BookValidationTest
    {
        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool ValidateSizeInBookNameTest(char value, int count)
        {
            Book book = new Book();

            book.Name = char.ToUpper(value) + new string(value, count - 1);

            var result = new BookValidation().Validate(book);

            return result.Any(a => a.Field.Equals(nameof(book.Name)));
        }

        [Test]
        public void ValidateBookAnnotationByNullTest()
        {
            Book book = new Book();

            book.Annotation = null;

            var result = new BookValidation().Validate(book);

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(book.Annotation))));
        }

        [TestCase('t', 2000, ExpectedResult = false)]
        [TestCase('t', 2001, ExpectedResult = true)]
        public bool ValidateSizeInBookAnnotationTest(char value, int count)
        {
            Book book = new Book();

            book.Annotation = char.ToUpper(value) + new string(value, count - 1);

            var result = new BookValidation().Validate(book);

            return result.Any(a => a.Field.Equals(nameof(book.Annotation)));
        }

        [Test]
        public void ValidateBookNumberOfPagesByNegativeTest()
        {
            Book book = new Book();

            book.NumberOfPages = -3;

            var result = new BookValidation().Validate(book);

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(book.NumberOfPages))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool ValidateSizeInBookPublisherTest(char value, int count)
        {
            Book book = new Book();

            book.Publisher = char.ToUpper(value) + new string(value, count - 1);

            var result = new BookValidation().Validate(book);

            return result.Any(a => a.Field.Equals(nameof(book.Publisher)));
        }

        [TestCase("Test")]
        [TestCase("Test-Test")]
        [TestCase("Test-test-Test")]
        [TestCase("Test Test")]
        [TestCase("Test test")]
        [TestCase("Тест")]
        [TestCase("Тест-Тест")]
        [TestCase("Тест-тест-Тест")]
        [TestCase("Тест Тест")]
        [TestCase("Тест тест")]
        public void ValidateTrueBookPublishingCityTest(string value)
        {
            Book book = new Book();

            book.PublishingCity= value;

            var result = new BookValidation().Validate(book);

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(book.PublishingCity))));
        }

        [TestCase("test")]
        [TestCase("-test")]
        [TestCase("test-")]
        [TestCase("test-Test")]
        [TestCase("Test-test")]
        [TestCase("Test - Test")]
        [TestCase("Test-Тест")]
        [TestCase("Test-Test-Test")]
        [TestCase("тест")]
        [TestCase("-тест")]
        [TestCase("тест-")]
        [TestCase("тест-Тест")]
        [TestCase("Тест-тест")]
        [TestCase("-Тест-Тест")]
        [TestCase("Тест-Тест-")]
        [TestCase("Тест-Тест-Тест")]
        public void ValidateFalseBookPublishingCityTest(string value)
        {
            Book book = new Book();

            book.PublishingCity = value;

            var result = new BookValidation().Validate(book);

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(book.PublishingCity))));
        }

        [TestCase('t', 200, ExpectedResult = false)]
        [TestCase('t', 201, ExpectedResult = true)]
        public bool ValidateSizeInBookPublishingCityTest(char value, int count)
        {
            Book book = new Book();

            book.PublishingCity = char.ToUpper(value) + new string(value, count - 1);

            var result = new BookValidation().Validate(book);

            return result.Any(a => a.Field.Equals(nameof(book.PublishingCity)));
        }

        //// TODO PublishingYear and Isbn
    }
}

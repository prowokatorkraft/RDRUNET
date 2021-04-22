using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Test.Validation.TestCases;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class NewspaperIssueValidationTests
    {
        [Test]
        public void Validate_Name_Null()
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Name = null;

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(issue.Name))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Name_Size(char value, int count)
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Name = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(issue.Name)));
        }

        [Test]
        public void Validate_Annotation_Null()
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Annotation = null;

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(issue.Annotation))));
        }

        [TestCase('t', 2000, ExpectedResult = false)]
        [TestCase('t', 2001, ExpectedResult = true)]
        public bool Validate_Annotation_Size(char value, int count)
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Annotation = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(issue.Annotation)));
        }

        [Test]
        public void Validate_NumberOfPages_Negative()
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.NumberOfPages = -3;

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(issue.NumberOfPages))));
        }

        [Test]
        public void Validate_Publisher_Null()
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Publisher = null;

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(issue.Publisher))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Publisher_Size(char value, int count)
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.Publisher = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(issue.Publisher)));
        }

        [TestCaseSource(typeof(NewspaperIssueValidationTestCases), nameof(NewspaperIssueValidationTestCases.ValidatePublishingCityTestCases))]
        public bool Validate_PublishingCity(string value)
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.PublishingCity = value;

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(issue.PublishingCity)));
        }

        [TestCase('t', 200, ExpectedResult = false)]
        [TestCase('t', 201, ExpectedResult = true)]
        public bool Validate_PublishingCity_Size(char value, int count)
        {
            // Arrange

            NewspaperIssue issue = new NewspaperIssue();
            issue.PublishingCity = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new NewspaperIssueValidation().Validate(issue);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(issue.PublishingCity)));
        }

        [TestCaseSource(typeof(NewspaperIssueValidationTestCases), nameof(NewspaperIssueValidationTestCases.ValidatePublishingYearTestCases))]
        public bool Validate_PublishingYear(int value)
        {
            // Arrange

            NewspaperIssue newspaper = new NewspaperIssue();
            newspaper.PublishingYear = value;

            // Act

            var result = new NewspaperIssueValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.PublishingYear)));
        }

        [TestCaseSource(typeof(NewspaperIssueValidationTestCases), nameof(NewspaperIssueValidationTestCases.ValidateDateTestCases))]
        public bool Validate_DateOfPublication(int publishingYear, DateTime date)
        {
            // Arrange

            NewspaperIssue newspaper = new NewspaperIssue();
            newspaper.PublishingYear = publishingYear;
            newspaper.Date = date;

            // Act

            var result = new NewspaperIssueValidation().Validate(newspaper);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(newspaper.Date)));
        }
    }
}

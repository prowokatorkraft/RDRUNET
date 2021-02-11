using System;
using System.Linq;
using Epam.Library.Bll.Validation;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Test.Validation.TestCases;
using NUnit.Framework;

namespace Epam.Library.Test.Validation
{
    [TestFixture]
    public class PatentValidationTests
    {
        [Test]
        public void Validate_Name_Null()
        {
            // Arrange

            Patent patent = new Patent();
            patent.Name = null;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(patent.Name))));
        }

        [TestCase('t', 300, ExpectedResult = false)]
        [TestCase('t', 301, ExpectedResult = true)]
        public bool Validate_Name_Size(char value, int count)
        {
            // Arrange

            Patent patent = new Patent();
            patent.Name = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.Name)));
        }

        [Test]
        public void Validate_Annotation_Null()
        {
            // Arrange

            Patent patent = new Patent();
            patent.Annotation = null;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            Assert.IsFalse(result.Any(a => a.Field.Equals(nameof(patent.Annotation))));
        }

        [TestCase('t', 2000, ExpectedResult = false)]
        [TestCase('t', 2001, ExpectedResult = true)]
        public bool Validate_Annotation_Size(char value, int count)
        {
            // Arrange

            Patent patent = new Patent();
            patent.Annotation = char.ToUpper(value) + new string(value, count - 1);

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.Annotation)));
        }

        [Test]
        public void Validate_NumberOfPages_Negative()
        {
            // Arrange

            Patent patent = new Patent();
            patent.NumberOfPages = -3;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            Assert.IsTrue(result.Any(a => a.Field.Equals(nameof(patent.NumberOfPages))));
        }

        [TestCaseSource(typeof(PatentValidationTestCases), nameof(PatentValidationTestCases.ValidateCountryTestCases))]
        public bool Validate_Country(string value)
        {
            // Arrange

            Patent patent = new Patent();
            patent.Country = value;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.Country)));
        }

        [TestCaseSource(typeof(PatentValidationTestCases), nameof(PatentValidationTestCases.ValidateRegistrationNumberTestCases))]
        public bool Validate_RegistrationNumber(string value)
        {
            // Arrange

            Patent patent = new Patent();
            patent.RegistrationNumber = value;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.RegistrationNumber)));
        }

        [TestCaseSource(typeof(PatentValidationTestCases), nameof(PatentValidationTestCases.ValidateApplicationDateTestCases))]
        public bool Validate_ApplicationDate(DateTime? value)
        {
            // Arrange

            Patent patent = new Patent();
            patent.ApplicationDate = value;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.ApplicationDate)));
        }

        [Test]
        public void Validate_ApplicationDate_LastDate()
        {
            // Arrange

            Patent patent1 = new Patent();
            patent1.ApplicationDate = DateTime.Now;
            Patent patent2 = new Patent();
            patent2.ApplicationDate = DateTime.Now.AddYears(1);

            // Act

            var result1 = new PatentValidation().Validate(patent1);
            var result2 = new PatentValidation().Validate(patent2);

            // Assert

            Assert.Multiple(() =>
            {
                Assert.IsFalse(result1.Any(a => a.Field.Equals(nameof(patent1.ApplicationDate))));
                Assert.IsTrue(result2.Any(a => a.Field.Equals(nameof(patent2.ApplicationDate))));
            });
        }

        [TestCaseSource(typeof(PatentValidationTestCases), nameof(PatentValidationTestCases.ValidateDateOfPublicationTestCases))]
        public bool Validate_DateOfPublication(DateTime? applicationDate, DateTime dateOfPublication)
        {
            // Arrange

            Patent patent = new Patent();
            patent.ApplicationDate = applicationDate;
            patent.DateOfPublication = dateOfPublication;

            // Act

            var result = new PatentValidation().Validate(patent);

            // Assert

            return result.Any(a => a.Field.Equals(nameof(patent.DateOfPublication)));
        }

        [Test]
        public void Validate_DateOfPublication_LastDate()
        {
            // Arrange

            Patent patent1 = new Patent();
            patent1.DateOfPublication = DateTime.Now;
            Patent patent2 = new Patent();
            patent2.DateOfPublication = DateTime.Now.AddYears(1);

            // Act

            var result1 = new PatentValidation().Validate(patent1);
            var result2 = new PatentValidation().Validate(patent2);

            // Assert

            Assert.Multiple(() =>
            {
                Assert.IsFalse(result1.Any(a => a.Field.Equals(nameof(patent1.DateOfPublication))));
                Assert.IsTrue(result2.Any(a => a.Field.Equals(nameof(patent2.DateOfPublication))));
            });
        }
    }
}

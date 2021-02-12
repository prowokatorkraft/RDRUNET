using NUnit.Framework;
using Moq;
using System;
using System.Collections.Generic;
using Epam.Library.Dal.Contracts;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Bll;
using Epam.Library.Test.TestCases;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.Newspaper;

namespace Epam.Library.Test
{
    [TestFixture]
    public class NewspaperBllTests
    {
        [TestCaseSource(typeof(NewspaperBllTestCases), nameof(NewspaperBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractNewspaper>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            var errors = newspaperBll.Add(new Newspaper());

            // Assert
            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => throw new Exception());
            Mock<IValidationBll<AbstractNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(new Newspaper());

            // Assert
            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<AbstractNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(null);

            // Assert
            Assert.Throws(typeof(AddException), action);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForAdd(Action action)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Add(It.IsAny<AbstractNewspaper>())).Callback(action);
            return newspaperDao;
        }

        private static Mock<IValidationBll<AbstractNewspaper>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<AbstractNewspaper>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractNewspaper>()))
                .Returns(func);
            return validation;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<AbstractNewspaper> newspaperValue = new Mock<AbstractNewspaper>();

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForGet(() => newspaperValue.Object);

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            var newspaper = newspaperBll.Get(0);

            // Assert

            Assert.NotNull(newspaper);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForGet(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForGet(() => null);

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForGet(Func<AbstractNewspaper> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Get(It.IsAny<int>())).Returns(func);
            return newspaperDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForRemove(() => removeDao);

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            var newspaper = newspaperBll.Remove(0);

            // Assert

            return newspaper;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForRemove(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Remove(0);

            // Assert

            Assert.Throws(typeof(RemoveException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(func);
            return newspaperDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForSearch(() => new List<AbstractNewspaper>());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            var newspaper = newspaperBll.Search(new SearchRequest<SortOptions, NewspaperSearchOptions>());

            // Assert

            Assert.NotNull(newspaper);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForSearch(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Search(new SearchRequest<SortOptions, NewspaperSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForSearch(Func<IEnumerable<AbstractNewspaper>> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, NewspaperSearchOptions>>())).Returns(func);
            return newspaperDao;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForGroupsByPublishYear(() => new Dictionary<int, List<AbstractNewspaper>>());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            var newspaper = newspaperBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.NotNull(newspaper);
        }

        [Test]
        public void GetAllGroupsByPublishYear_Exception()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForGroupsByPublishYear(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForGroupsByPublishYear(Func<Dictionary<int, List<AbstractNewspaper>>> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.GetAllGroupsByPublishYear()).Returns(func);
            return newspaperDao;
        }
    }
}

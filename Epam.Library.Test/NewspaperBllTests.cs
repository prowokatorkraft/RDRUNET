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
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            var errors = newspaperBll.Add(new OldNewspaper());

            // Assert
            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => throw new Exception());
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(new OldNewspaper());

            // Assert
            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(null);

            // Assert
            Assert.Throws(typeof(AddException), action);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForAdd(Action action)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.Add(It.IsAny<AbstractOldNewspaper>())).Callback(action);
            return newspaperDao;
        }

        private static Mock<IValidationBll<AbstractOldNewspaper>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<AbstractOldNewspaper>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractOldNewspaper>()))
                .Returns(func);
            return validation;
        }

        [TestCaseSource(typeof(NewspaperBllTestCases), nameof(NewspaperBllTestCases.AddTestCases))]
        public bool Update(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            var errors = newspaperBll.Update(new OldNewspaper(0,null,0,null,false,null,null,0,null,null,DateTime.Now));

            // Assert
            return isAddDao;
        }

        [Test]
        public void Update_Exeption()
        {
            // Arrange
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => throw new Exception());
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Update(new OldNewspaper());

            // Assert
            Assert.Throws(typeof(UpdateException), action);
        }

        [Test]
        public void Update_Exeption_Null()
        {
            // Arrange
            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => { });
            Mock<IValidationBll<AbstractOldNewspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Update(null);

            // Assert
            Assert.Throws(typeof(UpdateException), action);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForUpdate(Action action)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.Update(It.IsAny<AbstractOldNewspaper>())).Callback(action);
            return newspaperDao;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<AbstractOldNewspaper> newspaperValue = new Mock<AbstractOldNewspaper>();

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForGet(() => newspaperValue.Object);

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

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForGet(() => throw new Exception());

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

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForGet(() => null);

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForGet(Func<AbstractOldNewspaper> func)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.Get(It.IsAny<int>())).Returns(func);
            return newspaperDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForRemove(() => removeDao);

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

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForRemove(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Remove(0);

            // Assert

            Assert.Throws(typeof(RemoveException), newspaper);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(func);
            return newspaperDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForSearch(() => new List<AbstractOldNewspaper>());

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

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForSearch(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.Search(new SearchRequest<SortOptions, NewspaperSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForSearch(Func<IEnumerable<AbstractOldNewspaper>> func)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, NewspaperSearchOptions>>())).Returns(func);
            return newspaperDao;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForGroupsByPublishYear(() => new Dictionary<int, List<AbstractOldNewspaper>>());

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

            Mock<IOldNewspaperDao> newspaperDao = InitializeMockDaoForGroupsByPublishYear(() => throw new Exception());

            var newspaperBll = new NewspaperBll(newspaperDao.Object, null);

            // Act

            TestDelegate newspaper = () => newspaperBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(GetException), newspaper);
        }

        private static Mock<IOldNewspaperDao> InitializeMockDaoForGroupsByPublishYear(Func<Dictionary<int, List<AbstractOldNewspaper>>> func)
        {
            var newspaperDao = new Mock<IOldNewspaperDao>();
            newspaperDao.Setup(a => a.GetAllGroupsByPublishYear(It.IsAny<PagingInfo>())).Returns(func);
            return newspaperDao;
        }
    }
}

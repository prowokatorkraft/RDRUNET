using NUnit.Framework;
using Moq;
using System;
using System.Collections.Generic;
using Epam.Library.Dal.Contracts;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Bll;
using Epam.Library.Test.TestCases;
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
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => listErrors);
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
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(new Newspaper());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForAdd(Action action)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Add(It.IsAny<Newspaper>())).Callback(action);
            return newspaperDao;
        }

        private static Mock<IValidationBll<Newspaper>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<Newspaper>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<Newspaper>()))
                .Returns(func);
            return validation;
        }

        [TestCaseSource(typeof(NewspaperBllTestCases), nameof(NewspaperBllTestCases.AddTestCases))]
        public bool Update(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            var errors = newspaperBll.Update(new Newspaper(0, null, null, false));

            // Assert
            return isAddDao;
        }

        [Test]
        public void Update_Exeption()
        {
            // Arrange
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => throw new Exception());
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Update(new Newspaper());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Update_Exeption_Null()
        {
            // Arrange
            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForUpdate(() => { });
            Mock<IValidationBll<Newspaper>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperBll(newspaperDao.Object, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Update(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForUpdate(Action action)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Update(It.IsAny<Newspaper>())).Callback(action);
            return newspaperDao;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<Newspaper> newspaperValue = new Mock<Newspaper>();

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

            Assert.Throws(typeof(LayerException), newspaper);
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

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForGet(Func<Newspaper> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
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

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Remove(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return newspaperDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<INewspaperDao> newspaperDao = InitializeMockDaoForSearch(() => new List<Newspaper>());

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

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private static Mock<INewspaperDao> InitializeMockDaoForSearch(Func<IEnumerable<Newspaper>> func)
        {
            var newspaperDao = new Mock<INewspaperDao>();
            newspaperDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, NewspaperSearchOptions>>(), It.IsAny<RoleType>())).Returns(func);
            return newspaperDao;
        }
    }
}

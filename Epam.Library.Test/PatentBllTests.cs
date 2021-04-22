using NUnit.Framework;
using Moq;
using System;
using System.Collections.Generic;
using Epam.Library.Dal.Contracts;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Bll;
using Epam.Library.Test.TestCases;
using Epam.Library.Common.Entities.AuthorElement.Patent;

namespace Epam.Library.Test
{
    [TestFixture]
    public class PatentBllTests
    {
        [TestCaseSource(typeof(PatentBllTestCases), nameof(PatentBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<IPatentDao> patentDao = InitializeMockDaoForAdd(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => listErrors);
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            var errors = patentBll.Add(new Patent());

            // Assert
            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange
            Mock<IPatentDao> patentDao = InitializeMockDaoForAdd(() => throw new Exception());
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => patentBll.Add(new Patent());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange
            Mock<IPatentDao> patentDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => patentBll.Add(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<IPatentDao> InitializeMockDaoForAdd(Action action)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.Add(It.IsAny<AbstractPatent>())).Callback(action);
            return patentDao;
        }

        private static Mock<IValidationBll<AbstractPatent>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<AbstractPatent>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractPatent>()))
                .Returns(func);
            return validation;
        }

        [TestCaseSource(typeof(PatentBllTestCases), nameof(PatentBllTestCases.AddTestCases))]
        public bool Update(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<IPatentDao> patentDao = InitializeMockDaoForUpdate(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => listErrors);
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            var errors = patentBll.Update(new Patent(0, null, 0, null, false, null, null, null, null, DateTime.Now));

            // Assert
            return isAddDao;
        }

        [Test]
        public void Update_Exeption()
        {
            // Arrange
            Mock<IPatentDao> patentDao = InitializeMockDaoForUpdate(() => throw new Exception());
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => patentBll.Update(new Patent());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Update_Exeption_Null()
        {
            // Arrange
            Mock<IPatentDao> patentDao = InitializeMockDaoForUpdate(() => { });
            Mock<IValidationBll<AbstractPatent>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var patentBll = new PatentBll(patentDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => patentBll.Update(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<IPatentDao> InitializeMockDaoForUpdate(Action action)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.Update(It.IsAny<AbstractPatent>())).Callback(action);
            return patentDao;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<AbstractPatent> patentValue = new Mock<AbstractPatent>();

            Mock <IPatentDao> patentDao = InitializeMockDaoForGet(() => patentValue.Object);

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            var patent = patentBll.Get(0);

            // Assert

            Assert.NotNull(patent);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGet(() => throw new Exception());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGet(() => null);

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        private static Mock<IPatentDao> InitializeMockDaoForGet(Func<AbstractPatent> func)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return patentDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<IPatentDao> PatentDao = InitializeMockDaoForRemove(() => removeDao);

            var PatentBll = new PatentBll(PatentDao.Object, null, null);

            // Act

            var patent = PatentBll.Remove(0);

            // Assert

            return patent;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForRemove(() => throw new Exception());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.Remove(0);

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        private Mock<IPatentDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.Remove(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return patentDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForSearch(() => new List<AbstractPatent>());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            var patent = patentBll.Search(new SearchRequest<SortOptions, PatentSearchOptions>());

            // Assert

            Assert.NotNull(patent);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForSearch(() => throw new Exception());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.Search(new SearchRequest<SortOptions, PatentSearchOptions>());

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        private static Mock<IPatentDao> InitializeMockDaoForSearch(Func<IEnumerable<AbstractPatent>> func)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, PatentSearchOptions>>(), It.IsAny<RoleType>())).Returns(func);
            return patentDao;
        }

        [Test]
        public void GetByAuthorId()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGetByAuthorId(() => new List<AbstractPatent>());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            var patent = patentBll.GetByAuthorId(0);

            // Assert

            Assert.NotNull(patent);
        }

        [Test]
        public void GetByAuthorId_Exception()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGetByAuthorId(() => throw new Exception());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.GetByAuthorId(0);

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        private static Mock<IPatentDao> InitializeMockDaoForGetByAuthorId(Func<IEnumerable<AbstractPatent>> func)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.GetByAuthorId(It.IsAny<int>(), It.IsAny<PagingInfo>(), It.IsAny<RoleType>())).Returns(func);
            return patentDao;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGroupsByPublishYear(() => new Dictionary<int, List<AbstractPatent>>());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            var patent = patentBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.NotNull(patent);
        }

        [Test]
        public void GetAllGroupsByPublishYear_Exception()
        {
            // Arrange

            Mock<IPatentDao> patentDao = InitializeMockDaoForGroupsByPublishYear(() => throw new Exception());

            var patentBll = new PatentBll(patentDao.Object, null, null);

            // Act

            TestDelegate patent = () => patentBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(LayerException), patent);
        }

        private static Mock<IPatentDao> InitializeMockDaoForGroupsByPublishYear(Func<Dictionary<int, List<AbstractPatent>>> func)
        {
            var patentDao = new Mock<IPatentDao>();
            patentDao.Setup(a => a.GetAllGroupsByPublishYear(It.IsAny<PagingInfo>(), It.IsAny<RoleType>())).Returns(func);
            return patentDao;
        }
    }
}

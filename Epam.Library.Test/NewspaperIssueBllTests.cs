using Epam.Library.Bll;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using Epam.Library.Test.TestCases;
using Moq;
using NUnit.Framework;
using System;
using System.Linq;
using System.Collections.Generic;

namespace Epam.Library.Test
{
    [TestFixture]
    public class NewspaperIssueBllTests
    {
        [TestCaseSource(typeof(NewspaperIssueBllTestCases), nameof(NewspaperIssueBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForAdd(() => isAddDao = true);
            Mock<INewspaperBll> newspaperBll = InitializeMockBllForGet(() => new Newspaper());
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperIssueBll = new NewspaperIssueBll(newspaperDao.Object, newspaperBll.Object, validation.Object);

            // Act
            var errors = newspaperIssueBll.Add(new NewspaperIssue());

            // Assert
            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForAdd(() => throw new Exception());
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(new NewspaperIssue());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperBll = new NewspaperIssueBll(newspaperDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => newspaperBll.Add(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForAdd(Action action)
        {
            var newspaperIssueDao = new Mock<INewspaperIssueDao>();
            newspaperIssueDao.Setup(a => a.Add(It.IsAny<NewspaperIssue>())).Callback(action);
            return newspaperIssueDao;
        }
        private Mock<INewspaperBll> InitializeMockBllForGet(Func<Newspaper> func)
        {
            var newspaperBll = new Mock<INewspaperBll>();
            newspaperBll.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return newspaperBll;
        }

        private Mock<IValidationBll<NewspaperIssue>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<NewspaperIssue>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<NewspaperIssue>()))
                .Returns(func);
            return validation;
        }

        [TestCaseSource(typeof(NewspaperIssueBllTestCases), nameof(NewspaperIssueBllTestCases.AddTestCases))]
        public bool Update(ErrorValidation error)
        {
            // Arrange
            bool isAddDao = false;
            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForUpdate(() => isAddDao = true);
            Mock<INewspaperBll> newspaperBll = InitializeMockBllForGet(() => new Newspaper());
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => listErrors);
            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, newspaperBll.Object, validation.Object);

            // Act
            var errors = newspaperIssueBll.Update(new NewspaperIssue(0, null, 0, null, false, null, null, 0, null, DateTime.Now, 0));

            // Assert
            return isAddDao;
        }

        [Test]
        public void Update_Exeption()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForUpdate(() => throw new Exception());
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperIssueBll = new NewspaperIssueBll(newspaperDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => newspaperIssueBll.Update(new NewspaperIssue());

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Update_Exeption_Null()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForUpdate(() => { });
            Mock<IValidationBll<NewspaperIssue>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var newspaperIssueBll = new NewspaperIssueBll(newspaperDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => newspaperIssueBll.Update(null);

            // Assert
            Assert.Throws(typeof(LayerException), action);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForUpdate(Action action)
        {
            var newspaperIssueDao = new Mock<INewspaperIssueDao>();
            newspaperIssueDao.Setup(a => a.Update(It.IsAny<NewspaperIssue>())).Callback(action);
            return newspaperIssueDao;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<NewspaperIssue> issueValue = new Mock<NewspaperIssue>();

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGet(() => issueValue.Object);

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            var newspaper = newspaperIssueBll.Get(0);

            // Assert

            Assert.NotNull(newspaper);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForGet(() => throw new Exception());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperDao.Object, null, null);

            // Act

            TestDelegate newspaper = () => newspaperIssueBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), newspaper);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGet(() => null);

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            TestDelegate newspaper = () => newspaperIssueBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForGet(Func<NewspaperIssue> func)
        {
            var newspaperIssueDao = new Mock<INewspaperIssueDao>();
            newspaperIssueDao.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return newspaperIssueDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<INewspaperIssueDao> issueDao = InitializeMockDaoForRemove(() => removeDao);

            var newspaperIssueBll = new NewspaperIssueBll(issueDao.Object, null, null);

            // Act

            var newspaper = newspaperIssueBll.Remove(0);

            // Assert

            return newspaper;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperDao = InitializeMockDaoForRemove(() => throw new Exception());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperDao.Object, null, null);

            // Act

            TestDelegate newspaper = () => newspaperIssueBll.Remove(0);

            // Assert

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var issueDao = new Mock<INewspaperIssueDao>();
            issueDao.Setup(a => a.Remove(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return issueDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForSearch(() => new List<NewspaperIssue>());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            var newspaper = newspaperIssueBll.Search(new SearchRequest<SortOptions, NewspaperIssueSearchOptions>());

            // Assert

            Assert.NotNull(newspaper);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForSearch(() => throw new Exception());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            TestDelegate newspaper = () => newspaperIssueBll.Search(new SearchRequest<SortOptions, NewspaperIssueSearchOptions>());

            // Assert

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private static Mock<INewspaperIssueDao> InitializeMockDaoForSearch(Func<IEnumerable<NewspaperIssue>> func)
        {
            var issueDao = new Mock<INewspaperIssueDao>();
            issueDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, NewspaperIssueSearchOptions>>(), It.IsAny<RoleType>())).Returns(func);
            return issueDao;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGroupsByPublishYear(() => new Dictionary<int, List<NewspaperIssue>>());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            var newspaperIssue = newspaperIssueBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.NotNull(newspaperIssue);
        }

        [Test]
        public void GetAllGroupsByPublishYear_Exception()
        {
            // Arrange

            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGroupsByPublishYear(() => throw new Exception());

            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act

            TestDelegate newspaper = () => newspaperIssueBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(LayerException), newspaper);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForGroupsByPublishYear(Func<Dictionary<int, List<NewspaperIssue>>> func)
        {
            var newspaperIssueDao = new Mock<INewspaperIssueDao>();
            newspaperIssueDao.Setup(a => a.GetAllGroupsByPublishYear(It.IsAny<PagingInfo>(), It.IsAny<RoleType>())).Returns(func);
            return newspaperIssueDao;
        }

        [Test]
        public void GetAllByNewspaper()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGetAllByNewspaper(() => new List<NewspaperIssue>() 
            { 
                new NewspaperIssue(),
                new NewspaperIssue()
            });
            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act
            var newspaperIssues = newspaperIssueBll.GetAllByNewspaper(0);

            // Assert
            Assert.AreEqual(newspaperIssues.Count(), 2);
        }

        [Test]
        public void GetCountByNewspaper()
        {
            // Arrange
            Mock<INewspaperIssueDao> newspaperIssueDao = InitializeMockDaoForGetCountByNewspaper(2);
            var newspaperIssueBll = new NewspaperIssueBll(newspaperIssueDao.Object, null, null);

            // Act
            var count = newspaperIssueBll.GetCountByNewspaper(0);

            // Assert
            Assert.AreEqual(count, 2);
        }

        private Mock<INewspaperIssueDao> InitializeMockDaoForGetAllByNewspaper(Func<IEnumerable<NewspaperIssue>> func)
        {
            var issueDao = new Mock<INewspaperIssueDao>();
            issueDao.Setup(a => a.GetAllByNewspaper(It.IsAny<int>(),
                                                    It.IsAny<PagingInfo>(),
                                                    It.IsAny<SortOptions>(),
                                                    It.IsAny<RoleType>())
            ).Returns(func);

            return issueDao;
        }
        private Mock<INewspaperIssueDao> InitializeMockDaoForGetCountByNewspaper(int count)
        {
            var issueDao = new Mock<INewspaperIssueDao>();
            issueDao.Setup(a => a.GetCountByNewspaper(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(count);

            return issueDao;
        }

    }
}

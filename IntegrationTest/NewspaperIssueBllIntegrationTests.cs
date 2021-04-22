using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.IntegrationTest
{
    public class NewspaperIssueBllIntegrationTests
    {
        private INewspaperBll _newspaperBll;
        private INewspaperIssueBll _newspaperIssueBll;
        private ICatalogueBll _catalogueBll;

        private List<int> _newspaperIDs;
        private List<int> _newspaperIssueIDs;
        private int _newspaperId;

        [OneTimeSetUp]
        public void InitClass()
        {
            _newspaperBll = NinjectForTests.NewspaperBll;
            _newspaperIssueBll = NinjectForTests.NewspaperIssueBll;
            _catalogueBll = NinjectForTests.CatalogueBll;

            _newspaperIDs = new List<int>();
            _newspaperIssueIDs = new List<int>();

            _newspaperId = GetNewspaperId("Test for issue");
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _newspaperIssueIDs.ForEach(a => _newspaperIssueBll.Remove(a, RoleType.admin));
            _newspaperIDs.ForEach(a => _newspaperBll.Remove(a, RoleType.admin));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue(null, "Add-True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            int preCount = GetCount();
            int id;

            // Act
            var errors = _newspaperIssueBll.Add(issue);
            _newspaperIssueIDs.Add(id = GetId(issue).Value);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount + 1, postCount);
            });
        }

        [Test]
        public void Add_False()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue() { NewspaperId = _newspaperId };
            int preCount = GetCount();

            // Act
            var errors = _newspaperIssueBll.Add(issue);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsTrue(errors.Count() > 0);
                Assert.AreEqual(preCount, postCount);
            });
        }

        [Test]
        public void Add_Null_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperIssueBll.Add(null);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Update_True()
        {
            // Arrange
            NewspaperIssue issue1 = new NewspaperIssue(null, "Add-True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            NewspaperIssue issue2 = new NewspaperIssue(null, "Addtrue-True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            int id;

            _newspaperIssueBll.Add(issue1);
            _newspaperIssueIDs.Add(id = GetId(issue1).Value);
            issue2.Id = id;

            int preCount = GetCount();

            // Act
            var errors = _newspaperIssueBll.Update(issue2);

            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount, postCount);
                Assert.IsTrue(issue2.Equals(_newspaperIssueBll.Get(issue2.Id.Value)));
            });
        }

        [Test]
        public void Update_False()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue(-100, null, 0, null, false, null, null, 0, null, DateTime.Now, _newspaperId);
            int preCount = GetCount();

            // Act
            var errors = _newspaperIssueBll.Update(issue);
            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsTrue(errors.Count() > 0);
                Assert.AreEqual(preCount, postCount);
            });
        }

        [Test]
        public void Update_Null_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperIssueBll.Update(null);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Update_IdNull_Exception()
        {
            // Arrange
            int preCoutn = GetCount();

            // Act
            TestDelegate test = () => _newspaperIssueBll.Update(new NewspaperIssue(null, null, 0, null, false, null, null, 0, null, DateTime.Now, _newspaperId));

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCoutn, GetCount());
            });
        }

        [Test]
        public void Remove_True()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue(null, "Remove True", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            _newspaperIssueBll.Add(issue);

            int id = GetId(issue).Value;

            int preCount = GetCount();

            // Act
            _newspaperIssueBll.Remove(id, RoleType.admin);

            int postCount = GetCount();

            if (preCount == postCount)
            {
                _newspaperIssueIDs.Add(id);
            }

            // Assert
            Assert.AreEqual(preCount - 1, postCount);
        }

        [Test]
        public void Remove_Exception_False()
        {
            // Arrange
            int preCount = GetCount();

            // Act
            TestDelegate test = () => _newspaperIssueBll.Remove(-30000);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCount, GetCount());
            });
        }

        [Test]
        public void Get()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue(null, "Get", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            _newspaperIssueBll.Add(issue);

            int id;
            _newspaperIssueIDs.Add(id = GetId(issue).Value);

            // Act
            var element = _newspaperIssueBll.Get(id);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsNotNull(element);
                Assert.AreEqual(issue, element);
            });
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange
            TestDelegate test = () => _newspaperIssueBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [TestCaseSource(typeof(NewspaperIssueBllIntegrationTestCases), nameof(NewspaperIssueBllIntegrationTestCases.Search))]
        public bool Search(NewspaperIssue issue, SearchRequest<SortOptions, NewspaperIssueSearchOptions> request)
        {
            // Arrange
            if (issue != null)
            {
                issue.NewspaperId = _newspaperId;

                _newspaperIssueBll.Add(issue);

                _newspaperIssueIDs.Add(GetId(issue).Value);
            }

            // Act
            bool result = _newspaperIssueBll.Search(request).Any(a => a.Equals(issue));

            // Assert
            return result;
        }

        [Test]
        public void GetAllByNewspaper()
        {
            // Arrange
            NewspaperIssue issue = new NewspaperIssue(null, "GetAllByNewspaper", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, _newspaperId);
            _newspaperIssueBll.Add(issue);
            _newspaperIssueIDs.Add(GetId(issue).Value);

            // Act
            bool result = _newspaperIssueBll.GetAllByNewspaper(_newspaperId).Any(a => a.Equals(issue));

            // Assert
            Assert.IsTrue(result);
        }

        [Test]
        public void GetCountByNewspaper()
        {
            // Arrange
            int newspaperId = GetNewspaperId("Count Test for issue");
            _newspaperIDs.Add(newspaperId);

            NewspaperIssue issue = new NewspaperIssue(null, "GetCountByNewspaper", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, newspaperId);
            _newspaperIssueBll.Add(issue);
            _newspaperIssueIDs.Add(GetId(issue).Value);

            // Act
            var result = _newspaperIssueBll.GetCountByNewspaper(newspaperId);

            // Assert
            Assert.AreEqual(result, 1);
        }


        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange
            NewspaperIssue[] issue = new NewspaperIssue[]
            {
                new NewspaperIssue(null, "GpoupsByPublishYear One", 0, null, false, "Test", "Test", DateTime.Now.Year - 5, null, DateTime.Now.AddYears(-5), _newspaperId),
                new NewspaperIssue(null, "GpoupsByPublishYear Two", 0, null, false, "Test", "Test", DateTime.Now.Year - 2, null, DateTime.Now.AddYears(-2), _newspaperId),
            };

            List<int> ids = new List<int>();

            foreach (var item in issue)
            {
                _newspaperIssueBll.Add(item);

                ids.Add(GetId(item).Value);
            }

            _newspaperIssueIDs.AddRange(ids);

            // Act
            int result = _newspaperIssueBll.GetAllGroupsByPublishYear().Count();

            // Assert
            Assert.IsTrue(result >= 2);
        }

        private int GetCount()
        {
            return _newspaperIssueBll.Search(null).Count();
        }

        private int? GetId(NewspaperIssue issue)
        {
            return _newspaperIssueBll.Search(null)
                .Where(a => a.Equals(issue))
                ?.Max(b => b.Id);
        }
        private int? GetId(Newspaper newspaper)
        {
            return _newspaperBll.Search(null)
                .Where(a => a.Equals(newspaper))
                ?.Max(b => b.Id);
        }

        private int GetNewspaperId(string name)
        {
            var newspaper = new Newspaper(null, name, null, false);
            _newspaperBll.Add(newspaper);

            int newspaperId = GetId(newspaper).Value;
            _newspaperIDs.Add(newspaperId);

            return newspaperId;
        }
    }
}

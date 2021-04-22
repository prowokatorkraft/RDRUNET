using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.IntegrationTest
{
    public class PatentBllIntegrationTests
    {
        private IPatentBll _patentBll;
        private ICatalogueBll _catalogueBll;
        private IAuthorBll _authorBll;

        private List<int> _patentIDs;
        private List<int> _authorIDs;

        [OneTimeSetUp]
        public void InitClass()
        {
            _patentBll = NinjectForTests.PatentBll;
            _catalogueBll = NinjectForTests.CatalogueBll;
            _authorBll = NinjectForTests.AuthorBll;

            _patentIDs = new List<int>();
            _authorIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _patentIDs.ForEach(a => _patentBll.Remove(a, RoleType.admin));

            _authorIDs.ForEach(a => _authorBll.Remove(a, RoleType.admin));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            Patent patent = new Patent(null, "Add-True", 0, null, false, null, "Test", "123456780", null, DateTime.Now);
            int preCount = GetCount();
            int id;

            // Act
            var errors = _patentBll.Add(patent);
            _patentIDs.Add(id = GetId(patent).Value);
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
            Patent patent = new Patent();
            int preCount = GetCount();

            // Act
            var errors = _patentBll.Add(patent);
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
            TestDelegate test = () => _patentBll.Add(null);

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
            Patent patent1 = new Patent(null, "Add-True", 0, null, false, null, "Test", "123456780", null, DateTime.Now);
            Patent patent2 = new Patent(null, "Addtrue-True", 0, null, false, null, "Test", "123456780", null, DateTime.Now);
            int id;

            _patentBll.Add(patent1);
            _patentIDs.Add(id = GetId(patent1).Value);
            patent2.Id = id;

            int preCount = GetCount();

            // Act
            var errors = _patentBll.Update(patent2);

            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount, postCount);
                Assert.IsTrue(patent2.Equals(_patentBll.Get(patent2.Id.Value)));
            });
        }

        [Test]
        public void Update_False()
        {
            // Arrange
            Patent patent = new Patent(-100, null, 0, null, false, null, null, null, null, DateTime.Now);
            int preCount = GetCount();

            // Act
            var errors = _patentBll.Update(patent);
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
            TestDelegate test = () => _patentBll.Update(null);

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
            TestDelegate test = () => _patentBll.Update(new Patent(null,null,0,null,false,null,null,null,null,DateTime.Now));

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
            Patent patent = new Patent(null, "Remove True", 0, null, false, null, "Test", "128856789", null, DateTime.Now);

            _patentBll.Add(patent);

            int id = GetId(patent).Value;

            int preCount = GetCount();

            // Act
            _patentBll.Remove(id, RoleType.admin);

            int postCount = GetCount();

            if (preCount == postCount)
            {
                _patentIDs.Add(id);
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
            TestDelegate test = () => _patentBll.Remove(-30000);

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
            Patent patent = new Patent(null, "Get", 0, null, false, null, "Test", "123226789", null, DateTime.Now);

            _patentBll.Add(patent);

            int id;
            _patentIDs.Add(id = GetId(patent).Value);

            // Act
            var element = _patentBll.Get(id);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsNotNull(element);
                Assert.AreEqual(patent, element);
            });
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange
            TestDelegate test = () => _patentBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [TestCaseSource(typeof(PatentBllIntegrationTestCases), nameof(PatentBllIntegrationTestCases.Search))]
        public bool Search(Patent patent, SearchRequest<SortOptions, PatentSearchOptions> request)
        {
            // Arrange
            if (patent != null)
            {
                _patentBll.Add(patent);

                _patentIDs.Add(GetId(patent).Value);
            }

            // Act
            bool result = _patentBll.Search(request).Any(a => a.Equals(patent));

            // Assert
            return result;
        }

        [TestCaseSource(typeof(PatentBllIntegrationTestCases), nameof(PatentBllIntegrationTestCases.GetByAuthorId))]
        public bool GetByAuthorId(Author author, Patent patent)
        {
            // Arrange
            _authorBll.Add(author);
            int idAuthors;

            _authorIDs.Add(idAuthors = GetId(author).Value);

            if (patent != null)
            {
                patent.AuthorIDs = new int[] { idAuthors };

                _patentBll.Add(patent);

                _patentIDs.Add(GetId(patent).Value);
            }

            //Act
            var result = _patentBll.GetByAuthorId(idAuthors).Any();

            // Assert
            return result;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange
            Patent[] patents = new Patent[]
            {
                new Patent(null, "GpoupsByPublishYear One", 0, null, false, null, "Test", "823456789", null, DateTime.Now.AddYears(-5)),
                new Patent(null, "GpoupsByPublishYear Two", 0, null, false, null, "Test", "923456789", null, DateTime.Now.AddYears(-2)),
            };

            List<int> ids = new List<int>();

            foreach (var item in patents)
            {
                _patentBll.Add(item);

                ids.Add(GetId(item).Value);
            }

            _patentIDs.AddRange(ids);

            // Act
            int result = _patentBll.GetAllGroupsByPublishYear().Count();

            // Assert
            Assert.IsTrue(result >= 2);
        }

        private int GetCount()
        {
            return _patentBll.Search(null).Count();
        }

        private int? GetId(Patent patent)
        {
            return _patentBll.Search(null)
                .Where(a => a.Equals(patent))
                ?.Max(b => b.Id);
        }

        private int? GetId(Author author)
        {
            return _authorBll.Search(null)
                .Where(a => a.Equals(author))
                ?.Max(b => b.Id);
        }
    }
}

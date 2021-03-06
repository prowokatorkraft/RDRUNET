using System;
using System.Collections.Generic;
using System.Linq;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;

namespace Epam.Library.IntegrationTest
{

    public class AuthorBllIntegrationTests
    {
        private IAuthorBll _authorBll;
        private ICatalogueBll _catalogueBll;
        private IPatentBll _patentBll;

        private List<int> _authorIDs;
        private List<int> _patentIDs;

        [OneTimeSetUp]
        public void InitClass()
        {
            _authorBll = NinjectForTests.AuthorBll;
            _catalogueBll = NinjectForTests.CatalogueBll;
            _patentBll = NinjectForTests.PatentBll;

            _authorIDs = new List<int>();
            _patentIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _patentIDs.ForEach(p => _patentBll.Remove(p, RoleType.admin));

            _authorIDs.ForEach(a => _authorBll.Remove(a, RoleType.admin));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            Author author = new Author(null, "Add", "True");
            int preCount = GetCount();
            int id;

            // Act
            var errors = _authorBll.Add(author);
            _authorIDs.Add(id = GetId(author).Value);
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
            Author author = new Author(null, null, null);
            int preCount = GetCount();

            // Act
            var errors = _authorBll.Add(author);
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
            TestDelegate test = () => _authorBll.Add(null);

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
            Author author1 = new Author(null, "Update", "True");
            Author author2 = new Author(null, "Updatetrue", "True");
            int id;

            _authorBll.Add(author1);
            _authorIDs.Add(id = GetId(author1).Value);
            author2.Id = id;

            int preCount = GetCount();

            // Act
            var errors = _authorBll.Update(author2);

            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount, postCount);
                Assert.IsTrue(author2.Equals(_authorBll.Get(author2.Id.Value)));
            });
        }

        [Test]
        public void Update_False()
        {
            // Arrange
            Author author = new Author(-100, null, null);
            int preCount = GetCount();

            // Act
            var errors = _authorBll.Update(author);
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
            TestDelegate test = () => _authorBll.Update(null);

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
            TestDelegate test = () => _authorBll.Update(new Author(null,null,null));

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
            Author author = new Author(null, "Remove", "True");

            _authorBll.Add(author);

            int id = GetId(author).Value;

            int preCount = GetCount();

            // Act
            _authorBll.Remove(id, RoleType.admin);

            int postCount = GetCount();

            if (preCount == postCount)
            {
                _authorIDs.Add(id);
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
            TestDelegate test = () => _authorBll.Remove(-30000);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.Throws<LayerException>(test);
                Assert.AreEqual(preCount, GetCount());
            });
        }

        [Test]
        public void Remove_Dependencies_False()
        {
            // Arrange
            Author author = new Author(null, "Remove", "Dependencies");
            _authorBll.Add(author);

            int preCount = GetCount();
            int idAuthor;

            _authorIDs.Add(idAuthor = GetId(author).Value);

            Patent patent = new Patent(null, "Remove Dependencies", 0, null, false, new int[] { idAuthor }, "Test", "123996789", null, DateTime.Now);
            _patentBll.Add(patent);

            int idPatent;
            _patentIDs.Add(idPatent = GetId(patent).Value);

            // Act
            bool isRemoved = _authorBll.Remove(idAuthor);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsFalse(isRemoved);
                Assert.AreEqual(preCount, GetCount());
            });
        }

        [Test]
        public void Get()
        {
            // Arrange
            Author author = new Author(null, "Get", "Get");
            _authorBll.Add(author);

            int id;
            _authorIDs.Add(id = GetId(author).Value);

            // Act
            Author element = _authorBll.Get(id);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsNotNull(element);
                Assert.AreEqual(author, element);
            });
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange
            TestDelegate test = () => _authorBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [Test]
        public void Check_True()
        {
            // Arrange
            Author[] authors = new Author[]
            {
                new Author(null, "Check", "True-One"),
                new Author(null, "Check", "True-Two"),
                new Author(null, "Check", "True-Three")
            };

            List<int> ids = new List<int>();

            foreach (var item in authors)
            {
                _authorBll.Add(item);
                ids.Add(GetId(item).Value);
            }

            _authorIDs.AddRange(ids);

            // Act
            var result = _authorBll.Check(ids.ToArray());

            // Assert
            Assert.IsTrue(result);
        }

        [Test]
        public void Check_False()
        {
            // Act
            var result = _authorBll.Check(new int[] { -30000 });

            // Assert
            Assert.IsFalse(result);
        }

        [TestCaseSource(typeof(AuthorBllIntegrationTestCases), nameof(AuthorBllIntegrationTestCases.Search))]
        public bool Search(Author author, SearchRequest<SortOptions, AuthorSearchOptions> request)
        {
            // Arrange
            if (author != null)
            {
                _authorBll.Add(author);

                _authorIDs.Add(GetId(author).Value);
            }

            //Act
            bool result = _authorBll.Search(request).Any(a => a.Equals(author));

            // Assert
            return result;
        }

        private int GetCount()
        {
            return _authorBll.Search(null).Count();
        }

        private int? GetId(Author author)
        {
            return _authorBll.Search(null)
                .Where(a => a.Equals(author))
                ?.Max(b => b.Id);
        }

        private int? GetId(AbstractAuthorElement authorElement)
        {
            return _catalogueBll.Search(null)
                .OfType<AbstractAuthorElement>()
                .Where(a => a.Equals(authorElement))
                ?.Max(b => b.Id);
        }
    }
}

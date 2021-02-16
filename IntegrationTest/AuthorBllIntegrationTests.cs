using System;
using System.Collections.Generic;
using System.Linq;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.DependencyInjection;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using NUnit.Framework;

namespace Epam.Library.IntegrationTest
{
    [TestFixture]
    public class AuthorBllIntegrationTests
    {
        private IAuthorBll _authorBll;

        private ICatalogueBll _catalogueBll;

        [TestFixtureSetUp]
        public void InitClass()
        {
            _authorBll = DependencyInjection.AuthorBll;
            _catalogueBll = DependencyInjection.CatalogueBll;
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            int preCount = GetCount();
            Author author = new Author(null, "Test", "Test");

            // Act
            var errors = _authorBll.Add(author);
            int postCount = GetCount();

            int? id = GetId(author);
            if (id.HasValue)
            {
                _authorBll.Remove(id.Value);
            }

            // Assert
            Assert.AreEqual(0, errors.Count());
            Assert.AreEqual(preCount + 1, postCount);
            Assert.IsTrue(id.HasValue);
        }

        [Test]
        public void Add_False()
        {
            // Arrange
            int preCount = GetCount();
            Author author = new Author(null, "Test", null);

            // Act
            var errors = _authorBll.Add(author);

            // Assert
            Assert.IsTrue(errors.Count() > 0);
            Assert.AreEqual(preCount, GetCount());
        }

        [Test]
        public void Add_Null_Exception()
        {
            // Arrange
            int count = GetCount();

            // Act
            TestDelegate test = () => _authorBll.Add(null);

            // Assert
            Assert.Throws<AddException>(test);
            Assert.AreEqual(count, GetCount());
        }

        [Test]
        public void Remove_True()
        {
            // Arrange
            Author author = new Author(null, "Test", "Test");
            _authorBll.Add(author);

            int preCount = GetCount();
            int id = GetId(author).Value;

            // Act
            bool isRemoved = _authorBll.Remove(id);

            // Assert
            Assert.IsTrue(isRemoved);
            Assert.AreEqual(preCount - 1, GetCount());
        }

        [Test]
        public void Remove_Exception_False()
        {
            // Arrange
            int preCount = GetCount();

            // Act
            TestDelegate test = () => _authorBll.Remove(-30000);

            // Assert
            Assert.Throws<RemoveException>(test);
            Assert.AreEqual(preCount, GetCount());
        }

        [Test]
        public void Remove_Dependencies_False()
        {
            // Arrange
            Author author = new Author(null, "Test", "Test");
            _authorBll.Add(author);
            int preCount = GetCount();
            int idAuthor = GetId(author).Value;

            Patent patent = new Patent(null, "Test", 0, null, new int[] { idAuthor }, "Test", "123456789", null, DateTime.Now);
            DependencyInjection.PatentBll.Add(patent);
            int idPatent = GetId(patent).Value;

            // Act
            bool isRemoved = _authorBll.Remove(idAuthor);

            // Assert
            Assert.IsFalse(isRemoved);
            Assert.AreEqual(preCount, GetCount());

            DependencyInjection.PatentBll.Remove(idPatent);
            _authorBll.Remove(idAuthor);
        }

        [Test]
        public void Get()
        {
            // Arrange
            Author author = new Author(null, "Test", "Test");
            _authorBll.Add(author);
            int id = GetId(author).Value;

            // Act
            Author element = _authorBll.Get(id);

            _authorBll.Remove(id);

            // Assert
            Assert.IsNotNull(element);
            Assert.AreEqual(author, element);
        }

        [Test]
        [ExpectedException(typeof(GetException))]
        public void Get_Exception()
        {
            _authorBll.Get(-30000);
        }

        private int GetCount()
        {
            return _authorBll.Search(null).Count();
        }

        private int? GetId(Author author)
        {
            return _authorBll.Search(null)
                .Where(a => a.Equals(author))
                .LastOrDefault()
                ?.Id.Value;
        }

        private int? GetId(AbstractAuthorElement authorElement)
        {
            return _catalogueBll.Search(null)
                .OfType<AbstractAuthorElement>()
                .Where(a => a.Equals(authorElement))
                .LastOrDefault()
                ?.Id.Value;
        }
    }
}

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
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement;

namespace Epam.Library.Test
{
    [TestFixture]
    public class CatalogueBllTests
    {
        [Test]
        public void Get()
        {
            // Arrange

            Mock<LibraryAbstractElement> catalogueValue = new Mock<LibraryAbstractElement>();

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGet(() => catalogueValue.Object);

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            var catalogue = catalogueBll.Get(0);

            // Assert

            Assert.NotNull(catalogue);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGet(() => throw new Exception());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            TestDelegate catalogue = () => catalogueBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), catalogue);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGet(() => null);

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            TestDelegate catalogue = () => catalogueBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForGet(Func<LibraryAbstractElement> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.Get(It.IsAny<int>())).Returns(func);
            return catalogueDao;
        }

        [Test]
        public void GetByAuthorId()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGetByAuthorId(() => new List<AbstractAuthorElement>());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            var catalogue = catalogueBll.GetByAuthorId(0);

            // Assert

            Assert.NotNull(catalogue);
        }

        [Test]
        public void GetByAuthorId_Exception()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGetByAuthorId(() => throw new Exception());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            TestDelegate catalogue = () => catalogueBll.GetByAuthorId(0);

            // Assert

            Assert.Throws(typeof(GetException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForGetByAuthorId(Func<IEnumerable<AbstractAuthorElement>> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(func);
            return catalogueDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForSearch(() => new List<LibraryAbstractElement>());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            var catalogue = catalogueBll.Search(new SearchRequest<SortOptions, CatalogueSearchOptions>());

            // Assert

            Assert.NotNull(catalogue);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForSearch(() => throw new Exception());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            TestDelegate catalogue = () => catalogueBll.Search(new SearchRequest<SortOptions, CatalogueSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForSearch(Func<IEnumerable<LibraryAbstractElement>> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, CatalogueSearchOptions>>())).Returns(func);
            return catalogueDao;
        }
    }
}

using NUnit.Framework;
using Moq;
using System;
using System.Collections.Generic;
using Epam.Library.Dal.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Bll;
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

            Assert.Throws(typeof(LayerException), catalogue);
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

            Assert.Throws(typeof(LayerException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForGet(Func<LibraryAbstractElement> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
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

            Assert.Throws(typeof(LayerException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForGetByAuthorId(Func<IEnumerable<AbstractAuthorElement>> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.GetByAuthorId(It.IsAny<int>(), It.IsAny<PagingInfo>(), It.IsAny<RoleType>())).Returns(func);
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

            Assert.Throws(typeof(LayerException), catalogue);
        }

        [Test]
        public void GetCount()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGetCount(() => 3);

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            var count = catalogueBll.GetCount();

            // Assert

            Assert.AreEqual(count, 3);
        }

        [Test]
        public void GetCount_Exception()
        {
            // Arrange

            Mock<ICatalogueDao> catalogueDao = InitializeMockDaoForGetCount(() => throw new Exception());

            var catalogueBll = new CatalogueBll(catalogueDao.Object);

            // Act

            TestDelegate catalogue = () => catalogueBll.GetCount();

            // Assert

            Assert.Throws(typeof(LayerException), catalogue);
        }

        private static Mock<ICatalogueDao> InitializeMockDaoForSearch(Func<IEnumerable<LibraryAbstractElement>> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, CatalogueSearchOptions>>(), It.IsAny<RoleType>())).Returns(func);
            return catalogueDao;
        }
        private static Mock<ICatalogueDao> InitializeMockDaoForGetCount(Func<int> func)
        {
            var catalogueDao = new Mock<ICatalogueDao>();
            catalogueDao.Setup(a => a.GetCount(It.IsAny<CatalogueSearchOptions>(), It.IsAny<string>(), It.IsAny<RoleType>())).Returns(func);
            return catalogueDao;
        }
    }
}

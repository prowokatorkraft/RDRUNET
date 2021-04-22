using NUnit.Framework;
using Moq;
using System;
using System.Collections.Generic;
using Epam.Library.Dal.Contracts;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Bll;
using Epam.Library.Test.TestCases;

namespace Epam.Library.Test
{
    [TestFixture]
    public class AuthorBllTests
    {
        [TestCaseSource(typeof(AuthorBllTestCases), nameof(AuthorBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange

            bool isAddDao = false;
            Mock<IAuthorDao> authorDao = InitializeMockDaoForAdd(() => isAddDao = true);

            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }

            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => listErrors);

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            var errors = authorBll.Add(new Author());

            // Assert

            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForAdd(() => throw new Exception());

            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Add(new Author());

            // Assert

            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Add(null);

            // Assert

            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<IValidationBll<Author>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<Author>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<Author>()))
                .Returns(func);
            return validation;
        }

        private static Mock<IAuthorDao> InitializeMockDaoForAdd(Action action)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Add(It.IsAny<Author>())).Callback(action);
            return authorDao;
        }

        [TestCaseSource(typeof(AuthorBllTestCases), nameof(AuthorBllTestCases.AddTestCases))]
        public bool Update(ErrorValidation error)
        {
            // Arrange

            bool isAddDao = false;
            Mock<IAuthorDao> authorDao = InitializeMockDaoForUpdate(() => isAddDao = true);

            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }

            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => listErrors);

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            var errors = authorBll.Update(new Author(0,null,null));

            // Assert

            return isAddDao;
        }

        [Test]
        public void Update_Exeption()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForUpdate(() => throw new Exception());

            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Update(new Author());

            // Assert

            Assert.Throws(typeof(LayerException), action);
        }

        [Test]
        public void Update_Exeption_Null()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForUpdate(() => { });
            Mock<IValidationBll<Author>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Update(null);

            // Assert

            Assert.Throws(typeof(LayerException), action);
        }

        private static Mock<IAuthorDao> InitializeMockDaoForUpdate(Action action)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Update(It.IsAny<Author>())).Callback(action);
            return authorDao;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForGet(() => new Author());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            var author = authorBll.Get(0);

            // Assert

            Assert.NotNull(author);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForGet(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), author);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForGet(() => null);

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Get(0);

            // Assert

            Assert.Throws(typeof(LayerException), author);
        }

        private static Mock<IAuthorDao> InitializeMockDaoForGet(Func<Author> func)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Get(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return authorDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Check(bool checkDao)
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForCheck(() => checkDao);

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            var author = authorBll.Check(new int[] { });

            // Assert

            return author;
        }

        [Test]
        public void Check_Exception()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForCheck(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Check(new int[] { });

            // Assert

            Assert.Throws(typeof(LayerException), author);
        }

        private static Mock<IAuthorDao> InitializeMockDaoForCheck(Func<bool> func)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Check(It.IsAny<int[]>(), It.IsAny<RoleType>())).Returns(func);
            return authorDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForRemove(() => removeDao);

            Mock<ICatalogueBll> catalogue = InitializeMockCatalogueForRemove(() => new List<AbstractAuthorElement>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, catalogue.Object, null);

            // Act

            var author = authorBll.Remove(0);

            // Assert

            return author;
        }

        [TestCase(true, ExpectedResult = false)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove_Dependency(bool removekDao)
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForRemove(() => removekDao);
            
            var authorElement = new Mock<AbstractAuthorElement>();
            
            Mock<ICatalogueBll> catalogue = InitializeMockCatalogueForRemove(() => new List<AbstractAuthorElement>() { authorElement.Object });
            
            IAuthorBll authorBll = new AuthorBll(authorDao.Object, catalogue.Object, null);

            // Act

            var author = authorBll.Remove(0);

            // Assert

            return author;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForRemove(() => throw new Exception());
            Mock<ICatalogueBll> catalogue = InitializeMockCatalogueForRemove(() => new List<AbstractAuthorElement>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, catalogue.Object, null);

            // Act

            TestDelegate author = () => authorBll.Remove(0);

            // Assert

            Assert.Throws(typeof(LayerException), author);
        }

        private static Mock<ICatalogueBll> InitializeMockCatalogueForRemove(Func<IEnumerable<AbstractAuthorElement>> func)
        {
            var catalogue = new Mock<ICatalogueBll>();
            catalogue.Setup(a => a.GetByAuthorId(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return catalogue;
        }

        private static Mock<IAuthorDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Remove(It.IsAny<int>(), It.IsAny<RoleType>())).Returns(func);
            return authorDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForSearch(() => new List<Author>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            var author = authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>());

            // Assert

            Assert.NotNull(author);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            Mock<IAuthorDao> authorDao = InitializeMockDaoForSearch(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>());

            // Assert

            Assert.Throws(typeof(LayerException), author);
        }

        private static Mock<IAuthorDao> InitializeMockDaoForSearch(Func<IEnumerable<Author>> func)
        {
            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, AuthorSearchOptions>>(), It.IsAny<RoleType>())).Returns(func);
            return authorDao;
        }
    }
}

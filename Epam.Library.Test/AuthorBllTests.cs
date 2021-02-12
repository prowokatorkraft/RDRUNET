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
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.SearchOptionsEnum;

namespace Epam.Library.Test
{
    [TestFixture]
    public class AuthorBllTests
    {
        [TestCaseSource(typeof(AuthorBllTestCases), nameof(AuthorBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            bool isAddDao = false;
            authorDao.Setup(a => a.Add(It.IsAny<Author>())).Callback(() => isAddDao = true);

            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            var validation = new Mock<IValidationBll<Author>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<Author>()))
                .Returns(listErrors);

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Add(It.IsAny<Author>())).Callback(() => throw new Exception());

            var validation = new Mock<IValidationBll<Author>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<Author>()))
                .Returns(new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Add(new Author());

            // Assert

            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Add(It.IsAny<Author>()));

            var validation = new Mock<IValidationBll<Author>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<Author>()))
                .Returns(new List<ErrorValidation>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => authorBll.Add(null);

            // Assert

            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Get()
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Get(It.IsAny<int>())).Returns(new Author());

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Get(It.IsAny<int>())).Returns(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), author);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Get(It.IsAny<int>())).Returns(() => null);

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), author);
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Check(bool checkDao)
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Check(It.IsAny<int[]>())).Returns(checkDao);

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Check(It.IsAny<int[]>())).Returns(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Check(new int[] { });

            // Assert

            Assert.Throws(typeof(GetException), author);
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removekDao)
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(removekDao);

            var catalogue = new Mock<ICatalogueBll>();
            catalogue.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(new List<AbstractAutorElement>());

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(removekDao);

            var authorElement = new Mock<AbstractAutorElement>();
            var catalogue = new Mock<ICatalogueBll>();
            catalogue.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(new List<AbstractAutorElement>() { authorElement.Object });

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(() => throw new Exception());

            var catalogue = new Mock<ICatalogueBll>();
            catalogue.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(new List<AbstractAutorElement>());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, catalogue.Object, null);

            // Act

            TestDelegate author = () => authorBll.Remove(0);

            // Assert

            Assert.Throws(typeof(RemoveException), author);
        }

        [Test]
        public void Search()
        {
            // Arrange

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, AuthorSearchOptions>>())).Returns(new List<Author>());

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

            var authorDao = new Mock<IAuthorDao>();
            authorDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, AuthorSearchOptions>>())).Returns(() => throw new Exception());

            IAuthorBll authorBll = new AuthorBll(authorDao.Object, null, null);

            // Act

            TestDelegate author = () => authorBll.Search(new SearchRequest<SortOptions, AuthorSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), author);
        }
    }
}

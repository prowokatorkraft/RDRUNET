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

namespace Epam.Library.Test
{
    [TestFixture]
    public class BookBllTests
    {
        [TestCaseSource(typeof(BookBllTestCases), nameof(BookBllTestCases.AddTestCases))]
        public bool Add(ErrorValidation error)
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bool isAddDao = false;
            bookDao.Setup(a => a.Add(It.IsAny<AbstractBook>())).Callback(() => isAddDao = true);

            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            var validation = new Mock<IValidationBll<AbstractBook>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractBook>()))
                .Returns(listErrors);

            var bookBll = new BookBll(bookDao.Object, null, validation.Object);

            // Act

            var errors = bookBll.Add(new Book());

            // Assert

            return isAddDao;
        }

        [Test]
        public void Add_Exeption()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Add(It.IsAny<AbstractBook>())).Callback(() => throw new Exception());

            var validation = new Mock<IValidationBll<AbstractBook>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractBook>()))
                .Returns(new List<ErrorValidation>());

            var bookBll = new BookBll(bookDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => bookBll.Add(new Book());

            // Assert

            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Add_Exeption_Null()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Add(It.IsAny<AbstractBook>()));

            var validation = new Mock<IValidationBll<AbstractBook>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractBook>()))
                .Returns(new List<ErrorValidation>());

            var bookBll = new BookBll(bookDao.Object, null, validation.Object);

            // Act

            TestDelegate action = () => bookBll.Add(null);

            // Assert

            Assert.Throws(typeof(AddException), action);
        }

        [Test]
        public void Get()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Get(It.IsAny<int>())).Returns(new Book());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.Get(0);

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Get(It.IsAny<int>())).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        [Test]
        public void Get_Exception_Null()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Get(It.IsAny<int>())).Returns(() => null);

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(removeDao);

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var author = bookBll.Remove(0);

            // Assert

            return author;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Remove(0);

            // Assert

            Assert.Throws(typeof(RemoveException), book);
        }

        [Test]
        public void Search()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, BookSearchOptions>>())).Returns(new List<AbstractBook>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>());

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void Search_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, BookSearchOptions>>())).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublishYear()).Returns(new Dictionary<int, List<AbstractBook>>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void GetAllGroupsByPublishYear_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublishYear()).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        [Test]
        public void GetAllGroupsByPublisher()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublisher("")).Returns(new Dictionary<string, List<AbstractBook>>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.GetAllGroupsByPublisher("");

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void GetAllGroupsByPublisher_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublisher("")).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetAllGroupsByPublisher("");

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        [Test]
        public void GetByAuthorId()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(new List<AbstractBook>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.GetByAuthorId(0);

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void GetByAuthorId_Exception()
        {
            // Arrange

            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetByAuthorId(It.IsAny<int>())).Returns(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetByAuthorId(0);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }
    }
}
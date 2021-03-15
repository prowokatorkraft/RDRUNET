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
            bool isAddDao = false;
            Mock<IBookDao> bookDao = InitializeMockDaoForAdd(() => isAddDao = true);
            var listErrors = new List<ErrorValidation>();
            if (error != null)
            {
                listErrors.Add(error);
            }
            Mock<IValidationBll<AbstractBook>> validation = InitializeMockValidationForAdd(() => listErrors);
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
            Mock<IBookDao> bookDao = InitializeMockDaoForAdd(() => throw new Exception());
            Mock<IValidationBll<AbstractBook>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
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
            Mock<IBookDao> bookDao = InitializeMockDaoForAdd(() => { });
            Mock<IValidationBll<AbstractBook>> validation = InitializeMockValidationForAdd(() => new List<ErrorValidation>());
            var bookBll = new BookBll(bookDao.Object, null, validation.Object);

            // Act
            TestDelegate action = () => bookBll.Add(null);

            // Assert
            Assert.Throws(typeof(AddException), action);
        }

        private static Mock<IBookDao> InitializeMockDaoForAdd(Action action)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Add(It.IsAny<AbstractBook>())).Callback(action);
            return bookDao;
        }

        private static Mock<IValidationBll<AbstractBook>> InitializeMockValidationForAdd(Func<IEnumerable<ErrorValidation>> func)
        {
            var validation = new Mock<IValidationBll<AbstractBook>>();
            validation.Setup<IEnumerable<ErrorValidation>>(a => a.Validate(It.IsAny<AbstractBook>()))
                .Returns(func);
            return validation;
        }

        [Test]
        public void Get()
        {
            // Arrange

            Mock<AbstractBook> bookValue = new Mock<AbstractBook>();

            Mock<IBookDao> bookDao = InitializeMockDaoForGet(() => bookValue.Object);

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

            Mock<IBookDao> bookDao = InitializeMockDaoForGet(() => throw new Exception());

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

            Mock<IBookDao> bookDao = InitializeMockDaoForGet(() => null);

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Get(0);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForGet(Func<AbstractBook> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Get(It.IsAny<int>())).Returns(func);
            return bookDao;
        }

        [TestCase(true, ExpectedResult = true)]
        [TestCase(false, ExpectedResult = false)]
        public bool Remove(bool removeDao)
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForRemove(() => removeDao);

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.Remove(0);

            // Assert

            return book;
        }

        [Test]
        public void Remove_Exception()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForRemove(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Remove(0);

            // Assert

            Assert.Throws(typeof(RemoveException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForRemove(Func<bool> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Remove(It.IsAny<int>())).Returns(func);
            return bookDao;
        }

        [Test]
        public void Search()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForSearch(() => new List<AbstractBook>());

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

            Mock<IBookDao> bookDao = InitializeMockDaoForSearch(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.Search(new SearchRequest<SortOptions, BookSearchOptions>());

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForSearch(Func<IEnumerable<AbstractBook>> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.Search(It.IsAny<SearchRequest<SortOptions, BookSearchOptions>>())).Returns(func);
            return bookDao;
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForGroupsByPublishYear(() => new Dictionary<int, List<AbstractBook>>());

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

            Mock<IBookDao> bookDao = InitializeMockDaoForGroupsByPublishYear(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetAllGroupsByPublishYear();

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForGroupsByPublishYear(Func<Dictionary<int,List<AbstractBook>>> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublishYear()).Returns(func);
            return bookDao;
        }

        [Test]
        public void GetAllGroupsByPublisher()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForGropusByPublisher(() => new Dictionary<string, List<AbstractBook>>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.GetAllGroupsByPublisher(null);

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void GetAllGroupsByPublisher_Exception()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForGropusByPublisher(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetAllGroupsByPublisher(null);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForGropusByPublisher(Func<Dictionary<string, List<AbstractBook>>> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetAllGroupsByPublisher(null)).Returns(func);
            return bookDao;
        }

        [Test]
        public void GetByAuthorId()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForGetByAuthorId(() => new List<AbstractBook>());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            var book = bookBll.GetByAuthorId(0, null);

            // Assert

            Assert.NotNull(book);
        }

        [Test]
        public void GetByAuthorId_Exception()
        {
            // Arrange

            Mock<IBookDao> bookDao = InitializeMockDaoForGetByAuthorId(() => throw new Exception());

            var bookBll = new BookBll(bookDao.Object, null, null);

            // Act

            TestDelegate book = () => bookBll.GetByAuthorId(0, null);

            // Assert

            Assert.Throws(typeof(GetException), book);
        }

        private static Mock<IBookDao> InitializeMockDaoForGetByAuthorId(Func<IEnumerable<AbstractBook>> func)
        {
            var bookDao = new Mock<IBookDao>();
            bookDao.Setup(a => a.GetByAuthorId(It.IsAny<int>(), It.IsAny<PagingInfo>())).Returns(func);
            return bookDao;
        }
    }
}
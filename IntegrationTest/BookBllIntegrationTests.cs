using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.IntegrationTest
{
    public class BookBllIntegrationTests
    {
        private IBookBll _bookBll;
        private ICatalogueBll _catalogueBll;
        private IAuthorBll _authorBll;

        private List<int> _bookIDs;
        private List<int> _authorIDs;

        [OneTimeSetUp]
        public void InitClass()
        {
            _bookBll = NinjectForTests.BookBll;
            _catalogueBll = NinjectForTests.CatalogueBll;
            _authorBll = NinjectForTests.AuthorBll;

            _bookIDs = new List<int>();
            _authorIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _bookIDs.ForEach(a => _bookBll.Remove(a, RoleType.admin));

            _authorIDs.ForEach(a => _authorBll.Remove(a, RoleType.admin));
        }

        [Test]
        public void Add_True()
        {
            // Arrange
            Book book = new Book(null, "Add-True", 0, null, false, null, "Test", "Test", 2020, null);
            int preCount = GetCount();
            int id;

            // Act
            var errors = _bookBll.Add(book);
            _bookIDs.Add(id = GetId(book).Value);
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
            Book book = new Book();
            int preCount = GetCount();

            // Act
            var errors = _bookBll.Add(book);
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
            TestDelegate test = () => _bookBll.Add(null);

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
            Book book1 = new Book(null, "Add-True", 0, null, false, null, "Test", "Test", 2020, null);
            Book book2 = new Book(null, "Addtrue-True", 0, null, false, null, "Test", "Test", 2020, null);
            int id;

            _bookBll.Add(book1);
            _bookIDs.Add(id = GetId(book1).Value);
            book2.Id = id;

            int preCount = GetCount();

            // Act
            var errors = _bookBll.Update(book2);

            int postCount = GetCount();

            // Assert
            Assert.Multiple(() =>
            {
                Assert.AreEqual(0, errors.Count());
                Assert.AreEqual(preCount, postCount);
                Assert.IsTrue(book2.Equals(_bookBll.Get(book2.Id.Value)));
            });
        }

        [Test]
        public void Update_False()
        {
            // Arrange
            Book book = new Book(-100, null, 0, null, false, null, null, null, 0, null);
            int preCount = GetCount();

            // Act
            var errors = _bookBll.Update(book);
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
            TestDelegate test = () => _bookBll.Update(null);

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
            TestDelegate test = () => _bookBll.Update(new Book(null,null,0,null,false,null,null,null,0,null));

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
            Book book = new Book(null, "Remove-True", 0, null, false, null, "Test", "Test", 2020, null);

            _bookBll.Add(book);

            int id = GetId(book).Value;

            int preCount = GetCount();

            // Act
            _bookBll.Remove(id, RoleType.admin);

            int postCount = GetCount();

            if (preCount == postCount)
            {
                _bookIDs.Add(id);
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
            TestDelegate test = () => _bookBll.Remove(-30000);

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
            Book book = new Book(null, "Get", 0, null, false, null, "Test", "Test", 2020, null);
            _bookBll.Add(book);

            int id;
            _bookIDs.Add(id = GetId(book).Value);

            // Act
            var element = _bookBll.Get(id);

            // Assert
            Assert.Multiple(() =>
            {
                Assert.IsNotNull(element);
                Assert.AreEqual(book, element);
            });
        }

        [Test]
        public void Get_Exception()
        {
            // Arrange
            TestDelegate test = () => _bookBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [TestCaseSource(typeof(BookBllIntegrationTestCases), nameof(BookBllIntegrationTestCases.Search))]
        public bool Search(Book book, SearchRequest<SortOptions, BookSearchOptions> request)
        {
            // Arrange
            if (book != null)
            {
                _bookBll.Add(book);

                _bookIDs.Add(GetId(book).Value);
            }

            //Act
            bool result = _bookBll.Search(request).Any(a => a.Equals(book));

            // Assert
            return result;
        }

        [TestCaseSource(typeof(BookBllIntegrationTestCases), nameof(BookBllIntegrationTestCases.GetByAuthorId))]
        public bool GetByAuthorId(Author author, Book book)
        {
            // Arrange
            _authorBll.Add(author);
            int idAuthors;

            _authorIDs.Add(idAuthors = GetId(author).Value);

            if (book != null)
            {
                book.AuthorIDs = new int[] { idAuthors };

                _bookBll.Add(book);

                _bookIDs.Add(GetId(book).Value);
            }

            //Act
            var result = _bookBll.GetByAuthorId(idAuthors, null).Any();

            // Assert
            return result;
        }

        [TestCase(null)]
        [TestCase("Test")]
        public void GetAllGroupsByPublisher(string stringLine)
        {
            // Arrange
            Book[] books = new Book[]
            {
                new Book(null, "GpoupsByPublisher-One " + stringLine, 0, null, false, null, "Test One", "Test", 2000, null),
                new Book(null, "GpoupsByPublisher-Two " + stringLine, 0, null, false, null, "Test Two", "Test", 2000, null)
            };

            List<int> ids = new List<int>();

            foreach (var item in books)
            {
                _bookBll.Add(item);

                ids.Add(GetId(item).Value);
            }

            _bookIDs.AddRange(ids);

            // Act
            int result = _bookBll.GetAllGroupsByPublisher(new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Name, stringLine)).Count();

            // Assert
            Assert.IsTrue(result >= 2);
        }

        [Test]
        public void GetAllGroupsByPublishYear()
        {
            // Arrange
            Book[] books = new Book[]
            {
                new Book(null, "GpoupsByPublishYear-One", 0, null, false, null, "Test", "Test", 2000, null),
                new Book(null, "GpoupsByPublishYear-Two", 0, null, false, null, "Test", "Test", 2008, null)
            };

            List<int> ids = new List<int>();

            foreach (var item in books)
            {
                _bookBll.Add(item);

                ids.Add(GetId(item).Value);
            }

            _bookIDs.AddRange(ids);

            // Act
            int result = _bookBll.GetAllGroupsByPublishYear().Count();

            // Assert
            Assert.IsTrue(result >= 2);
        }

        private int GetCount()
        {
            return _bookBll.Search(null).Count();
        }

        private int? GetId(Book book)
        {
            return _bookBll.Search(null)
                .Where(a => a.Equals(book))
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

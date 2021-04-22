using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.IntegrationTest.TestCases;
using NUnit.Framework;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.IntegrationTest
{
    public class CatalogueBllIntegrationTests
    {
        private ICatalogueBll _catalogueBll;
        private IBookBll _bookBll;
        private IPatentBll _patentBll;
        private IAuthorBll _authorBll;

        private List<int> _bookIDs;
        private List<int> _patentIDs;
        private List<int> _authorIDs;

        [OneTimeSetUp]
        public void InitClass()
        {
            _bookBll = NinjectForTests.BookBll;
            _patentBll = NinjectForTests.PatentBll;
            _authorBll = NinjectForTests.AuthorBll;
            _catalogueBll = NinjectForTests.CatalogueBll;

            _bookIDs = new List<int>();
            _patentIDs = new List<int>();
            _authorIDs = new List<int>();
        }

        [OneTimeTearDown]
        public void DiposeClass()
        {
            _bookIDs.ForEach(a => _bookBll.Remove(a, RoleType.admin));

            _patentIDs.ForEach(a => _patentBll.Remove(a, RoleType.admin));

            _authorIDs.ForEach(a => _authorBll.Remove(a, RoleType.admin));
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
            var element = _catalogueBll.Get(id);

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
            TestDelegate test = () => _catalogueBll.Get(-30000);

            // Assert
            Assert.Throws<LayerException>(test);
        }

        [TestCaseSource(typeof(CatalogueBllIntegrationTestCases), nameof(CatalogueBllIntegrationTestCases.Search))]
        public bool Search(Book book, SearchRequest<SortOptions, CatalogueSearchOptions> request)
        {
            // Arrange
            if (book != null)
            {
                _bookBll.Add(book);

                _bookIDs.Add(GetId(book).Value);
            }

            //Act
            bool result = _catalogueBll.Search(request).Any(a => a.Equals(book));

            // Assert
            return result;
        }

        [TestCaseSource(typeof(CatalogueBllIntegrationTestCases), nameof(CatalogueBllIntegrationTestCases.GetByAuthorId))]
        public int GetByAuthorId(Author author, Book book, Patent patent)
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

            if (patent != null)
            {
                patent.AuthorIDs = new int[] { idAuthors };

                _patentBll.Add(patent);

                _patentIDs.Add(GetId(patent).Value);
            }

            //Act
            var result = _catalogueBll.GetByAuthorId(idAuthors).Count();

            // Assert
            return result;
        }

        private int? GetId(LibraryAbstractElement element)
        {
            return _catalogueBll.Search(null)
                .Where(a => a.Equals(element))
                .LastOrDefault()
                ?.Id.Value;
        }

        private int? GetId(Author author)
        {
            return _authorBll.Search(null)
                .Where(a => a.Equals(author))
                ?.Max(b => b.Id);
        }
    }
}

using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using NUnit.Framework;
using System.Collections;

namespace Epam.Library.IntegrationTest.TestCases
{
    public static class BookBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new Book(null, "Search Null", 0, null, null, "Test", "Test", 2020, null),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Book(null, "Test One", 0, null, null, "Test", "Test", 2020, null),
                    new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Book(null, "Test Name", 0, null, null, "Test", "Test", 2020, null),
                    new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Name, "Test Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Name, "------------------------")
                ).Returns(false);

                yield return new TestCaseData
                (
                    new Book(null, "Test Two", 0, null, null, "Test Publisher", "Test", 2020, null),
                    new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Publisher, "Test Publisher")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, BookSearchOptions>(SortOptions.None, BookSearchOptions.Publisher, "------------------------")
                ).Returns(false);
            }
        }

        public static IEnumerable GetByAuthorId
        {
            get
            {
                yield return new TestCaseData
                (
                    new Author(null, "Getbyauthorid", "One"),
                    null
                ).Returns(false);

                yield return new TestCaseData
                (
                    new Author(null, "Getbyauthorid", "Two"),
                    new Book(null, "Getbyauthorid Two", 0, null, null, "Test", "Test", 2020, null)
                ).Returns(true);
            }
        }
    }
}

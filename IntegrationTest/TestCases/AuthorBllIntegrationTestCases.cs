using System;
using System.Collections;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.SearchOptionsEnum;
using NUnit.Framework;

namespace IntegrationTest.TestCases
{
    public static class AuthorBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new Author(null, "Search", "Null"),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Author(null, "Test-One", "Test-One"), 
                    new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.None, AuthorSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Author(null, "First-Name", "Search"),
                    new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.None, AuthorSearchOptions.FirstName, "First-Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Author(null, "Search", "Last-Name"),
                    new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.None, AuthorSearchOptions.LastName, "Last-Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.None, AuthorSearchOptions.FirstName, "--------")
                ).Returns(false);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, AuthorSearchOptions>(SortOptions.None, AuthorSearchOptions.LastName, "--------")
                ).Returns(false);
            }
        }
    }
}

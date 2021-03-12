using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.IntegrationTest.TestCases
{
    public static class CatalogueBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new Book(null, "Search Null", 0, null, false, null, "Test", "Test", 2020, null),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Book(null, "Test One", 0, null, false, null, "Test", "Test", 2020, null),
                    new SearchRequest<SortOptions, CatalogueSearchOptions>(SortOptions.None, CatalogueSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Book(null, "Test Name", 0, null, false, null, "Test", "Test", 2020, null),
                    new SearchRequest<SortOptions, CatalogueSearchOptions>(SortOptions.None, CatalogueSearchOptions.Name, "Test Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, CatalogueSearchOptions>(SortOptions.None, CatalogueSearchOptions.Name, "------------------------")
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
                    null,
                    null
                ).Returns(0);

                yield return new TestCaseData
                (
                    new Author(null, "Getbyauthorid", "Two"),
                    new Book(null, "Getbyauthorid Two Book", 0, null, false, null, "Test", "Test", 2020, null),
                    null
                ).Returns(1);

                yield return new TestCaseData
                (
                    new Author(null, "Getbyauthorid", "Three"),
                    null,
                    new Patent(null, "Getbyauthorid Three Patent", 0, null, false, null, "Test", "123356389", null, DateTime.Now)
                ).Returns(1);

                yield return new TestCaseData
                (
                    new Author(null, "Getbyauthorid", "Four"),
                    new Book(null, "Getbyauthorid Four Book", 0, null, false, null, "Test", "Test", 2020, null),
                    new Patent(null, "Getbyauthorid Four Patent", 0, null, false, null, "Test", "123396382", null, DateTime.Now)
                ).Returns(2);
            }
        }
    }
}
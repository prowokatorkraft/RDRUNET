using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.IntegrationTest.TestCases
{
    public static class PatentBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new Patent(null, "Search Null", 0, null, null, "Test", "193456789", null, DateTime.Now),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Patent(null, "Test One", 0, null, null, "Test", "143456789", null, DateTime.Now),
                    new SearchRequest<SortOptions, PatentSearchOptions>(SortOptions.None, PatentSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Patent(null, "Test Name", 0, null, null, "Test", "123456789", null, DateTime.Now),
                    new SearchRequest<SortOptions, PatentSearchOptions>(SortOptions.None, PatentSearchOptions.Name, "Test Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, PatentSearchOptions>(SortOptions.None, PatentSearchOptions.Name, "------------------------")
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
                    new Patent(null, "Getbyauthorid Two", 0, null, null, "Test", "123356789", null, DateTime.Now)
                ).Returns(true);
            }
        }
    }
}

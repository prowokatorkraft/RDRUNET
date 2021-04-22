using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.IntegrationTest.TestCases
{
    public static class NewspaperBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new Newspaper(null, "Search Null", null, false),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Newspaper(null, "Test One", null, false),
                    new SearchRequest<SortOptions, NewspaperSearchOptions>(SortOptions.None, NewspaperSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new Newspaper(null, "Test Name", null, false),
                    new SearchRequest<SortOptions, NewspaperSearchOptions>(SortOptions.None, NewspaperSearchOptions.Name, "Test Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, NewspaperSearchOptions>(SortOptions.None, NewspaperSearchOptions.Name, "------------------------")
                ).Returns(false);
            }
        }
    }
}

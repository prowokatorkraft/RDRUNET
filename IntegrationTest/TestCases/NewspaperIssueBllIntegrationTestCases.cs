using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using NUnit.Framework;
using System;
using System.Collections;

namespace Epam.Library.IntegrationTest.TestCases
{
    class NewspaperIssueBllIntegrationTestCases
    {
        public static IEnumerable Search
        {
            get
            {
                yield return new TestCaseData
                (
                    new NewspaperIssue(null, "Search Null", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, -1),
                    null
                ).Returns(true);

                yield return new TestCaseData
                (
                    new NewspaperIssue(null, "Test One", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, -1),
                    new SearchRequest<SortOptions, NewspaperIssueSearchOptions>(SortOptions.None, NewspaperIssueSearchOptions.None, null)
                ).Returns(true);

                yield return new TestCaseData
                (
                    new NewspaperIssue(null, "Test Name", 0, null, false, "Test", "Test", DateTime.Now.Year, null, DateTime.Now, -1),
                    new SearchRequest<SortOptions, NewspaperIssueSearchOptions>(SortOptions.None, NewspaperIssueSearchOptions.Name, "Test Name")
                ).Returns(true);

                yield return new TestCaseData
                (
                    null,
                    new SearchRequest<SortOptions, NewspaperIssueSearchOptions>(SortOptions.None, NewspaperIssueSearchOptions.Name, "------------------------")
                ).Returns(false);
            }
        }
    }
}

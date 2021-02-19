using System.Collections;
using Epam.Library.Common.Entities;
using NUnit.Framework;

namespace Epam.Library.Test.TestCases
{
    public static class PatentBllTestCases
    {
        public static IEnumerable AddTestCases
        {
            get
            {
                yield return new TestCaseData(null).Returns(true);
                yield return new TestCaseData(new ErrorValidation()).Returns(false);
            }
        }
    }
}

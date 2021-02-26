using System;
using System.Globalization;

namespace Epam.Library.Bll.Validation
{
    public static class ValidationLengths
    {
        public const int FirstNameLength = 50;

        public const int LastNameLength = 200;

        public const int NameLength = 300;

        public const int AnnotationLength = 2000;

        public const int PublisherLength = 300;

        public const int PublishingCityLength = 200;

        public const int MinPublishingYearLength = 1400;

        public const int IsbnLength = 18;

        public const int CountryLength = 200;

        public const string MinApplicationDateRange = "01.01.1474";

        public const string MinDateOfPublicationRange = MinApplicationDateRange;
    }
}

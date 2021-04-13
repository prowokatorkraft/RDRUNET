using System;

namespace Epam.Library.Common.Entities.Newspaper
{
    public abstract class AbstractOldNewspaper : LibraryAbstractElement
    {
        public abstract string Publisher { get; set; }

        public abstract string PublishingCity { get; set; }

        public abstract int PublishingYear { get; set; }

        public abstract string Issn { get; set; }

        public abstract string Number { get; set; }

        public abstract DateTime Date { get; set; }
    }
}

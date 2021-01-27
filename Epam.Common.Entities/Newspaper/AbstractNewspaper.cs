using System;

namespace Epam.Common.Entities.Newspaper
{
    public abstract class AbstractNewspaper : AbstractElement
    {
        public abstract NewspaperPublishingHouse PublishingHouse { get; set; }

        public abstract string Number { get; set; }

        public abstract DateTime Date { get; set; }

        protected AbstractNewspaper(string name, int numberOfPages, NewspaperPublishingHouse publishingHouse, DateTime date)
            : base(name, numberOfPages)
        {
            PublishingHouse = publishingHouse;
            Date = date;
        }
    }
}

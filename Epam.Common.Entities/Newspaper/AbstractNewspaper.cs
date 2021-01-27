namespace Epam.Common.Entities.Newspaper
{
    public abstract class AbstractNewspaper : AbstractElement
    {
        public abstract NewspaperPublishingHouse PublishingHouse { get; set; }

        protected AbstractNewspaper(string name, int numberOfPages, NewspaperPublishingHouse publishingHouse)
            : base(name, numberOfPages)
        {
            PublishingHouse = publishingHouse;
        }
    }
}

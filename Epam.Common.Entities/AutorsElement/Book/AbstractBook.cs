namespace Epam.Common.Entities.AutorsElement.Book
{
    public abstract class AbstractBook : AbstractAutorsElement
    {
        public abstract BookPublishingHouse PublishingHouse { get; set; }

        protected AbstractBook(string name, int numberOfPages, BookPublishingHouse publishingHouse) 
            : base(name, numberOfPages)
        {
            PublishingHouse = publishingHouse;
        }
    }
}

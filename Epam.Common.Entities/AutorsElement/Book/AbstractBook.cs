namespace Epam.Library.Common.Entities.AutorsElement.Book
{
    public abstract class AbstractBook : AbstractAutorsElement
    {
        public abstract string PublishingHouse { get; set; }
        
        public abstract string PublishingCity { get; set; }
        
        public abstract int PublishingYear { get; set; }

        public abstract string Isbn { get; set; }

        protected AbstractBook(string name, int numberOfPages, string publishingHouse, string publishingCity, int publishingYear) 
            : base(name, numberOfPages)
        {
            PublishingHouse = publishingHouse;
            PublishingCity = publishingCity;
            PublishingYear = publishingYear;
        }
    }
}

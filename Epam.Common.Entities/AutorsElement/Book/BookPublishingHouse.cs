namespace Epam.Common.Entities.AutorsElement.Book
{
    public class BookPublishingHouse : PublishingHouse
    {
        public string Isbn { get; set; }

        public BookPublishingHouse(string name, string publishingCity, int publishingYear, string isbn) 
            : base(name, publishingCity, publishingYear)
        {
            Isbn = isbn;
        }
        public BookPublishingHouse(string name, string publishingCity, int publishingYear)
            : base(name, publishingCity, publishingYear)
        {

        }
    }
}

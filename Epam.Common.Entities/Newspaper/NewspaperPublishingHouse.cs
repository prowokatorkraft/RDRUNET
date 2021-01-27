namespace Epam.Common.Entities.Newspaper
{
    public class NewspaperPublishingHouse : PublishingHouse
    {
        public string Issn { get; set; }

        public NewspaperPublishingHouse(string name, string publishingCity, int publishingYear, string issn)
            : base(name, publishingCity, publishingYear)
        {
            Issn = issn;
        }
        public NewspaperPublishingHouse(string name, string publishingCity, int publishingYear)
            : base(name, publishingCity, publishingYear)
        {
            
        }
    }
}

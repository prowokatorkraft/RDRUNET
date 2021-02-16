namespace Epam.Library.Common.Entities.AuthorElement.Book
{
    public abstract class AbstractBook : AbstractAuthorElement
    {
        public abstract string Publisher { get; set; }
        
        public abstract string PublishingCity { get; set; }
        
        public abstract int PublishingYear { get; set; }

        public abstract string Isbn { get; set; }
    }
}

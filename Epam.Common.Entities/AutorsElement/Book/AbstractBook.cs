namespace Epam.Library.Common.Entities.AutorsElement.Book
{
    public abstract class AbstractBook : AbstractAutorsElement
    {
        public abstract string Publisher { get; set; }
        
        public abstract string PublishingCity { get; set; }
        
        public abstract int PublishingYear { get; set; }

        public abstract string Isbn { get; set; }
    }
}

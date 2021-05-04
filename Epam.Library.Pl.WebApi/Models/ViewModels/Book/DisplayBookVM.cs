using System.Collections.Generic;

namespace Epam.Library.Pl.WebApi.Models
{
    public class DisplayBookVM
    {
        public int? Id { get; set; }

        public string Name { get; set; }

        public int NumberOfPages { get; set; }

        public string Annotation { get; set; }

        public string Publisher { get; set; }

        public string PublishingCity { get; set; }

        public int PublishingYear { get; set; }

        public string Isbn { get; set; }

        public IEnumerable<AuthorVM> Authors { get; set; }
    }
}
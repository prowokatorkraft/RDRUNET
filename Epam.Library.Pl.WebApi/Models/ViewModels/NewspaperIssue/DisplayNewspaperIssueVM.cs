using System;

namespace Epam.Library.Pl.WebApi.Models
{
    public class DisplayNewspaperIssueVM
    {
        public int? Id { get; set; }
        public string Name { get; set; }
        public int NumberOfPages { get; set; }
        public string Annotation { get; set; }
        public string Publisher { get; set; }
        public string PublishingCity { get; set; }
        public int? Number { get; set; }
        public DateTime Date { get; set; }
        public DisplayNewspaperVM Newspaper { get; set; }
    }
}
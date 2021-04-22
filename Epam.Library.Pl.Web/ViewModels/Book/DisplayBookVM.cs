using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class DisplayBookVM
    {
        public int? Id { get; set; }

        public string Name { get; set; }

        [Display(Name = "Number of pages")]
        public int NumberOfPages { get; set; }

        public string Annotation { get; set; }

        public string Authors { get; set; }

        public string Publisher { get; set; }

        [Display(Name = "Publishing year")]
        public string PublishingCity { get; set; }

        [Display(Name = "Publishing city")]
        public int PublishingYear { get; set; }

        [Display(Name = "ISBN")]
        public string Isbn { get; set; }
    }
}
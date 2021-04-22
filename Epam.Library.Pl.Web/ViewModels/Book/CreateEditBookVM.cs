using Epam.Library.Pl.Web.Models;
using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateEditBookVM
    {
        public int? Id { get; set; }

        [Required]
        [MaxLength(length: ValidationLengths.NameLength, ErrorMessage = "Value exceeds the allowed size.")]
        public string Name { get; set; }

        [Display(Name = "Number of pages")]
        [Range(1, int.MaxValue, ErrorMessage = "Value exceeds the allowed size.")]
        public int NumberOfPages { get; set; }

        [MaxLength(length: ValidationLengths.AnnotationLength, ErrorMessage = "Value exceeds the allowed size.")]
        public string Annotation { get; set; }

        [Display(Name = "Authors")]
        public int[] AuthorIDs { get; set; }

        [Required]
        [MaxLength(length: ValidationLengths.PublisherLength, ErrorMessage = "Value exceeds the allowed size.")]
        public string Publisher { get; set; }

        [Required]
        [Display(Name = "Publishing city")]
        [RegularExpression(ValidationPatterns.PublishingCityPattern, ErrorMessage = "Incorrect entered value.")]
        public string PublishingCity { get; set; }

        [Display(Name = "Publishing year")]
        [Range(ValidationLengths.MinPublishingYearLength, int.MaxValue, ErrorMessage = "Value exceeds the allowed size.")] 
        public int PublishingYear { get; set; }

        [Display(Name = "ISBN")]
        [RegularExpression(ValidationPatterns.IsbnPattern, ErrorMessage = "Incorrect entered value.")]
        public string Isbn { get; set; }
    }
}
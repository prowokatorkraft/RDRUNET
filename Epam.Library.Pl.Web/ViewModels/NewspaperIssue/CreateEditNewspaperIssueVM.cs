using Epam.Library.Pl.Web.Models;
using System;
using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateEditNewspaperIssueVM
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

        [Required]
        [MaxLength(length: ValidationLengths.PublisherLength, ErrorMessage = "Value exceeds the allowed size.")]
        public string Publisher { get; set; }

        [Required]
        [Display(Name = "Publishing city")]
        [RegularExpression(ValidationPatterns.PublishingCityPattern, ErrorMessage = "Incorrect entered value.")]
        public string PublishingCity { get; set; }

        public int? Number { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime Date { get; set; }

        [Display(Name = "Newspaper")]
        public int NewspaperId { get; set; }
    }
}
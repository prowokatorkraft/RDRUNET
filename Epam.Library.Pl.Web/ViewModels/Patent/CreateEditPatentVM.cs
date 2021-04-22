using Epam.Library.Pl.Web.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateEditPatentVM
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
        [MaxLength(length: ValidationLengths.CountryLength, ErrorMessage = "Value exceeds the allowed size.")]
        [MinLength(length: 2, ErrorMessage = "Value exceeds the allowed size.")]
        [RegularExpression(ValidationPatterns.CountryPattern, ErrorMessage = "Incorrect entered value.")]
        public string Country { get; set; }

        [Display(Name = "Registration number")]
        [RegularExpression(ValidationPatterns.RegistrationNumberPattern, ErrorMessage = "Incorrect entered value.")]
        public string RegistrationNumber { get; set; }

        [Display(Name = "Application date")]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime? ApplicationDate { get; set; }

        [Display(Name = "Date of publication")]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime DateOfPublication { get; set; }
    }
}
using Epam.Library.Pl.Web.Models;
using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateEditAuthorVM
    {
        public int? Id { get; set; }

        [Required]
        [MaxLength(length: ValidationLengths.FirstNameLength, ErrorMessage = "Value exceeds the allowed size.")]
        [RegularExpression(ValidationPatterns.FirstNamePattern, ErrorMessage = "Incorrect entered value.")]
        public string FirstName { get; set; }

        [Required]
        [MaxLength(length: ValidationLengths.LastNameLength, ErrorMessage = "Value exceeds the allowed size.")]
        [RegularExpression(ValidationPatterns.LastNamePattern, ErrorMessage = "Incorrect entered value.")]
        public string LastName { get; set; }
    }
}
using Epam.Library.Pl.Web.Models;
using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateEditNewspaperVM
    {
        public int? Id { get; set; }

        [Required]
        [MaxLength(length: ValidationLengths.NameLength, ErrorMessage = "Value exceeds the allowed size.")]
        public string Name { get; set; }

        [RegularExpression(ValidationPatterns.IssnPattern, ErrorMessage = "Incorrect entered value.")]
        public string ISSN { get; set; }
    }
}
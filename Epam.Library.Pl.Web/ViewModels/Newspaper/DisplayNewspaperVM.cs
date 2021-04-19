using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class DisplayNewspaperVM
    {
        public int? Id { get; set; }

        [Display(Name = "Name newspaper")]
        public string Name { get; set; }

        public string ISSN { get; set; }

        public bool IsDeleted { get; set; }
    }
}
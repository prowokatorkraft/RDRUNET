using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class ElementVM
    {
        public string Name { get; set; }
        public string Identity { get; set; }

        [Display(Name = "Number of pages")]
        public int NumberOfPages { get; set; }
    }
}
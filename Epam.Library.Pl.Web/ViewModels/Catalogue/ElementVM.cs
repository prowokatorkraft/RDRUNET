using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class ElementVM
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Identity { get; set; }
        
        [Display(Name = "Number of pages")]
        public int NumberOfPages { get; set; }

        public bool IsDeleted { get; set; }
        public TypeEnumVM Type { get; set; }
    }
}
namespace Epam.Library.Pl.WebApi.Models
{
    public class PageInfoVM
    {
        public int CurrentPage { get; set; } = 1;
        public int? CountPage { get; set; }
        public int SizePage { get; set; } = 20;
    }
}
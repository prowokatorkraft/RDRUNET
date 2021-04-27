namespace Epam.Library.Pl.WebApi.Models
{
    public class SearchFilterVM
    {
        public string SearchOption { get; set; }
        public string SearchLine { get; set; }
        public bool IsDescending { get; set; } = false;
        public int? MinNumberOfPages { get; set; }
        public int? MaxNumberOfPages { get; set; }
    }
}
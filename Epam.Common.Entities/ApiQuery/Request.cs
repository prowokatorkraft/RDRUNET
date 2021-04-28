namespace Epam.Library.Common.Entities.ApiQuery
{
    public class Request
    {
        public int CurrentPage { get; set; } = 1;
        public int SizePage { get; set; } = 20;
        public string SearchOption { get; set; }
        public string SearchLine { get; set; }
        public bool IsDescending { get; set; } = false;
        public int? MinNumberOfPages { get; set; }
        public int? MaxNumberOfPages { get; set; }
    }
}
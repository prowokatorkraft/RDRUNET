namespace Epam.Library.Common.Entities.ApiQuery
{
    public class GetRequest
    {
        public string SearchOption { get; set; }
        public string SearchLine { get; set; }
        public bool IsDescending { get; set; } = false;
    }
}
namespace Epam.Library.Common.Entities
{
    public class PagingInfo
    {
        public int SizePage { get; set; } = 10000;

        public int CurrentPage { get; set; } = 1;

        public PagingInfo()
        {
        }

        public PagingInfo(int sizePage, int page)
        {
            SizePage = sizePage;
            CurrentPage = page;
        }
    }
}

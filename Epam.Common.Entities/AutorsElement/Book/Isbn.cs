namespace Epam.Common.Entities.AutorsElement.Book
{
    public struct Isbn
    {
        public int PlaceOrigin { get; set; }

        public int Code { get; set; }

        public byte UniqueNumber { get; set; }

        public Isbn(int placeOrigin, int code, byte uniqueNumber)
        {
            PlaceOrigin = placeOrigin;
            Code = code;
            UniqueNumber = uniqueNumber;
        }
    }
}

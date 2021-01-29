namespace Epam.Library.Common.Entities
{
    public abstract class LibraryAbstractElement
    {
        public abstract string Name { get; set; }

        public abstract int NumberOfPages { get; set; }

        public abstract string Annotation { get; set; }
    }
}

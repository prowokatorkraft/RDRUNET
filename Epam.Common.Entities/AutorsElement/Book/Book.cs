using System.Collections.Generic;

namespace Epam.Library.Common.Entities.AutorsElement.Book
{
    public class Book : AbstractBook
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Autor[] Autors { get; set; }

        public override string PublishingHouse { get; set; }

        public override string PublishingCity { get; set; }

        public override int PublishingYear { get; set; }

        public override string Isbn { get; set; }

        public Book(string name, int numberOfPages, string publishingHouse, string publishingCity, int publishingYear)
            : base(name, numberOfPages, publishingHouse, publishingCity, publishingYear)
        {

        }

        public override bool Equals(object obj)
        {
            bool isEquals;

            if (Isbn != null)
            {
                isEquals = obj is Book book &&
                            EqualityComparer<string>.Default.Equals(Isbn, book.Isbn);
            }
            else
            {
                isEquals = obj is Book book &&
                            Name == book.Name &&
                            EqualityComparer<Autor[]>.Default.Equals(Autors, book.Autors) &&
                            EqualityComparer<string>.Default.Equals(PublishingHouse, book.PublishingHouse);
            }

            return isEquals;
        }

        public override int GetHashCode()
        {
            int hashCode = 1573203807;

            if (Isbn != null)
            {
                hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Isbn);
            }
            else
            {
                hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
                hashCode = hashCode * -1521134295 + EqualityComparer<Autor[]>.Default.GetHashCode(Autors);
                hashCode = hashCode * -1521134295 + EqualityComparer<int>.Default.GetHashCode(PublishingYear);
            }

            return hashCode;
        }
    }
}

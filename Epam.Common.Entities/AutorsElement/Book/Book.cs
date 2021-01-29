using System.Collections.Generic;

namespace Epam.Library.Common.Entities.AutorsElement.Book
{
    public class Book : AbstractBook
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Author[] Authors { get; set; }

        public override string Publisher { get; set; }

        public override string PublishingCity { get; set; }

        public override int PublishingYear { get; set; }

        public override string Isbn { get; set; }

        public Book()
        {

        }

        public Book(string name, int numberOfPages, string annotation, Author[] authors, 
            string publisher, string publishingCity, int publishingYear, string isbn)
        {
            Name = name;
            NumberOfPages = numberOfPages;
            Annotation = annotation;
            Authors = authors;
            Publisher = publisher;
            PublishingCity = publishingCity;
            PublishingYear = publishingYear;
            Isbn = isbn;
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
                            EqualityComparer<Author[]>.Default.Equals(Authors, book.Authors) &&
                            EqualityComparer<string>.Default.Equals(Publisher, book.Publisher);
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
                hashCode = hashCode * -1521134295 + EqualityComparer<Author[]>.Default.GetHashCode(Authors);
                hashCode = hashCode * -1521134295 + EqualityComparer<int>.Default.GetHashCode(PublishingYear);
            }

            return hashCode;
        }
    }
}

using System.Collections.Generic;

namespace Epam.Common.Entities.AutorsElement.Book
{
    public class Book : AbstractBook
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Autor[] Autors { get; set; }

        public override BookPublishingHouse PublishingHouse { get; set; }

        public Book(string name, int numberOfPages, BookPublishingHouse publishingHouse)
            : base(name, numberOfPages, publishingHouse)
        {

        }

        public override bool Equals(object obj)
        {
            bool isEquals;

            if (PublishingHouse.Isbn != null)
            {
                isEquals = obj is Book book &&
                            EqualityComparer<string>.Default.Equals(PublishingHouse.Isbn, book.PublishingHouse.Isbn);
            }
            else
            {
                isEquals = obj is Book book &&
                            Name == book.Name &&
                            EqualityComparer<Autor[]>.Default.Equals(Autors, book.Autors) &&
                            EqualityComparer<BookPublishingHouse>.Default.Equals(PublishingHouse, book.PublishingHouse);
            }

            return isEquals;
        }

        public override int GetHashCode()
        {
            int hashCode = 1573203807;

            if (PublishingHouse.Isbn != null)
            {
                hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(PublishingHouse.Isbn);
            }
            else
            {
                hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
                hashCode = hashCode * -1521134295 + EqualityComparer<Autor[]>.Default.GetHashCode(Autors);
                hashCode = hashCode * -1521134295 + EqualityComparer<int>.Default.GetHashCode(PublishingHouse.PublishingYear);
            }

            return hashCode;
        }
    }
}

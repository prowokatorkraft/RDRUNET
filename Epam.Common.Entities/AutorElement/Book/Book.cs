using System;
using System.Collections.Generic;
using System.Linq;

namespace Epam.Library.Common.Entities.AuthorElement.Book
{
    public class Book : AbstractBook
    {
        public override int? Id { get; set; }

        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override bool Deleted { get; set; }

        public override int[] AuthorIDs { get; set; }

        public override string Publisher { get; set; }

        public override string PublishingCity { get; set; }

        public override int PublishingYear { get; set; }

        public override string Isbn { get; set; }

        public Book()
        {

        }

        public Book(int? id, string name, int numberOfPages, string annotation, bool deleted, int[] authorIDs, 
            string publisher, string publishingCity, int publishingYear, string isbn)
        {
            Id = id;
            Name = name;
            NumberOfPages = numberOfPages;
            Annotation = annotation;
            Deleted = deleted;
            AuthorIDs = authorIDs;
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
                            EqualityComparer<string>.Default.Equals(Publisher, book.Publisher) &&
                            (((AuthorIDs is null || AuthorIDs.Length == 0) && (book.AuthorIDs is null || book.AuthorIDs.Length == 0)) ||
                            ((AuthorIDs != null && book.AuthorIDs != null && AuthorIDs.Length == book.AuthorIDs.Length) &&
                             AuthorIDs.All(a => book.AuthorIDs.Contains(a))));
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
                
                hashCode = hashCode * -1521134295 + EqualityComparer<int>.Default.GetHashCode(PublishingYear);

                if (AuthorIDs != null)
                {
                    foreach (var item in AuthorIDs)
                    {
                        hashCode = hashCode * -1521134295 + EqualityComparer<int>.Default.GetHashCode(item);
                    }
                }
            }

            return hashCode;
        }

        public override object Clone()
        {
            return new Book(
                Id,
                Name,
                NumberOfPages,
                Annotation,
                Deleted,
                AuthorIDs?.Clone() as int[] ?? null,
                Publisher,
                PublishingCity,
                PublishingYear,
                Isbn
            );
        }
    }
}

using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.Newspaper
{
    public class Newspaper : AbstractNewspaper
    {
        public override int? Id { get; set; }

        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override bool Deleted { get; set; }

        public override string Publisher { get; set; }

        public override string PublishingCity { get; set; }

        public override int PublishingYear { get; set; }

        public override string Issn { get; set; }

        public override string Number { get; set; }

        public override DateTime Date { get; set; }

        public Newspaper() 
        {
        
        }

        public Newspaper(int? id, string name, int numberOfPages, string annotation, bool deleted, string publisher, 
            string publishingCity, int publishingYear, string issn, string number, DateTime date)
        {
            Id = id;
            Name = name;
            NumberOfPages = numberOfPages;
            Annotation = annotation;
            Deleted = deleted;
            Publisher = publisher;
            PublishingCity = publishingCity;
            PublishingYear = publishingYear;
            Issn = issn;
            Number = number;
            Date = date;
        }

        public override bool Equals(object obj)
        {
            return obj is Newspaper newspaper &&
                   Name == newspaper.Name &&
                   Publisher == newspaper.Publisher &&
                   Date.Date == newspaper.Date.Date;
        }

        public override int GetHashCode()
        {
            int hashCode = 923829507;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Publisher);
            hashCode = hashCode * -1521134295 + Date.GetHashCode();
            return hashCode;
        }

        public override object Clone()
        {
            return new Newspaper(Id, Name, NumberOfPages, Annotation, Deleted, Publisher, PublishingCity, PublishingYear, Issn, Number, Date);
        }
    }
}

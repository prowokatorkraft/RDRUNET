using Epam.Library.Common.Entities;
using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.Newspaper
{
    public class NewspaperIssue : LibraryAbstractElement
    {
        public override int? Id { get; set; }
        public override string Name { get; set; }
        public override int NumberOfPages { get; set; }
        public override string Annotation { get; set; }
        public override bool Deleted { get; set; }
        public string Publisher { get; set; }
        public string PublishingCity { get; set; }
        public int PublishingYear { get; set; }
        public int? Number { get; set; }
        public DateTime Date { get; set; }
        public int NewspaperId { get; set; }

        public NewspaperIssue()
        {

        }
        public NewspaperIssue(int? id, string name, int numberOfPages, string annotation, bool deleted, string publisher,
            string publishingCity, int publishingYear, int? number, DateTime date, int newspaperId)
        {
            Id = id;
            Name = name;
            NumberOfPages = numberOfPages;
            Annotation = annotation;
            Deleted = deleted;
            Publisher = publisher;
            PublishingCity = publishingCity;
            PublishingYear = publishingYear;
            Number = number;
            Date = date;
            NewspaperId = newspaperId;
        }

        public override bool Equals(object obj)
        {
            return obj is NewspaperIssue newspaper &&
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
            return new NewspaperIssue(Id, Name, NumberOfPages, Annotation, Deleted, Publisher, PublishingCity, PublishingYear, Number, Date, NewspaperId);
        }
    }
}

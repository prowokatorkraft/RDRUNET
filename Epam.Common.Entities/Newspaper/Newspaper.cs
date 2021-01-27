using System;
using System.Collections.Generic;

namespace Epam.Common.Entities.Newspaper
{
    public class Newspaper : AbstractNewspaper
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }
        
        public override NewspaperPublishingHouse PublishingHouse { get; set; }
        
        public override string Number { get; set; }
        
        public override DateTime Date { get; set; }

        public Newspaper(string name, int numberOfPages, NewspaperPublishingHouse publishingHouse, DateTime date)
            : base(name, numberOfPages, publishingHouse, date)
        {
            
        }

        public override bool Equals(object obj)
        {
            return obj is Newspaper newspaper &&
                   Name == newspaper.Name &&
                   EqualityComparer<string>.Default.Equals(PublishingHouse.Name, newspaper.PublishingHouse.Name) &&
                   Date == newspaper.Date;
        }

        public override int GetHashCode()
        {
            int hashCode = 923829507;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(PublishingHouse.Name);
            hashCode = hashCode * -1521134295 + Date.GetHashCode();
            return hashCode;
        }
    }
}

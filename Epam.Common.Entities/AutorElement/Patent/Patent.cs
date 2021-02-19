using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.AuthorElement.Patent
{
    public class Patent : AbstractPatent
    {
        public override int? Id { get; set; }

        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override int[] AuthorIDs { get; set; }

        public override string Country { get; set; }

        public override string RegistrationNumber { get; set; }

        public override DateTime? ApplicationDate { get; set; }

        public override DateTime DateOfPublication { get; set; }

        public Patent()
        {

        }

        public Patent(int? id, string name, int numberOfPages, string annotation, int[] authorIDs, 
            string country, string registrationNumber, DateTime? applicationDate, DateTime dateOfPublication)
        {
            Id = id;
            Name = name;
            NumberOfPages = numberOfPages;
            Annotation = annotation;
            AuthorIDs = authorIDs;
            Country = country;
            RegistrationNumber = registrationNumber;
            ApplicationDate = applicationDate;
            DateOfPublication = dateOfPublication;
        }

        public override bool Equals(object obj)
        {
            return obj is Patent patent &&
                   Country == patent.Country &&
                   RegistrationNumber == patent.RegistrationNumber;
        }

        public override int GetHashCode()
        {
            int hashCode = -1173245029;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Country);
            hashCode = hashCode * -1521134295 + RegistrationNumber.GetHashCode();
            return hashCode;
        }

        public override object Clone()
        {
            return new Patent(Id, Name, NumberOfPages, Annotation, AuthorIDs?.Clone() as int[], Country, RegistrationNumber, ApplicationDate, DateOfPublication);
        }
    }
}

using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.AutorsElement.Patent
{
    public class Patent : AbstractPatent
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Autor[] Autors { get; set; }

        public override string Country { get; set; }

        public override int RegistrationNumber { get; set; }

        public override DateTime ApplicationDate { get; set; }

        public override DateTime DateOfPublication { get; set; }

        public Patent(string name, int numberOfPages, string city, int registrationNumber, DateTime dateOfPublication)
            : base(name, numberOfPages, city, registrationNumber, dateOfPublication)
        {
            
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
    }
}

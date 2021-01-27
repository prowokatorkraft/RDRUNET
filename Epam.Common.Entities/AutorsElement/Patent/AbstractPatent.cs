using System;

namespace Epam.Common.Entities.AutorsElement.Patent
{
    public abstract class AbstractPatent : AbstractAutorsElement
    {
        public abstract string Country { get; set; }

        public abstract int RegistrationNumber { get; set; }

        public abstract DateTime ApplicationDate { get; set; }

        public abstract DateTime DateOfPublication { get; set; }

        protected AbstractPatent(string name, int numberOfPages, string city, 
            int registrationNumber, DateTime applicationDate, DateTime dateOfPublication)
            : this(name, numberOfPages, city, registrationNumber, dateOfPublication)
        {
            ApplicationDate = applicationDate;
        }
        protected AbstractPatent(string name, int numberOfPages, string city,
            int registrationNumber, DateTime dateOfPublication)
            : base(name, numberOfPages)
        {
            Country = city;
            RegistrationNumber = registrationNumber;
            DateOfPublication = dateOfPublication;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement.Patent
{
    public abstract class AbstractPatent : AbstractAutorsElement
    {
        public string City { get; set; }

        public int RegistrationNumber { get; set; }

        public DateTime ApplicationDate { get; set; }

        public DateTime DateOfPublication { get; set; }

        protected AbstractPatent(string name, int numberOfPages, Autor[] autors, string city, 
            int registrationNumber, DateTime applicationDate, DateTime dateOfPublication)
            : this(name, numberOfPages, autors, city, registrationNumber, dateOfPublication)
        {
            ApplicationDate = applicationDate;
        }
        protected AbstractPatent(string name, int numberOfPages, Autor[] autors, string city,
            int registrationNumber, DateTime dateOfPublication)
            : base(name, numberOfPages, autors)
        {
            City = city;
            RegistrationNumber = registrationNumber;
            DateOfPublication = dateOfPublication;
        }
    }
}

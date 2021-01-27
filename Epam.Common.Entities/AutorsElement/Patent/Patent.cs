using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement.Patent
{
    public class Patent : AbstractPatent
    {
        public override string Name { get; set; }

        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Autor[] Autors { get; set; }

        public override string City { get; set; }

        public override int RegistrationNumber { get; set; }

        public override DateTime ApplicationDate { get; set; }

        public override DateTime DateOfPublication { get; set; }

        public Patent(string name, int numberOfPages, string city, int registrationNumber, DateTime dateOfPublication)
            : base(name, numberOfPages, city, registrationNumber, dateOfPublication)
        {
            
        }
    }
}

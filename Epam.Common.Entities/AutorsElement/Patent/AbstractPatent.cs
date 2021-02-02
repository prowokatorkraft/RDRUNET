using System;

namespace Epam.Library.Common.Entities.AutorsElement.Patent
{
    public abstract class AbstractPatent : AbstractAutorsElement
    {
        public abstract string Country { get; set; }

        public abstract string RegistrationNumber { get; set; }

        public abstract DateTime? ApplicationDate { get; set; }

        public abstract DateTime DateOfPublication { get; set; }
    }
}

using System;

namespace Epam.Library.Common.Entities.AuthorElement.Patent
{
    public abstract class AbstractPatent : AbstractAuthorElement
    {
        public abstract string Country { get; set; }

        public abstract string RegistrationNumber { get; set; }

        public abstract DateTime? ApplicationDate { get; set; }

        public abstract DateTime DateOfPublication { get; set; }
    }
}

using System;
using System.Collections.Generic;

namespace Epam.Library.Pl.WebApi.Models
{
    public class DisplayPatentVM
    {
        public int? Id { get; set; }

        public string Name { get; set; }

        public int NumberOfPages { get; set; }

        public string Annotation { get; set; }

        public string Country { get; set; }

        public string RegistrationNumber { get; set; }

        public DateTime? ApplicationDate { get; set; }

        public DateTime DateOfPublication { get; set; }

        public IEnumerable<AuthorVM> Authors { get; set; }
    }
}
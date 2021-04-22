using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class DisplayPatentVM
    {
        public int? Id { get; set; }

        public string Name { get; set; }

        [Display(Name = "Number of pages")]
        public int NumberOfPages { get; set; }

        public string Annotation { get; set; }

        public string Authors { get; set; }

        public string Country { get; set; }

        [Display(Name = "Registration number")]
        public string RegistrationNumber { get; set; }

        [Display(Name = "Application date")]
        public DateTime? ApplicationDate { get; set; }

        [Display(Name = "Date of publication")]
        public DateTime DateOfPublication { get; set; }
    }
}
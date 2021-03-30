using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateBookVM
    {
        [Required]
        public string Name { get; set; }

        public int NumberOfPages { get; set; }

        public string Annotation { get; set; }

        //public int[] AuthorIDs { get; set; }

        [Required]
        public string Publisher { get; set; }

        [Required]
        public string PublishingCity { get; set; }

        public int PublishingYear { get; set; }

        public string Isbn { get; set; }
    }
}
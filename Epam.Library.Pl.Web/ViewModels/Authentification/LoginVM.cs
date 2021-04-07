﻿using System.ComponentModel.DataAnnotations;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class LoginVM
    {
        [Required]
        public string Login { get; set; }

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }
    }
}
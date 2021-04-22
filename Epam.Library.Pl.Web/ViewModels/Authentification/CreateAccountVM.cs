using Epam.Library.Pl.Web.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using RemoteAttribute = System.Web.Mvc.RemoteAttribute;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class CreateAccountVM : IValidatableObject
    {
        [Required]
        [MinLength(length: ValidationLengths.MinLogin, ErrorMessage = "Value exceeds the allowed size.")]
        [RegularExpression(ValidationPatterns.LoginPattern, ErrorMessage = "Incorrect entered value.")]
        [Remote("IsLoginAllowed", "Account", ErrorMessage = "Login already exists.")]
        public string Login { get; set; }

        [Required]
        [DataType(DataType.Password)]
        [MinLength(length: ValidationLengths.MinPassword, ErrorMessage = "Value exceeds the allowed size.")]
        public string Password { get; set; }

        [Display(Name = "Password confirmation")]
        [DataType(DataType.Password)]
        [Compare(nameof(Password), ErrorMessage = "Value does not match.")]
        public string PasswordConfirmation { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            for (int index = 0; index < Password.Length; index++)
            {
                if (char.IsControl(Password, index))
                {
                    yield return new ValidationResult("Password not must include in yourself control characters.", new[] { nameof(Password) });
                }
            }

            if (string.Equals(Login, Password, StringComparison.InvariantCultureIgnoreCase))
            {
                yield return new ValidationResult("Login cannot match password.", new[] { nameof(Password) });
            }
        }
    }
}
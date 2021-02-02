using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;
using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Validation
{
    public class PatentValidation : IValidation<AbstractPatent>
    {
        protected readonly Regex FirstNamePattern = new Regex("^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$", RegexOptions.Singleline);
        
        protected readonly Regex LastNamePattern = new Regex("^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        
        protected readonly Regex CountryPattern = new Regex("^[A-Za-z]+$|^[А-ЯЁа-яё]$", RegexOptions.Singleline);
        
        protected readonly Regex RegistrationNumberPattern = new Regex("^[0-9]{9}$", RegexOptions.Singleline);

        public void Validate(AbstractPatent element)
        {
            if (element is null)
            {
                throw new ArgumentNullException(nameof(element) + " is null!");
            }

            if (element.Name is null)
            {
                throw new NullReferenceException("Name is null!");
            }
            else if (element.Name.Length > 300)
            {
                element.Name = element.Name.Substring(0, 300);
            }

            if (element.NumberOfPages < 0)
            {
                throw new ArgumentException("The number of pages cannot be negative!");
            }

            if (element.Annotation != null && element.Annotation.Length > 2000)
            {
                element.Annotation = element.Annotation.Substring(0, 2000);
            }

            ValidateAndCorrectAutors(element.Authors);

            if (element.Country is null)
            {
                throw new NullReferenceException("Name is null!");
            }
            else
            {
                if (CountryPattern.IsMatch(element.Country))
                {
                    if (element.Country.Length > 3 || element.Country.ToLower().Equals("чад"))
                    {
                        element.Country = ToUpperFirstSimbol(element.Country);
                    }
                    else
                    {
                        element.Country = element.Country.ToUpper();
                    }
                }
                else
                {
                    throw new ArgumentException("Incorrect Country!");
                }
            }

            if (element.RegistrationNumber is null)
            {
                throw new ArgumentNullException("Registration number is null!");
            }
            else
            {
                if (!RegistrationNumberPattern.IsMatch(element.RegistrationNumber))
                {
                    throw new ArgumentException("Incorrect RegistrationNumber! It should only be 9 digits");
                }
            }

            if (element.ApplicationDate != null)
            {
                if (element.ApplicationDate.Value.Year < 1474 && element.ApplicationDate.Value > DateTime.Now)
                {
                    throw new ArgumentException("Incorrect ApplicationDate! It shouldn't be less than 1474 and more than today.");
                }
            }

            if (element.DateOfPublication <= DateTime.Now &&
                (element.ApplicationDate != null && element.DateOfPublication >= element.ApplicationDate ||
                 element.DateOfPublication.Year >= 1474))
            {
                throw new ArgumentException("Incorrect Date of publication!");
            }
        }

        private void ValidateAndCorrectAutors(Author[] autors)
        {
            if (autors != null)
            {
                foreach (var autor in autors)
                {
                    if (autor != null)
                    {
                        if (autor.FirstName != null && FirstNamePattern.IsMatch(autor.FirstName))
                        {
                            string[] str = autor.FirstName.Split('-');

                            ToUpperFirstSimbols(str);

                            string newValue = string.Join("-", str);

                            autor.FirstName = newValue.Length > 50
                                    ? newValue.Substring(0, 50)
                                    : newValue;
                        }
                        else
                        {
                            throw new ArgumentException("Icorrect FirstName!");
                        }

                        if (autor.LastName != null && LastNamePattern.IsMatch(autor.LastName))
                        {
                            string[] str = autor.LastName.Split('-', '\'', ' ');

                            string newValue = "";

                            if (str.Length > 1)
                            {
                                if (Regex.IsMatch(autor.LastName, "-"))
                                {
                                    ToUpperFirstSimbols(str);

                                    newValue = string.Join("-", str);
                                }
                                else if (Regex.IsMatch(autor.LastName, "'"))
                                {
                                    ToUpperFirstSimbols(str);

                                    newValue = string.Join("'", str);
                                }
                                else if (Regex.IsMatch(autor.LastName, " "))
                                {
                                    for (int i = 0; i < str.Length; i++)
                                    {
                                        if (str[i].Length > 1)
                                        {
                                            str[i] = i == 0
                                                ? str[i].ToLower()
                                                : char.ToUpper(str[i].First()) + str[i].Substring(1).ToLower();
                                        }
                                        else
                                        {
                                            str[i] = i == 0
                                                ? str[i].ToLower()
                                                : str[i].ToUpper();
                                        }
                                    }

                                    newValue = string.Join(" ", str);
                                }
                            }
                            else
                            {
                                ToUpperFirstSimbols(str);

                                newValue = str.First();
                            }

                            autor.LastName = newValue.Length > 200
                                    ? newValue.Substring(0, newValue.Length >= 200 ? 200 : newValue.Length)
                                    : newValue;
                        }
                        else
                        {
                            throw new ArgumentException("Icorrect LastName!");
                        }
                    }
                }
            }
        }

        private string ToUpperFirstSimbol(string str)
        {
            return str.Length > 1
                ? char.ToUpper(str.First()) + str.Substring(1).ToLower()
                : str.ToUpper();
        }

        private void ToUpperFirstSimbols(string[] strs)
        {
            for (int i = 0; i < strs.Length; i++)
            {
                if (strs[i].Length > 1)
                {
                    strs[i] = char.ToUpper(strs[i].First()) + strs[i].Substring(1).ToLower();
                }
                else
                {
                    strs[i] = strs[i].ToUpper();
                }
            }
        }
    }
}

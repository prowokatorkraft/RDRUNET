using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;
using System;
using System.Linq;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Logic.Validation
{
    public class BookValidation : IValidation<AbstractBook>
    {
        protected readonly Regex FirstNamePattern = new Regex("^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$", RegexOptions.Singleline);
        
        protected readonly Regex LastNamePattern = new Regex("^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        
        protected readonly Regex PublishingCityPattern = new Regex("^[A-Za-z]+(-| ?)[A-Za-z]+(-| ?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        
        protected readonly Regex IsbnPattern = new Regex("^ISBN ([0-9]{1,5})-([0-9]{1,7})-([0-9]{1,7})-([0-9Xx])$", RegexOptions.Singleline);

        public void ValidateElement(AbstractBook element)
        {
            if (element is null)
            {
                throw new ArgumentNullException((nameof(element) + " is null!"));
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

            if (element.Publisher is null)
            {
                throw new NullReferenceException("Publisher is null!");
            }
            else if (element.Publisher.Length > 300)
            {
                element.Publisher = element.Publisher.Substring(0, 300);
            }

            element.PublishingCity = ValidateAndCorrectPublishingCity(element.PublishingCity);

            if (element.PublishingYear < 1400 || element.PublishingYear > DateTime.Now.Year)
            {
                throw new ArgumentOutOfRangeException("Incorrect PublishingYear!");
            }

            if (element.Isbn != null)
            {
                if (IsbnPattern.IsMatch(element.Isbn))
                {
                    var groups = IsbnPattern.Match(element.Isbn).Groups;

                    int countDigit = 0;

                    for (int i = 1; i < groups.Count; i++)
                    {
                        countDigit += groups[i].Length;
                    }

                    if (countDigit != 10)
                    {
                        throw new ArgumentOutOfRangeException("Isbn should only be 10 digits!");
                    }
                }
                else
                {
                    throw new ArgumentException("Incorrect Isbn! Exmble \"ISBN 0 - 00 - 000000 - 0\"");
                }
            }
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

        private string ToUpperFirstSimbol(string str)
        {
            return str.Length > 1
                ? char.ToUpper(str.First()) + str.Substring(1).ToLower()
                : str.ToUpper();
        }

        private void ToUpperFirstSimbolsAndLowBy(int index, string[] str)
        {
            if (str.Length == 3)
            {
                for (int i = 0; i < str.Length; i++)
                {
                    if (i == index)
                    {
                        str[i] = str[i].ToLower();
                    }
                    else
                    {
                        str[i] = char.ToUpper(str[i].First()) + str[i].Substring(1).ToLower();
                    }
                }
            }
            else
            {
                throw new ArgumentOutOfRangeException("The argument does not match length 3!");
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

        private string ValidateAndCorrectPublishingCity(string publishingCity)
        {
            if (publishingCity is null)
            {
                throw new NullReferenceException("PublishingCity is null!");
            }
            else
            {
                if (PublishingCityPattern.IsMatch(publishingCity))
                {
                    string[] str = publishingCity.Split('-', ' ');

                    string newValue = "";

                    if (str.Length > 1)
                    {
                        int Count;

                        if ((Count = Regex.Matches(publishingCity, "-").Count) == 2)
                        {
                            ToUpperFirstSimbolsAndLowBy(1, str);

                            newValue = string.Join("-", str);
                        }
                        else if (Count == 1)
                        {
                            if (Regex.IsMatch(publishingCity, " "))
                            {
                                if (Regex.IsMatch(publishingCity, "^[A-Za-zА-ЯЁа-яё]+-[A-Za-zА-ЯЁа-яё]+ [A-Za-zА-ЯЁа-яё]+$"))
                                {
                                    str[0] = ToUpperFirstSimbol(str[0]);

                                    str[1] = ToUpperFirstSimbol(str[1]);

                                    if (str[2].Length > 1)
                                    {
                                        str[2] = str[2].First() + str[2].Substring(1).ToLower();
                                    }

                                    newValue = str[0] + "-" + str[1] + " " + str[2];
                                }
                                else
                                {
                                    str[0] = ToUpperFirstSimbol(str[0]);

                                    if (str[1].Length > 1)
                                    {
                                        str[1] = str[1].First() + str[1].Substring(1).ToLower();
                                    }

                                    str[2] = ToUpperFirstSimbol(str[2]);

                                    newValue = str[0] + " " + str[1] + "-" + str[2];
                                }
                            }
                        }
                        else if (Regex.Matches(publishingCity, " ").Count == 2)
                        {
                            str[0] = ToUpperFirstSimbol(str[0]);

                            if (str[1].Length > 1)
                            {
                                str[1] = str[1].First() + str[1].Substring(1).ToLower();
                            }

                            if (str[2].Length > 1)
                            {
                                str[2] = str[2].First() + str[2].Substring(1).ToLower();
                            }

                            newValue = string.Join("-", str);
                        }
                    }
                    else
                    {
                        ToUpperFirstSimbols(str);

                        newValue = str.First();
                    }

                    return newValue.Length > 200
                        ? newValue.Substring(0, 200)
                        : newValue;
                }
                else
                {
                    throw new ArgumentException("Icorrect PublishingCity!");
                }
            }
        }
    }
}

using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Patent;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Logic
{
    public class PatentBll : IPatentBll
    {
        protected readonly IPatentBll _patentDao;

        protected readonly Regex FirstNamePattern = new Regex("^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$", RegexOptions.Singleline);
        protected readonly Regex LastNamePattern = new Regex("^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        protected readonly Regex CountryPattern = new Regex("^[A-Za-z]+$|^[А-ЯЁа-яё]$", RegexOptions.Singleline);
        protected readonly Regex RegistrationNumberPattern = new Regex("^[0-9]{9}$",RegexOptions.Singleline);

        public PatentBll(IPatentBll patentDao)
        {
            _patentDao = patentDao;
        }

        public void AddPatent(AbstractPatent patent)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException(nameof(patent) + " is null!");
                }

                if (patent.Name is null)
                {
                    throw new NullReferenceException("Name is null!");
                }
                else if (patent.Name.Length > 300)
                {
                    patent.Name = patent.Name.Substring(0, 300);
                }

                if (patent.NumberOfPages < 0)
                {
                    throw new ArgumentException("The number of pages cannot be negative!");
                }

                if (patent.Annotation != null && patent.Annotation.Length > 2000)
                {
                    patent.Annotation = patent.Annotation.Substring(0, 2000);
                }

                ValidateAndCorrectAutors(patent.Authors);

                if (patent.Country is null)
                {
                    throw new NullReferenceException("Name is null!");
                }
                else
                {
                    if (CountryPattern.IsMatch(patent.Country))
                    {
                        if (patent.Country.Length > 3 || patent.Country.ToLower().Equals("чад"))
                        {
                            patent.Country = ToUpperFirstSimbol(patent.Country);
                        }
                        else
                        {
                            patent.Country = patent.Country.ToUpper();
                        }
                    }
                    else
                    {
                        throw new ArgumentException("Incorrect Country!");
                    }
                }

                if (patent.RegistrationNumber is null)
                {
                    throw new ArgumentNullException("Registration number is null!");
                }
                else
                {
                    if (!RegistrationNumberPattern.IsMatch(patent.RegistrationNumber))
                    {
                        throw new ArgumentException("Incorrect RegistrationNumber! It should only be 9 digits");
                    }
                }

                if (patent.ApplicationDate != null)
                {
                    if (patent.ApplicationDate.Value.Year < 1474 && patent.ApplicationDate.Value > DateTime.Now)
                    {
                        throw new ArgumentException("Incorrect ApplicationDate! It shouldn't be less than 1474 and more than today.");
                    }
                }

                if ( patent.DateOfPublication <= DateTime.Now &&
                    (patent.ApplicationDate != null && patent.DateOfPublication >= patent.ApplicationDate ||
                     patent.DateOfPublication.Year >= 1474) )
                {
                    throw new ArgumentException("Incorrect Date of publication!");
                }

                _patentDao.AddPatent(patent);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
            }
        }

        public void RemovePatent(AbstractPatent patent)
        {
            try
            {
                if (patent is null)
                {
                    throw new ArgumentNullException("Patent is null!");
                }

                _patentDao.RemovePatent(patent);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing element!", ex);
            }
        }

        public IEnumerable<AbstractPatent> SearchPatents(SortOptions options, PatentSearchOptions searchOptions, string search)
        {
            foreach (var item in _patentDao.SearchPatents(options, searchOptions, search))
            {
                yield return item;
            }
        }

        public IEnumerable<IGrouping<int, AbstractPatent>> GetAllPatentGroupsByPublishYear()
        {
            foreach (var item in _patentDao.GetAllPatentGroupsByPublishYear())
            {
                yield return item;
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

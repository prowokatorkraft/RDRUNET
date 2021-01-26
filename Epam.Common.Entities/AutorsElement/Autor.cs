using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement
{
    public class Autor
    {
        protected const string FirstNameFilter = "^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$";
        
        private string _firstName;
       
        public string FirstName
        {
            get => _firstName;

            protected set
            {
                if (value != null && Regex.IsMatch(value, FirstNameFilter))
                {
                    string[] str = value.Split('-');

                    ToUpperFirstSimbol(str);
                    
                    string newValue = string.Join("-", str);

                    _firstName = newValue.Substring(0, newValue.Length >= 50 ? 50 : newValue.Length);
                }
                else
                {
                    throw new ArgumentException("Icorrect FirstName!");
                }
            }
        }

        protected const string LastNameFilter = "^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$";
       
        private string _lastName;
        
        public string LastName
        {
            get => _lastName;

            protected set
            {
                if (value != null && Regex.IsMatch(value, LastNameFilter))
                {
                    string[] str = value.Split('-', ' ');
                    
                    string newValue = "";

                    if (str.Length > 1)
                    {
                        if (Regex.IsMatch(value, "-"))
                        {
                            ToUpperFirstSimbol(str);

                            newValue = string.Join("-", str);
                        }
                        else if (Regex.IsMatch(value, "'"))
                        {
                            ToUpperFirstSimbol(str);

                            newValue = string.Join("'", str);
                        }
                        else if (Regex.IsMatch(value, " "))
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

                    _lastName = newValue.Substring(0, newValue.Length >= 200 ? 200 : newValue.Length);
                }
                else
                {
                    throw new ArgumentException("Icorrect LastName!");
                }
            }
        }

        public Autor(string firstName, string lastName)
        {
            FirstName = firstName;
            LastName = lastName;
        }

        private void ToUpperFirstSimbol(params string[] str)
        {
            for (int i = 0; i < str.Length; i++)
            {
                if (str[i].Length > 1)
                {
                    str[i] = char.ToUpper(str[i].First()) + str[i].Substring(1).ToLower();
                }
                else
                {
                    str[i] = str[i].ToUpper();
                }
            }
        }
    }
}

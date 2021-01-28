﻿using System;

namespace Epam.Common.Entities.Newspaper
{
    public abstract class AbstractNewspaper : AbstractElement
    {
        public abstract string PublishingHouse { get; set; }
        //{
        //    get => _publishingHouse;

        //    protected set
        //    {
        //        _publishingHouse = value.Length > 300
        //            ? value.Substring(0, 300)
        //            : value;
        //    }
        //}

        //protected const string PublishingCityFilter = "^[A-Za-z]+(-| ?)[A-Za-z]+(-| ?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+$";
        //private string _publishingCity;

        public abstract string PublishingCity { get; set; }
        //{
        //    get => _publishingCity;

        //    protected set
        //    {
        //        if (value != null && Regex.IsMatch(value, PublishingCityFilter))
        //        {
        //            string[] str = value.Split('-', ' ');

        //            string newValue = "";

        //            if (str.Length > 1)
        //            {
        //                int Count;

        //                if ((Count = Regex.Matches(value, "-").Count) == 2)
        //                {
        //                    ToUpperLowUpperFirstSimbols(str);

        //                    newValue = string.Join("-", str);
        //                }
        //                else if (Count == 1)
        //                {
        //                    if (Regex.IsMatch(value, " "))
        //                    {
        //                        if (Regex.IsMatch(value, "^[A-Za-zА-ЯЁа-яё]+-[A-Za-zА-ЯЁа-яё]+ [A-Za-zА-ЯЁа-яё]+$"))
        //                        {
        //                            ////
        //                        }
        //                        else
        //                        {
        //                            ////
        //                        }
        //                    }
        //                }
        //                else if (Regex.Matches(value, " ").Count == 2)
        //                {
        //                    ////
        //                }
        //            }
        //            else
        //            {
        //                ToUpperFirstSimbol(str);

        //                newValue = str.First();
        //            }

        //            _publishingCity = newValue.Length > 200
        //                ? newValue.Substring(0, 200)
        //                : newValue;
        //        }
        //        else
        //        {
        //            throw new ArgumentException("Icorrect FirstName!");
        //        }
        //    }
        //}

        public abstract int PublishingYear { get; set; }

        public abstract string Issn { get; set; }

        public abstract string Number { get; set; }

        public abstract DateTime Date { get; set; }

        protected AbstractNewspaper(string name, int numberOfPages, string publishingHouse, string publishingCity, int publishingYear, DateTime date)
            : base(name, numberOfPages)
        {
            PublishingHouse = publishingHouse;
            PublishingCity = publishingCity;
            PublishingYear = publishingYear;
            Date = date;
        }

        //private void ToUpperFirstSimbol(params string[] str)
        //{
        //    for (int i = 0; i < str.Length; i++)
        //    {
        //        if (str[i].Length > 1)
        //        {
        //            str[i] = char.ToUpper(str[i].First()) + str[i].Substring(1).ToLower();
        //        }
        //        else
        //        {
        //            str[i] = str[i].ToUpper();
        //        }
        //    }
        //}

        //private void ToUpperLowUpperFirstSimbols(string[] str)
        //{
        //    if (str.Length == 3)
        //    {
        //        for (int i = 0; i < str.Length; i++)
        //        {
        //            if (i == 1)
        //            {
        //                str[i] = str[i].ToLower();
        //            }
        //            else
        //            {
        //                str[i] = char.ToUpper(str[i].First()) + str[i].Substring(1).ToLower();
        //            }
        //        }
        //    }
        //    else
        //    {
        //        throw new ArgumentOutOfRangeException("The argument does not match length 3!");
        //    }
        //}
    }
}

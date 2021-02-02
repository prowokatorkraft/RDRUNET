using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AutorsElement;
using Epam.Library.Common.Entities.AutorsElement.Book;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Epam.Library.Bll.Logic
{
    public class BookBll : IBookBll
    {
        protected readonly IBookDao _bookDao;

        protected readonly Regex FirstNamePattern = new Regex("^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$", RegexOptions.Singleline);
        protected readonly Regex LastNamePattern = new Regex("^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        protected readonly Regex PublishingCityPattern = new Regex("^[A-Za-z]+(-| ?)[A-Za-z]+(-| ?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+$", RegexOptions.Singleline);
        protected readonly Regex IsbnPattern = new Regex("^ISBN ([0-9]{1,5})-([0-9]{1,7})-([0-9]{1,7})-([0-9Xx])$", RegexOptions.Singleline);

        public BookBll(IBookDao bookDao)
        {
            _bookDao = bookDao;
        }

        public void AddBook(AbstractBook book)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException((nameof(book) + " is null!"));
                }

                if (book.Name is null)
                {
                    throw new NullReferenceException("Name is null!");
                }
                else if (book.Name.Length > 300)
                {
                    book.Name = book.Name.Substring(0, 300);
                }

                if (book.NumberOfPages < 0)
                {
                    throw new ArgumentException("The number of pages cannot be negative!");
                }

                if (book.Annotation != null && book.Annotation.Length > 2000)
                {
                    book.Annotation = book.Annotation.Substring(0, 2000);
                }

                ValidateAndCorrectAutors(book.Authors);

                if (book.Publisher is null)
                {
                    throw new NullReferenceException("Publisher is null!");
                }
                else if (book.Publisher.Length > 300)
                {
                    book.Publisher = book.Publisher.Substring(0, 300);
                }

                book.PublishingCity = ValidateAndCorrectPublishingCity(book.PublishingCity);

                if (book.PublishingYear < 1400 || book.PublishingYear > DateTime.Now.Year)
                {
                    throw new ArgumentOutOfRangeException("Incorrect PublishingYear!");
                }

                if (book.Isbn != null)
                {
                    if (IsbnPattern.IsMatch(book.Isbn))
                    {
                        var groups = IsbnPattern.Match(book.Isbn).Groups;

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

                _bookDao.AddBook(book);
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding item!", ex);
            }
        }

        public void RemoveBook(AbstractBook book)
        {
            try
            {
                if (book is null)
                {
                    throw new ArgumentNullException("Book is null!");
                }

                _bookDao.RemoveBook(book);
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing element!", ex);
            }
        }

        public IEnumerable<AbstractBook> SearchBooks(SortOptions options, BookSearchOptions searchOptions, string search)
        {
            foreach (var item in _bookDao.SearchBooks(options, searchOptions, search))
            {
                yield return item;
            }
        }

        public IEnumerable<IGrouping<int, AbstractBook>> GetAllBookGroupsByPublishYear()
        {
            foreach (var item in _bookDao.GetAllBookGroupsByPublishYear())
            {
                yield return item;
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

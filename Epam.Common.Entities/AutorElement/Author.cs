﻿namespace Epam.Library.Common.Entities.AuthorElement
{
    public class Author
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public Author() 
        {
        
        }

        public Author(string firstName, string lastName)
        {
            FirstName = firstName;
            LastName = lastName;
        }

        public override string ToString()
        {
            return FirstName + " " + LastName;
        }
    }
}

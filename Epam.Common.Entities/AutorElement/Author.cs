using System;

namespace Epam.Library.Common.Entities.AuthorElement
{
    public class Author : ICloneable
    {
        public int? Id { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public Author() 
        {
        
        }

        public Author(int? id, string firstName, string lastName)
        {
            Id = id;
            FirstName = firstName;
            LastName = lastName;
        }

        public override string ToString()
        {
            return FirstName + " " + LastName;
        }

        public object Clone()
        {
            return new Author(Id, FirstName, LastName);
        }
    }
}

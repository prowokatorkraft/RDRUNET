using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.AuthorElement
{
    public class Author : ICloneable
    {
        public int? Id { get; set; }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public bool Deleted { get; set; }

        public Author() 
        {
        
        }

        public Author(int? id, string firstName, string lastName, bool deleted = false)
        {
            Id = id;
            FirstName = firstName;
            LastName = lastName;
            Deleted = deleted;
        }

        public override string ToString()
        {
            return FirstName + " " + LastName;
        }

        public object Clone()
        {
            return new Author(Id, FirstName, LastName, Deleted);
        }

        public override bool Equals(object obj)
        {
            return obj is Author author &&
                   FirstName == author.FirstName &&
                   LastName == author.LastName;
        }

        public override int GetHashCode()
        {
            int hashCode = 1938039292;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(FirstName);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(LastName);
            return hashCode;
        }
    }
}

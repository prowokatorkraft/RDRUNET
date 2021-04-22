using System;
using System.Collections.Generic;

namespace Epam.Library.Common.Entities.Newspaper
{
    public class Newspaper : ICloneable
    {
        public int? Id { get; set; }
        public string Name { get; set; }
        public string Issn { get; set; }
        public bool Deleted { get; set; }

        public Newspaper()
        {

        }
        public Newspaper(int? id, string name, string issn, bool deleted)
        {
            Id = id;
            Name = name;
            Issn = issn;
            Deleted = deleted;
        }

        public object Clone()
        {
            return new Newspaper(Id, Name, Issn, Deleted);
        }

        public override bool Equals(object obj)
        {
            return obj is Newspaper newspaper &&
                   Name == newspaper.Name &&
                   Issn == newspaper.Issn;
        }
        public override int GetHashCode()
        {
            int hashCode = 1453574602;
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Issn);
            return hashCode;
        }
    }
}

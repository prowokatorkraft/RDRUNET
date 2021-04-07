using System.Collections.Generic;

namespace Epam.Common.Entities
{
    public class Role
    {
        public int? Id { get; set; }

        public string Name { get; set; }

        public override bool Equals(object obj)
        {
            return obj is Role role &&
                   Id == role.Id &&
                   Name == role.Name;
        }

        public override int GetHashCode()
        {
            int hashCode = -1919740922;
            hashCode = hashCode * -1521134295 + Id.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Name);
            return hashCode;
        }
    }
}

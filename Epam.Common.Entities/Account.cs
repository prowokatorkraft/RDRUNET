using System.Collections.Generic;

namespace Epam.Library.Common.Entities
{
    public class Account
    {
        public long? Id { get; set; }

        public string Login { get; set; }

        public string Password { get; set; }

        public string PasswordHash { get; set; }

        public int RoleId { get; set; }

        public override bool Equals(object obj)
        {
            return obj is Account account &&
                   Id == account.Id &&
                   Login == account.Login &&
                   PasswordHash == account.PasswordHash &&
                   RoleId == account.RoleId;
        }
        public override int GetHashCode()
        {
            int hashCode = -381869738;
            hashCode = hashCode * -1521134295 + Id.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Login);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(PasswordHash);
            hashCode = hashCode * -1521134295 + RoleId.GetHashCode();
            return hashCode;
        }
    }
}

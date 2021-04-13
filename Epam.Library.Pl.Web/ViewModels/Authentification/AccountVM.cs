using Epam.Library.Common.Entities;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class AccountVM
    {
        public long? Id { get; set; }

        public string Login { get; set; }

        public Role Role { get; set; }
    }
}
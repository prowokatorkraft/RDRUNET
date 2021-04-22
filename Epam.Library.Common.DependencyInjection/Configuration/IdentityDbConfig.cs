using System.Configuration;

namespace Epam.Library.Common.DependencyInjection.Configuration
{
    public class IdentityDbConfig : ConfigurationSection
    {
        [ConfigurationProperty("accounts")]
        public AccountCollection Accounts => (AccountCollection)base["accounts"];

        [ConfigurationCollection(typeof(AccountDb), AddItemName = "account")]
        public class AccountCollection : ConfigurationElementCollection
        {
            public AccountDb this[object index] => (AccountDb)BaseGet(index);

            protected override ConfigurationElement CreateNewElement()
            {
                return new AccountDb();
            }

            protected override object GetElementKey(ConfigurationElement element)
            {
                return ((AccountDb)element).Name;
            }

            public class AccountDb : ConfigurationElement
            {
                [ConfigurationProperty("Name", IsRequired = true)]
                public string Name => (string)this["Name"];

                [ConfigurationProperty("UserID", IsRequired = true)]
                public string UserID => (string)this["UserID"];

                [ConfigurationProperty("Password", IsRequired = true)]
                public string Password => (string)this["Password"];
            }
        }
    }
}

using System;

namespace Epam.Library.Bll.Validation
{
    public static class ValidationPatterns 
    {
        public const string FirstNamePattern = "^[A-Z][a-z]{0,}(-[A-Z][a-z]{0,})?$|^[А-ЯЁ][а-яё]{0,}(-[А-ЯЁ][а-яё]{0,})?$";

        public const string LastNamePattern = "^([a-z]+ )?[A-Z][a-z]{0,}((-|')[A-Z][a-z]{0,})?$|^([а-яё]+ )?[А-ЯЁ][а-яё]{0,}((-|')[А-ЯЁ][а-яё]{0,})?$";

        // TODO:
        public const string PublishingCityPattern = "^[A-Za-z]+(-| ?)[A-Za-z]+(-| ?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+$";

        public const string IsbnPattern = "^ISBN ([0-9]{1,5})-([0-9]{1,7})-([0-9]{1,7})-([0-9Xx])$";

        public const string IssnPattern = "^ISSN [0-9]{4}-[0-9]{4}$";

        public const string CountryPattern = "^[A-Za-z]+$|^[А-ЯЁа-яё]$";

        public const string RegistrationNumberPattern = "^[0-9]{9}$";
    }
}

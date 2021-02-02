using System;

namespace Epam.Library.Bll.Validation
{
    public static class ValidationPatterns
    {
        public const string FirstNamePattern = "^[A-Za-z]+-?[A-Za-z]+$|^[А-Яа-я]+-?[А-Яа-я]+$";

        public const string LastNamePattern = "^[A-Za-z]+(-| |'?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| |'?)[А-ЯЁа-яё]+$";

        public const string PublishingCityPattern = "^[A-Za-z]+(-| ?)[A-Za-z]+(-| ?)[A-Za-z]+$|^[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+(-| ?)[А-ЯЁа-яё]+$";

        public const string IsbnPattern = "^ISBN ([0-9]{1,5})-([0-9]{1,7})-([0-9]{1,7})-([0-9Xx])$";

        public const string IssnPattern = "^ISSN [0-9]{4}-[0-9]{4}$";

        public const string CountryPattern = "^[A-Za-z]+$|^[А-ЯЁа-яё]$";

        public const string RegistrationNumberPattern = "^[0-9]{9}$";

    }
}

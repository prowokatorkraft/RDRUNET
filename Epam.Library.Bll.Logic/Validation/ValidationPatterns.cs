namespace Epam.Library.Bll.Validation
{
    public static class ValidationPatterns 
    {
        public const string FirstNamePattern = "^[A-Z][a-z]{0,}(-[A-Z][a-z]{0,})?$|^[А-ЯЁ][а-яё]{0,}(-[А-ЯЁ][а-яё]{0,})?$";

        public const string LastNamePattern = "^([a-z]+ )?[A-Z][a-z]{0,}((-|')[A-Z][a-z]{0,})?$|^([а-яё]+ )?[А-ЯЁ][а-яё]{0,}((-|')[А-ЯЁ][а-яё]{0,})?$";

        public const string PublishingCityPattern = "^[A-Z][a-z]+((-[a-z]{1,})?((-[A-Z])|( [A-Za-z]))[a-z]{0,})?$|^[А-ЯЁ][а-яё]+((-[а-яё]{1,})?((-[А-ЯЁ])|( [А-ЯЁа-яё]))[а-яё]{0,})?$";

        public const string IsbnPattern = "^ISBN ([0-9]{1,5})-([0-9]{1,7})-([0-9]{1,7})-([0-9Xx])$";

        public const string IssnPattern = "^ISSN [0-9]{4}-[0-9]{4}$";

        public const string CountryPattern = "^([A-Z]{2,3}|[A-Z][a-z]{1,})$|^([А-ЯЁ]{2,3}|[А-ЯЁ][а-я]{1,})$";

        public const string RegistrationNumberPattern = "^[0-9]{1,9}$";

        public const string LoginPattern = "^[A-Za-z]([_]?[A-Za-z0-9]+){0,}[_]?[A-Za-z0-9]$";
    }
}

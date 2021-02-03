namespace Epam.Library.Common.Entities
{
    public class ErrorValidation
    {
        public string Field { get; set; }

        public string Description { get; set; }

        public string Recommendation { get; set; }

        public ErrorValidation()
        {
        }

        public ErrorValidation(string field, string description, string recommendation)
        {
            Field = field;
            Description = description;
            Recommendation = recommendation;
        }
    }
}

namespace Epam.Common.Entities
{
    public abstract class AbstractElement
    {
        public abstract string Name { get; set; }
        //{
        //    get => Name;

        //    private set
        //    {
        //        Name = value.Length > 300
        //            ? value.Substring(0, 300)
        //            : value;
        //    }
        //}

        public abstract int NumberOfPages { get; set; }
        //{
        //    get => NumberOfPages;

        //    private set
        //    {
        //        NumberOfPages = value < 0
        //            ? throw new ArgumentException("The number of pages cannot be negative!")
        //            : value;
        //    }
        //}

        public abstract string Annotation { get; set; }
        //{ 
        //    get => Annotation;

        //    private set
        //    {
        //        Annotation = value.Length > 2000
        //            ? value.Substring(0, 2000)
        //            : value;
        //    }
        //}

        protected AbstractElement(string name, int numberOfPages, string annotation) 
            : this(name, numberOfPages)
        {
            Annotation = annotation;
        }
        protected AbstractElement(string name, int numberOfPages)
        {
            Name = name;
            NumberOfPages = numberOfPages;
        }
    }
}

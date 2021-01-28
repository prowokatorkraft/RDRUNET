namespace Epam.Library.Common.Entities.AutorsElement
{
    public abstract class AbstractAutorsElement : AbstractElement 
    {
        public abstract Autor[] Autors { get; set; }

        protected AbstractAutorsElement(string name, int numberOfPages, Autor[] autors) : base(name, numberOfPages)
        {
            Autors = autors;
        }
        protected AbstractAutorsElement(string name, int numberOfPages) : base(name, numberOfPages)
        {
            
        }
    }
}

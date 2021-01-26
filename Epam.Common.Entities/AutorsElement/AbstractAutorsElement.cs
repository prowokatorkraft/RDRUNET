using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement
{
    public abstract class AbstractAutorsElement : AbstractElement 
    {
        public Autor Autor { get; private set; }

        public AbstractAutorsElement(string name, int numberOfPages, Autor autor) : base(name, numberOfPages)
        {
            Autor = autor;
        }
        public AbstractAutorsElement(string name, string annotation, int numberOfPages, Autor autor) : base(name, numberOfPages, annotation)
        {
            Autor = autor;
        }
    }
}

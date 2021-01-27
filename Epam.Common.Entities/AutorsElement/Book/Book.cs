using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement.Book
{
    public class Book : AbstractBook
    {
        public override string Name { get; set; }
        
        public override int NumberOfPages { get; set; }

        public override string Annotation { get; set; }

        public override Autor[] Autors { get; set; }

        public override BookPublishingHouse PublishingHouse { get; set; }

        public Book(string name, int numberOfPages, BookPublishingHouse publishingHouse)
            : base(name, numberOfPages, publishingHouse)
        {

        }
    }
}

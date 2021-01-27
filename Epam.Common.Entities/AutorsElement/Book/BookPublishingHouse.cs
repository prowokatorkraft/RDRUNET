using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.AutorsElement.Book
{
    public class BookPublishingHouse : PublishingHouse
    {
        public Isbn Isbn { get; set; }

        public BookPublishingHouse(string name, string publishingCity, int publishingYear, Isbn isbn) 
            : base(name, publishingCity, publishingYear)
        {
            Isbn = isbn;
        }
    }
}

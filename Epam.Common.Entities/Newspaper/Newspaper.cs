using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Epam.Common.Entities.Newspaper
{
    public class Newspaper : AbstractNewspaper
    {
        public override string Name { get; set; }
        public override int NumberOfPages { get; set; }
        public override string Annotation { get; set; }
        public override NewspaperPublishingHouse PublishingHouse { get; set; }

        public Newspaper(string name, int numberOfPages, NewspaperPublishingHouse publishingHouse)
            : base(name, numberOfPages, publishingHouse)
        {
            
        }
    }
}

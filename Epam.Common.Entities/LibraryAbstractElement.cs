using System;

namespace Epam.Library.Common.Entities
{
    public abstract class LibraryAbstractElement : ICloneable
    {
        public abstract int? Id { get; set; }

        public abstract string Name { get; set; }

        public abstract int NumberOfPages { get; set; }

        public abstract string Annotation { get; set; }

        public abstract bool Deleted { get; set; }

        public abstract object Clone();
    }
}

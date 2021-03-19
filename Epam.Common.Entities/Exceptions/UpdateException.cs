using System;

namespace Epam.Library.Common.Entities.Exceptions
{
    public class UpdateException : Exception
    {
        public UpdateException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
}

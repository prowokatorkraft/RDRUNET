using System;

namespace Epam.Library.Common.Entities.Exceptions
{
    public class RemoveException : Exception
    {
        public RemoveException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
}

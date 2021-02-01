using System;

namespace Epam.Common.Entities.Exceptions
{
    public class RemoveException : Exception
    {
        public RemoveException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
}

using System;

namespace Epam.Common.Entities.Exceptions
{
    public class AddException : Exception
    {
        public AddException(string message, Exception innerException) 
            : base(message, innerException)
        {

        }
    }
}

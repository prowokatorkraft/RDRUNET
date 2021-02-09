using System;

namespace Epam.Library.Common.Entities.Exceptions
{
    public class AddException : Exception
    {
        public AddException(string message, Exception innerException) 
            : base(message, innerException)
        {

        }
    }
}

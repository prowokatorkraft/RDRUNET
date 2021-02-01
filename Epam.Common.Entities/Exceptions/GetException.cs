using System;

namespace Epam.Library.Common.Entities.Exceptions
{
    public class GetException : Exception
    {
        public GetException(string message, Exception innerException)
            : base(message, innerException)
        {

        }
    }
}

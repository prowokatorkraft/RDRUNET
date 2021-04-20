using System;

namespace Epam.Library.Common.Entities
{
    public class LayerException : Exception
    {
        public string Layer { get; set; }
        public string Class { get; set; }
        public string Method { get; set; }

        public LayerException(string layer, string @class, string method, string message, Exception innerException)
            : base(message, innerException)
        {
            Layer = layer;
            Class = @class;
            Method = method;
        }
    }
}

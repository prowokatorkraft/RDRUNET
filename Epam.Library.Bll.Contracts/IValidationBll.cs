using Epam.Library.Common.Entities;
using System.Collections.Generic;

namespace Epam.Library.Bll.Contracts
{
    public interface IValidationBll<T>
    {
        IEnumerable<ErrorValidation> Validate(T element);
    }
}
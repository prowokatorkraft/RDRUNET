using Epam.Library.Common.Entities;

namespace Epam.Library.Bll.Contracts
{
    public interface IValidationBll<T>
    {
        ErrorValidation[] Validate(T element);
    }
}
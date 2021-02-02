using Epam.Library.Common.Entities;

namespace Epam.Library.Bll.Contracts
{
    public interface IValidation<T> where T: LibraryAbstractElement
    {
        void ValidateElement(T element);
    }
}
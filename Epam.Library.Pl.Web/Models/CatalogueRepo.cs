using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels;
using System.Collections.Generic;

namespace Epam.Library.Pl.Web.Models
{
    public class CatalogueRepo
    {
        ICatalogueBll _catalogueBll;
        Mapper _mapper;

        public CatalogueRepo(ICatalogueBll catalogueBll, Mapper mapper)
        {
            _catalogueBll = catalogueBll;
            _mapper = mapper;
        }

        public IEnumerable<ElementVM> GetAll(int PageNumber)
        {
            foreach (var item in _catalogueBll.Search(null))
            {
                switch (item)
                {
                    case Book o:
                        yield return _mapper.Map<ElementVM, Book>(o);
                        break;
                    case Patent o:
                        yield return _mapper.Map<ElementVM, Patent>(o);
                        break;
                    //case Newspaper o:
                    //    yield return MapperConfig.Map<ElementViewModel, Newspaper>(o);
                    //    break;
                    default:
                        break;
                }
            }
        }
    }
}
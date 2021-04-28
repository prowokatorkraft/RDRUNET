using System.Collections.Generic;

namespace Epam.Library.Pl.WebApi.Models
{
    public class PageDataVM<TModel>
    {
        public PageInfoVM PageInfo { get; set; }
        public List<TModel> Elements { get; set; }
    }
}
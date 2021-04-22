using System.Collections.Generic;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class PageDataVM<TModel>
    {
        public PageInfoVM PageInfo { get; set; }
        public List<TModel> Elements { get; set; }
    }
}
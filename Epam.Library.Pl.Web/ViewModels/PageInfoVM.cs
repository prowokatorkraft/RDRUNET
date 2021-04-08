using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class PageInfoVM
    {
        public int CurrentPage { get; set; } = 1;
        public int CountPage { get; set; }
        public int SizePage { get; set; } = 20;
        public string Action { get; set; }
        public string Controller { get; set; }
        public RouteValueDictionary Values { get; set; }
    }
}
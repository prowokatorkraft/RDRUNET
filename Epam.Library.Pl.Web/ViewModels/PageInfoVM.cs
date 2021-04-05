using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Epam.Library.Pl.Web.ViewModels
{
    public class PageInfoVM
    {
        public int CurrentPage { get; set; } = 1;
        public int CountPage { get; set; }
        public int SizePage { get; set; } = 20;
        public string ActionUrl { get; set; }
    }
}
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web.Controllers
{
    public class PatentController : Controller
    {
        IPatentBll _patentBll;
        Mapper _mapper;

        public PatentController(IPatentBll patentBll, Mapper mapper)
        {
            _patentBll = patentBll;
            _mapper = mapper;
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(CreateEditPatentVM patent)
        {
            if (ModelState.IsValid)
            {
                var errors = _patentBll.Add(_mapper.Map<Patent, CreateEditPatentVM>(patent));

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(patent);
        }

        [HttpGet]
        public ActionResult Edit(int id)
        {
            var patent = _mapper.Map<CreateEditPatentVM, Patent>(_patentBll.Get(id) as Patent);

            return View(patent);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(CreateEditPatentVM patent)
        {
            if (ModelState.IsValid)
            {
                var errors = _patentBll.Update(_mapper.Map<Patent, CreateEditPatentVM>(patent));

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }

            return View(patent);
        }

        [HttpGet]
        public ActionResult Display(int id)
        {
            var patent = _mapper.Map<DisplayPatentVM, Patent>(_patentBll.Get(id) as Patent);

            return View(patent);
        }

        [HttpGet]
        public ActionResult Remove(int id)
        {
            var patent = _mapper.Map<ElementVM, Patent>(_patentBll.Get(id) as Patent);

            return View(patent);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            if (_patentBll.Remove(id))
            {
                return Redirect("~/");
            }

            return RedirectToAction("Remove", new { id = id });
        }
    }
}
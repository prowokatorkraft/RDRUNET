using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace Epam.Library.Pl.Web.Controllers
{
    public class AccountController : Controller
    {
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Login(LoginVM model)
        {
            return View();
        }

        public ActionResult Logon()
        {
            return View();/////
        }

        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Register(CreateAccountVM model)
        {
            return View();
        }

        public JsonResult IsLoginAllowed(string login) ///
        {
            bool isNotExits = true;

            //if (!this._accountLogic.IsExists(login))
            //{
            //    isNotExits = false;
            //}

            return Json(isNotExits, JsonRequestBehavior.AllowGet);
        }

        private string GetPasswordHash(string password)
        {
            string result;

            using (SHA512 sha512 = new SHA512Managed())
            {
                byte[] data = Encoding.UTF8.GetBytes(password);
                data = sha512.ComputeHash(data);

                result = Encoding.UTF8.GetString(data);
            }
            
            return result;
        }
    }
}
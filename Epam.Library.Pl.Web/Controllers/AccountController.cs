using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using Epam.Library.Pl.Web.ViewModels;
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
        private readonly IAccountBll _accountBll;
        private readonly Mapper _mapper;

        public AccountController(IAccountBll accountBll, Mapper mapper)
        {
            _accountBll = accountBll;
            _mapper = mapper;
        }

        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginVM model)
        {
            var acc = _accountBll.GetByLogin(model.Login);

            if (acc?.PasswordHash == GetPasswordHash(model.Password))
            {
                FormsAuthentication.SetAuthCookie(model.Login, true);
                return Redirect("~/");
            }
            else
            {
                ModelState.AddModelError("", "Incorrect Login or Password.");
            }

            return View(model);
        }

        public ActionResult Logout()
        {
            FormsAuthentication.SignOut();

            return Redirect("~/");
        }

        public ActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(CreateAccountVM model)
        {
            if (ModelState.IsValid)
            {
                var errors = _accountBll.Add(_mapper.Map<Account, CreateAccountVM>(model));

                if (!errors.Any())
                {
                    return Redirect("~/");
                }

                foreach (var item in errors)
                {
                    ModelState.AddModelError(item.Field, $"{item.Description} {item.Recommendation}");
                }
            }
            return View(model);
        }

        public JsonResult IsLoginAllowed(string login)
        {
            return Json(!_accountBll.Check(login), JsonRequestBehavior.AllowGet);
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
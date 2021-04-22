using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Pl.Web.Filters;
using Epam.Library.Pl.Web.ViewModels;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web.Mvc;
using System.Web.Security;

namespace Epam.Library.Pl.Web.Controllers
{
    [AllowAnonymous]
    public class AccountController : Controller
    {
        private IAccountBll _accountBll;
        private IRoleBll _roleBll;
        private Mapper _mapper;

        public AccountController(IAccountBll accountBll, IRoleBll roleBll, Mapper mapper)
        {
            _accountBll = accountBll;
            _roleBll = roleBll;
            _mapper = mapper;
        }

        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        [LoginLog]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginVM model)
        {
            var acc = _accountBll.GetByLogin(model.Login);

            if (acc?.PasswordHash == GetPasswordHash(model.Password))
            {
                TempData["UserName"] = model.Login;
                TempData["IsAuth"] = true;

                FormsAuthentication.SetAuthCookie(model.Login, true);
                return Redirect("~/");
            }
            else
            {
                ModelState.AddModelError("", "Incorrect Login or Password.");
            }

            return View(model);
        }

        [LogoutLog]
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
        [RegisterLog]
        [ValidateAntiForgeryToken]
        public ActionResult Register(CreateAccountVM model)
        {
            if (ModelState.IsValid)
            {
                var role = GetRoleByCurrentUser();
                var errors = _accountBll.Add(_mapper.Map<Account, CreateAccountVM>(model, role));

                if (!errors.Any())
                {
                    TempData["UserName"] = model.Login;
                    TempData["IsAuth"] = true;

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

        private RoleType GetRoleByCurrentUser()
        {
            string roleName = null;
            if (User.Identity.IsAuthenticated)
            {
                roleName = _roleBll.GetById(_accountBll.GetByLogin(User.Identity.Name).RoleId).Name;
            }

            return GetRole(roleName);
        }
        private RoleType GetRole(string roleName)
        {
            switch (roleName)
            {
                case "admin":
                    return RoleType.admin;
                case "librarian":
                    return RoleType.librarian;
                case "user":
                    return RoleType.user;
                default:
                    return RoleType.None;
            }
        }
    }
}
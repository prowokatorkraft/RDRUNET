using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;

namespace Epam.Library.Pl.Web.Models
{
    public class RoleProviderModel : RoleProvider
    {
        private static IAccountBll _accountBll;
        private static IRoleBll _roleBll;

        public RoleProviderModel()
        {

        }
        public RoleProviderModel(IAccountBll accountBll, IRoleBll roleBll)
        {
            _accountBll = accountBll;
            _roleBll = roleBll;
        }

        public override string[] GetRolesForUser(string username)
        {
            var acc = _accountBll.GetByLogin(username);
            var role = acc is null
                        ? null
                        : _roleBll.GetById(acc.RoleId);
            
            switch (role?.Name)
            {
                case "user":
                    return new[] { RoleType.user.ToString() };
                case "librarian":
                    return new[] { RoleType.user.ToString(), RoleType.librarian.ToString() };
                case "admin":
                    return new[] { RoleType.user.ToString(), RoleType.librarian.ToString(), RoleType.admin.ToString() };
            }

            return new[] { "" };
        }

        public override bool IsUserInRole(string username, string roleName)
        {
            var acc = _accountBll.GetByLogin(username);
            var role = acc is null
                        ? null
                        : _roleBll.GetById(acc.RoleId);

            return string.Equals(role?.Name, roleName, StringComparison.InvariantCultureIgnoreCase);
        }

        #region Not implemented
        public override string ApplicationName { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override void CreateRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new NotImplementedException();
        }

        public override string[] FindUsersInRole(string roleName, string usernameToMatch)
        {
            throw new NotImplementedException();
        }

        public override string[] GetAllRoles()
        {
            throw new NotImplementedException();
        }

        public override string[] GetUsersInRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override bool RoleExists(string roleName)
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}
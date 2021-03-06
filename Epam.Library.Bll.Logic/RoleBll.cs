using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;

namespace Epam.Library.Bll
{
    public class RoleBll : IRoleBll
    {
        private IRoleDao _dao;

        public RoleBll(IRoleDao dao)
        {
            _dao = dao;
        }

        public bool Check(int id)
        {
            try
            {
                return _dao.GetById(id) != null;
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(RoleBll), nameof(Check), "Error getting item.", ex);
            }
        }

        public IEnumerable<Role> GetAll()
        {
            try
            {
                return _dao.GetAll();
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(RoleBll), nameof(GetAll), "Error getting item.", ex);
            }
        }

        public Role GetById(int id)
        {
            try
            {
                return _dao.GetById(id);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(RoleBll), nameof(GetById), "Error getting item.", ex);
            }
        }

        public Role GetByName(string name)
        {
            try
            {
                return _dao.GetByName(name);
            }
            catch (Exception ex)
            {
                throw new LayerException("Bll", nameof(RoleBll), nameof(GetByName), "Error getting item.", ex);
            }
        }
    }
}

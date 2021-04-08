using Epam.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Epam.Library.Dal.Database
{
    public class RoleDao : IRoleDao
    {
        private readonly string _connectionString;

        public RoleDao(string connectionString)
        {
            _connectionString = connectionString;
        }

        public IEnumerable<Role> GetAll()
        {
            try
            {
                List<Role> roleList = new List<Role>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Roles_GetAll", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        roleList.Add(GetAuthorByReader(reader));
                    }
                }

                return roleList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Role GetById(int id)
        {
            try
            {
                Role role;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Roles_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    role = reader.Read()
                             ? GetAuthorByReader(reader)
                             : null;
                }

                return role;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Role GetByName(string name)
        {
            try
            {
                Role role;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Roles_GetByName", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Name", name);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    role = reader.Read()
                             ? GetAuthorByReader(reader)
                             : null;
                }

                return role;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private Role GetAuthorByReader(SqlDataReader reader)
        {
            return new Role()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
            };
        }
    }
}

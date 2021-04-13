using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Epam.Library.Dal.Database
{
    public class AccountDao : IAccountDao
    {
        private readonly string _connectionString;

        public AccountDao(ConnectionStringDb connectionStrings)
        {
            _connectionString = connectionStrings.GetByRole(RoleType.admin);
        }

        public void Add(Account account)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Users_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    AddParametersForAdd(account, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public bool Check(long id)
        {
            return GetById(id) != null;
        }

        public bool Check(string login)
        {
            return GetByLogin(login) != null;
        }

        public IEnumerable<Account> Search(SearchRequest<SortOptions, AccountSearchOptions> searchRequest)
        {
            try
            {
                List<Account> accountList = new List<Account>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    string storedProcedure = GetProcedureForSearch(searchRequest);

                    SqlCommand command = new SqlCommand(storedProcedure, connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForSearch(searchRequest, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        accountList.Add(GetAuthorByReader(reader));
                    }
                }

                return accountList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public int GetCount(AccountSearchOptions searchOptions = AccountSearchOptions.None, string searchLine = null)
        {
            try
            {
                int count;

                string storedProcedure = GetProcedureForCount(searchOptions);
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand(storedProcedure, connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForCount(searchOptions, searchLine, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    reader.Read();
                    count = (int)reader["Count"];
                }

                return count;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Account GetById(long id)
        {
            try
            {
                Account account;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Users_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    account = reader.Read()
                             ? GetAuthorByReader(reader)
                             : null;
                }

                return account;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Account GetByLogin(string login)
        {
            try
            {
                Account account;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Users_GetByLogin", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Login", login);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    account = reader.Read()
                             ? GetAuthorByReader(reader)
                             : null;
                }

                return account;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool Remove(long id)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Users_Remove", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    command.ExecuteNonQuery();

                    return true;
                }
            }
            catch (Exception ex)
            {
                throw new RemoveException("Error removing data.", ex);
            }
        }

        public void UpdateRole(long accountId, int roleId)
        {
            try
            {
                Account account = GetById(accountId);
                account.RoleId = roleId;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Users_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(account, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating data.", ex);
            }
        }

        private void AddParametersForAdd(Account account, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int64,
                Direction = ParameterDirection.InputOutput,
                Value = account.Id ?? (object)DBNull.Value
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Login", account.Login);
            command.Parameters.AddWithValue("@Password", account.PasswordHash);
            command.Parameters.AddWithValue("@RoleId", account.RoleId);
        }
        private void AddParametersForCount(AccountSearchOptions searchOptions, string searchLine, SqlCommand command)
        {
            if (searchOptions != AccountSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchLine);
            }
        }

        private Account GetAuthorByReader(SqlDataReader reader)
        {
            return new Account()
            {
                Id = (long)reader["Id"],
                Login = (string)reader["Login"],
                PasswordHash = (string)reader["Password"],
                RoleId = (int)reader["RoleId"]
            };
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, AccountSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case AccountSearchOptions.Login:
                    storedProcedure = "dbo.Users_SearchByLogin";
                    break;
                default:
                    storedProcedure = "dbo.Users_GetAll";
                    break;
            }

            return storedProcedure;
        }
        private string GetProcedureForCount(AccountSearchOptions searchOptions)
        {
            string storedProcedure;

            switch (searchOptions)
            {
                case AccountSearchOptions.Login:
                    storedProcedure = "dbo.Users_CountByLogin";
                    break;
                default:
                    storedProcedure = "dbo.Users_Count";
                    break;
            }

            return storedProcedure;
        }

        private void AddParametersForSearch(SearchRequest<SortOptions, AccountSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != AccountSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            PagingInfo page = searchRequest?.PagingInfo ?? new PagingInfo();

            command.Parameters.AddWithValue("@SortDescending", searchRequest?.SortOptions.HasFlag(SortOptions.Descending) ?? false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }

    }
}

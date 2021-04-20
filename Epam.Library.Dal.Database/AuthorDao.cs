using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Epam.Library.Dal.Database
{
    public class AuthorDao : IAuthorDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        public AuthorDao(ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
        }

        public void Add(Author author)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Authors_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    AddParametersForAdd(author, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Add), "Error adding data.", ex);
            }
        }

        public bool Check(int[] ids, RoleType role = RoleType.None)
        {
            bool result;

            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Authors_Check", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForCheck(ids, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    reader.Read();
                    result = (bool)reader["Result"];
                }

                return result;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Check), "Error getting data.", ex);
            }
        }

        public Author Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                Author author;

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Authors_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    author = reader.Read()
                             ? GetAuthorByReader(reader)
                             : null;
                }

                return author;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Get), "Error getting data.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Authors_Remove", connection)
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
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Remove), "Error removing data.", ex);
            }
        }

        public void Update(Author autor)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Authors_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(autor, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Update), "Error updating data.", ex);
            }
        }

        public IEnumerable<Author> Search(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                List<Author> authorList = new List<Author>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
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
                        authorList.Add(GetAuthorByReader(reader));
                    }
                }

                return authorList;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(AuthorDao), nameof(Search), "Error getting data.", ex);
            }
        }

        private void AddParametersForAdd(Author author, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = author.Id ?? (object)DBNull.Value
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@FirstName", author.FirstName);
            command.Parameters.AddWithValue("@LastName", author.LastName);
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != AuthorSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            PagingInfo page = searchRequest?.PagingInfo ?? new PagingInfo();
            
            command.Parameters.AddWithValue("@SortDescending", searchRequest?.SortOptions.HasFlag(SortOptions.Descending) ?? false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForCheck(int[] ids, SqlCommand command)
        {
            DataTable authorTable = WrapInTable(ids);

            var authorParam = command.Parameters.AddWithValue("@AuthorIDs", authorTable);
            authorParam.SqlDbType = SqlDbType.Structured;
            authorParam.TypeName = "dbo.IDList";
        }

        private Author GetAuthorByReader(SqlDataReader reader)
        {
            return new Author()
            {
                Id = (int)reader["Id"],
                FirstName = (string)reader["FirstName"],
                LastName = (string)reader["LastName"],
                Deleted = (bool)reader["Deleted"]
            };
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, AuthorSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case AuthorSearchOptions.FirstName:
                    storedProcedure = "dbo.Authors_SearchByFirstName";
                    break;
                case AuthorSearchOptions.LastName:
                    storedProcedure = "dbo.Authors_SearchByLastName";
                    break;
                default:
                    storedProcedure = "dbo.Authors_GetAll";
                    break;
            }

            return storedProcedure;
        }

        private DataTable WrapInTable(int[] AuthorIDs)
        {
            DataTable authorTable = new DataTable();
            authorTable.Columns.Add(new DataColumn("ID", typeof(int)));

            if (AuthorIDs != null)
            {
                foreach (var id in AuthorIDs)
                {
                    authorTable.Rows.Add(id);
                }
            }

            return authorTable;
        }
    }
}

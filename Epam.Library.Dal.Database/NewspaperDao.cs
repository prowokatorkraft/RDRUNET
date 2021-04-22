using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace Epam.Library.Dal.Database
{
    public class NewspaperDao : INewspaperDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        public NewspaperDao(ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
        }

        public void Add(Newspaper newspaper)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Newspapers_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(newspaper, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(NewspaperDao), nameof(Add), "Error adding data.", ex);
            }
        }

        public Newspaper Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                Newspaper newspaper;

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Newspapers_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    newspaper = reader.Read()
                           ? GetNewspaperByReader(reader)
                           : null;
                }

                return newspaper;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(NewspaperDao), nameof(Get), "Error getting data.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Newspapers_Remove", connection)
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
                throw new LayerException("Dal", nameof(NewspaperDao), nameof(Remove), "Error removing data.", ex);
            }
        }

        public IEnumerable<Newspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                List<Newspaper> newspaperList = new List<Newspaper>();

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
                        newspaperList.Add(GetNewspaperByReader(reader));
                    }
                }

                return newspaperList;
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(NewspaperDao), nameof(Search), "Error getting data.", ex);
            }
        }

        public void Update(Newspaper newspaper)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Newspapers_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(newspaper, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new LayerException("Dal", nameof(NewspaperDao), nameof(Update), "Error updating data.", ex);
            }
        }

        private void AddParametersForAdd(Newspaper newspaper, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = newspaper.Id ?? (object)DBNull.Value
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Name", newspaper.Name);
            command.Parameters.AddWithValue("@Issn", newspaper.Issn);
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != NewspaperSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            PagingInfo page = searchRequest?.PagingInfo ?? new PagingInfo();

            command.Parameters.AddWithValue("@SortDescending", searchRequest?.SortOptions.HasFlag(SortOptions.Descending) ?? false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }

        private Newspaper GetNewspaperByReader(SqlDataReader reader)
        {
            Newspaper newspaper;

            newspaper = new Newspaper()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
                Deleted = (bool)reader["Deleted"],
                Issn = reader["Issn"] as string
            };

            return newspaper;
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case NewspaperSearchOptions.Name:
                    storedProcedure = "dbo.Newspapers_SearchByName";
                    break;
                default:
                    storedProcedure = "dbo.Newspapers_GetAll";
                    break;
            }

            return storedProcedure;
        }
    }
}

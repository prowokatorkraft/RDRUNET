using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace Epam.Library.Dal.Database
{
    public class PatentDao : IPatentDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        public PatentDao(ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
        }

        public void Add(AbstractPatent patent)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(patent, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractPatent Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                AbstractPatent patent;

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    patent = reader.Read()
                           ? GetPatentByReader(reader)
                           : null;
                }

                return patent;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractPatent>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                Dictionary<int, List<AbstractPatent>> group = new Dictionary<int, List<AbstractPatent>>();
                List<AbstractPatent> bookList = new List<AbstractPatent>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_SearchByPublishingYear", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForSearchByPublishingYear(null, page, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        bookList.Add(GetPatentByReader(reader));
                    }
                }

                GroupByPublishingYear(group, bookList);

                return group;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<AbstractPatent> GetByAuthorId(int id, PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                List<AbstractPatent> patentList = new List<AbstractPatent>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_GetByAuthorId", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForGet(id, page ?? new PagingInfo(), command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        patentList.Add(GetPatentByReader(reader));
                    }
                }

                return patentList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_Remove", connection)
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

        public void Update(AbstractPatent patent)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.Patents_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(patent, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating data.", ex);
            }
        }

        public IEnumerable<AbstractPatent> Search(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                List<AbstractPatent> patentList = new List<AbstractPatent>();

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
                        patentList.Add(GetPatentByReader(reader));
                    }
                }

                return patentList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private void AddParametersForAdd(AbstractPatent patent, SqlCommand command)
        {
            DataTable authorTable = WrapInTable(patent.AuthorIDs);

            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = patent.Id
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Name", patent.Name);
            command.Parameters.AddWithValue("@NumberOfPages", patent.NumberOfPages);
            command.Parameters.AddWithValue("@Annotation", patent.Annotation);
            command.Parameters.AddWithValue("@Country", patent.Country);
            command.Parameters.AddWithValue("@RegistrationNumber", patent.RegistrationNumber);
            command.Parameters.AddWithValue("@ApplicationDate", patent.ApplicationDate);
            command.Parameters.AddWithValue("@DateOfPublication", patent.DateOfPublication);

            var authorParam = command.Parameters.AddWithValue("@AuthorIDs", authorTable);
            authorParam.SqlDbType = SqlDbType.Structured;
            authorParam.TypeName = "dbo.IDList";
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, PatentSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != PatentSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            PagingInfo page = searchRequest?.PagingInfo ?? new PagingInfo();

            command.Parameters.AddWithValue("@SortDescending", searchRequest?.SortOptions.HasFlag(SortOptions.Descending) ?? false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForSearchByPublishingYear(int? publishingYear, PagingInfo paging, SqlCommand command)
        {
            if (publishingYear != null)
            {
                command.Parameters.AddWithValue("@SearchLine", publishingYear);
            }

            PagingInfo page = paging is null
                        ? new PagingInfo()
                        : paging;

            command.Parameters.AddWithValue("@SortDescending", false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForGet(int id, PagingInfo page, SqlCommand command)
        {
            command.Parameters.AddWithValue("@Id", id);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
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

        private AbstractPatent GetPatentByReader(SqlDataReader reader)
        {
            AbstractPatent patent;

            var AuthorIdList = new List<int>();

            string AuthorIdJson = reader["AuthorIDs"] as string;

            if (AuthorIdJson != null)
            {
                var AuthorIdObject = JsonConvert.DeserializeObject<JArray>(AuthorIdJson);

                foreach (var item in AuthorIdObject)
                {
                    AuthorIdList.Add((int)item["AuthorId"]);
                }
            }

            patent = new Patent()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
                NumberOfPages = (int)reader["NumberOfPages"],
                Annotation = reader["Annotation"] as string,
                Deleted = (bool)reader["Deleted"],
                AuthorIDs = AuthorIdList.ToArray(),
                Country = (string)reader["Country"],
                RegistrationNumber = (string)reader["RegistrationNumber"],
                ApplicationDate = reader["ApplicationDate"] as DateTime?,
                DateOfPublication = (DateTime)reader["DateOfPublication"]
            };

            return patent;
        }

        private void GroupByPublishingYear(Dictionary<int, List<AbstractPatent>> group, List<AbstractPatent> patentList)
        {
            foreach (var keyItem in patentList.GroupBy(e => e.DateOfPublication.Year))
            {
                var list = group.ContainsKey(keyItem.Key)
                           ? group[keyItem.Key]
                           : group[keyItem.Key] = new List<AbstractPatent>();

                foreach (var valueItem in keyItem)
                {
                    list.Add(valueItem);
                }
            }
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, PatentSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case PatentSearchOptions.Name:
                    storedProcedure = "dbo.Patents_SearchByName";
                    break;
                default:
                    storedProcedure = "dbo.Patents_GetAll";
                    break;
            }

            return storedProcedure;
        }
    }
}

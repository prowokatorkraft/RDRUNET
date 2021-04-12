using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace Epam.Library.Dal.Database
{
    public class NewspaperDao : INewspaperDao
    {
        private readonly string _connectionString;
        
        public NewspaperDao()/////
        {
            _connectionString = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=Library;Integrated Security=true;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;MultipleActiveResultSets=true;ApplicationIntent=ReadWrite;MultiSubnetFailover=False";
        }

        public void Add(AbstractNewspaper newspaper)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
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
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractNewspaper Get(int id)
        {
            try
            {
                AbstractNewspaper newspaper;

                using (SqlConnection connection = new SqlConnection(_connectionString))
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
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractNewspaper>> GetAllGroupsByPublishYear(PagingInfo page = null)
        {
            try
            {
                Dictionary<int, List<AbstractNewspaper>> group = new Dictionary<int, List<AbstractNewspaper>>();
                List<AbstractNewspaper> newspaperList = new List<AbstractNewspaper>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Newspapers_SearchByPublishingYear", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForSearchByPublishingYear(null, page, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        newspaperList.Add(GetNewspaperByReader(reader));
                    }
                }

                GroupByPublishingYear(group, newspaperList);

                return group;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool Remove(int id)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
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
                throw new RemoveException("Error removing data.", ex);
            }
        }

        public void Update(AbstractNewspaper newspaper)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
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
                throw new UpdateException("Error updating data.", ex);
            }
        }

        public IEnumerable<AbstractNewspaper> Search(SearchRequest<SortOptions, NewspaperSearchOptions> searchRequest)
        {
            try
            {
                List<AbstractNewspaper> newspaperList = new List<AbstractNewspaper>();

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
                        newspaperList.Add(GetNewspaperByReader(reader));
                    }
                }

                return newspaperList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private void AddParametersForAdd(AbstractNewspaper newspaper, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = newspaper.Id
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Name", newspaper.Name);
            command.Parameters.AddWithValue("@NumberOfPages", newspaper.NumberOfPages);
            command.Parameters.AddWithValue("@Annotation", newspaper.Annotation);
            command.Parameters.AddWithValue("@Publisher", newspaper.Publisher);
            command.Parameters.AddWithValue("@PublishingCity", newspaper.PublishingCity);
            command.Parameters.AddWithValue("@Number", newspaper.Number);
            command.Parameters.AddWithValue("@Date", newspaper.Date);
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

        private AbstractNewspaper GetNewspaperByReader(SqlDataReader reader)
        {
            AbstractNewspaper newspaper;

            newspaper = new Newspaper()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
                NumberOfPages = (int)reader["NumberOfPages"],
                Annotation = reader["Annotation"] as string,
                Deleted = (bool)reader["Deleted"],
                Publisher = (string)reader["Publisher"],
                PublishingCity = (string)reader["PublishingCity"],
                PublishingYear = ((DateTime)reader["Date"]).Year,
                Date = (DateTime)reader["Date"],
                Number = reader["Number"] as string,
                Issn = reader["Issn"] as string
            };

            return newspaper;
        }

        private void GroupByPublishingYear(Dictionary<int, List<AbstractNewspaper>> group, List<AbstractNewspaper> newspaperList)
        {
            foreach (var keyItem in newspaperList.GroupBy(e => e.PublishingYear))
            {
                var list = group.ContainsKey(keyItem.Key)
                           ? group[keyItem.Key]
                           : group[keyItem.Key] = new List<AbstractNewspaper>();

                foreach (var valueItem in keyItem)
                {
                    list.Add(valueItem);
                }
            }
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

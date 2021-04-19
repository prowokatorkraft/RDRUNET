using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace Epam.Library.Dal.Database
{
    public class NewspaperIssueDao : INewspaperIssueDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        public NewspaperIssueDao(ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
        }

        public void Add(NewspaperIssue issue)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(issue, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public NewspaperIssue Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                NewspaperIssue issue;

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    issue = reader.Read()
                           ? GetIssueByReader(reader)
                           : null;
                }

                return issue;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<NewspaperIssue> GetAllByNewspaper(int newspaperId, PagingInfo paging = null, SortOptions sort = SortOptions.None, RoleType role = RoleType.None)
        {
            try
            {
                List<NewspaperIssue> newspaperList = new List<NewspaperIssue>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_GetAllByNewspaperId", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForGetAllByNewspaper(newspaperId, paging, sort, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        newspaperList.Add(GetIssueByReader(reader));
                    }
                }

                return newspaperList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public int GetCountByNewspaper(int newspaperId, RoleType role = RoleType.None)
        {
            try
            {
                int count;

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_GetCountByNewspaperId", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", newspaperId);

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

        public Dictionary<int, List<NewspaperIssue>> GetAllGroupsByPublishYear(PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                Dictionary<int, List<NewspaperIssue>> group = new Dictionary<int, List<NewspaperIssue>>();
                List<NewspaperIssue> newspaperList = new List<NewspaperIssue>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_SearchByPublishingYear", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForSearchByPublishingYear(null, page, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        newspaperList.Add(GetIssueByReader(reader));
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

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_Remove", connection)
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

        public IEnumerable<NewspaperIssue> Search(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                List<NewspaperIssue> newspaperList = new List<NewspaperIssue>();

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
                        newspaperList.Add(GetIssueByReader(reader));
                    }
                }

                return newspaperList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public void Update(NewspaperIssue issue)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(RoleType.librarian)))
                {
                    SqlCommand command = new SqlCommand("dbo.NewspaperIssues_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(issue, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating data.", ex);
            }
        }
        
        private NewspaperIssue GetIssueByReader(SqlDataReader reader)
        {
            NewspaperIssue issue;

            issue = new NewspaperIssue()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
                NumberOfPages = (int)reader["NumberOfPages"],
                Annotation = reader["Annotation"] as string,
                Deleted = (bool)reader["Deleted"],
                Publisher = (string)reader["Publisher"],
                PublishingCity = (string)reader["PublishingCity"],
                PublishingYear = ((DateTime)reader["Date"]).Year,
                Number = reader["Number"] as int?,
                Date = (DateTime)reader["Date"],
                NewspaperId = (int)reader["NewspaperId"]
            };

            return issue;
        }
        
        private string GetProcedureForSearch(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case NewspaperIssueSearchOptions.Name:
                    storedProcedure = "dbo.NewspaperIssues_SearchByName";
                    break;
                default:
                    storedProcedure = "dbo.NewspaperIssues_GetAll";
                    break;
            }

            return storedProcedure;
        }

        private void AddParametersForAdd(NewspaperIssue issue, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = issue.Id
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Name", issue.Name);
            command.Parameters.AddWithValue("@NumberOfPages", issue.NumberOfPages);
            command.Parameters.AddWithValue("@Annotation", issue.Annotation);
            command.Parameters.AddWithValue("@Publisher", issue.Publisher);
            command.Parameters.AddWithValue("@PublishingCity", issue.PublishingCity);
            command.Parameters.AddWithValue("@Number", issue.Number);
            command.Parameters.AddWithValue("@Date", issue.Date);
            command.Parameters.AddWithValue("@NewspaperId", issue.NewspaperId);
        }
        private void AddParametersForGetAllByNewspaper(int id, PagingInfo paging, SortOptions sort, SqlCommand command)
        {
            command.Parameters.AddWithValue("@Id", id);

            PagingInfo page = paging ?? new PagingInfo();

            command.Parameters.AddWithValue("@SortDescending", sort.HasFlag(SortOptions.Descending) ? false : true);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, NewspaperIssueSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != NewspaperIssueSearchOptions.None)
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

        private void GroupByPublishingYear(Dictionary<int, List<NewspaperIssue>> group, List<NewspaperIssue> issueList)
        {
            foreach (var keyItem in issueList.GroupBy(e => e.PublishingYear))
            {
                var list = group.ContainsKey(keyItem.Key)
                           ? group[keyItem.Key]
                           : group[keyItem.Key] = new List<NewspaperIssue>();

                foreach (var valueItem in keyItem)
                {
                    list.Add(valueItem);
                }
            }
        }

        
    }
}

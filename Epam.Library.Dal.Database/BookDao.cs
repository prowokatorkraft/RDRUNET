using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Epam.Library.Dal.Database
{
    public class BookDao : IBookDao
    {
        private readonly string _connectionString;

        public BookDao(string connectionString)
        {
            _connectionString = connectionString;
        }

        public void Add(AbstractBook book)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_Add", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    DataTable authorTable = WrapInTable(book.AuthorIDs);

                    AddParametersForAdd(book, authorTable, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        public AbstractBook Get(int id)
        {
            try
            {
                AbstractBook book;

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    book = reader.Read()
                           ? GetBookByReader(reader)
                           : null;
                }

                return book;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            try
            {
                Dictionary<string, List<AbstractBook>> group = new Dictionary<string, List<AbstractBook>>();
                List<AbstractBook> bookList = new List<AbstractBook>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_SearchByPublisher", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    searchRequest.SearchOptions = BookSearchOptions.Publisher;
                    AddParametersForSearch(searchRequest, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        bookList.Add(GetBookByReader(reader));
                    }
                }

                GroupByPublisher(group, bookList);

                return group;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear(PagingInfo page = null)
        {
            try
            {
                Dictionary<int, List<AbstractBook>> group = new Dictionary<int, List<AbstractBook>>();
                List<AbstractBook> bookList = new List<AbstractBook>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_SearchByPublishingYear", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForSearchByPublishingYear(null, page, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        bookList.Add(GetBookByReader(reader));
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

        public IEnumerable<AbstractBook> GetByAuthorId(int id, PagingInfo page)
        {
            try
            {
                List<AbstractBook> bookList = new List<AbstractBook>();

                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_GetByAuthorId", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForGet(id, page ?? new PagingInfo(), command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        bookList.Add(GetBookByReader(reader));
                    }
                }

                return bookList;
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
                    SqlCommand command = new SqlCommand("dbo.Books_Remove", connection)
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

        public IEnumerable<AbstractBook> Search(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            try
            {
                List<AbstractBook> bookList = new List<AbstractBook>();

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
                        bookList.Add(GetBookByReader(reader));
                    }
                }

                return bookList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public void Update(AbstractBook book)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(_connectionString))
                {
                    SqlCommand command = new SqlCommand("dbo.Books_Update", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForAdd(book, WrapInTable(book.AuthorIDs), command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating data.", ex);
            }
        }

        private void AddParametersForAdd(AbstractBook book, DataTable authorTable, SqlCommand command)
        {
            var idParam = new SqlParameter()
            {
                ParameterName = "@Id",
                DbType = DbType.Int32,
                Direction = ParameterDirection.InputOutput,
                Value = book.Id ?? (object)DBNull.Value
            };
            command.Parameters.Add(idParam);

            command.Parameters.AddWithValue("@Name", book.Name);
            command.Parameters.AddWithValue("@NumberOfPages", book.NumberOfPages);
            command.Parameters.AddWithValue("@Annotation", book.Annotation ?? (object)DBNull.Value);
            command.Parameters.AddWithValue("@Publisher", book.Publisher);
            command.Parameters.AddWithValue("@PublishingCity", book.PublishingCity);
            command.Parameters.AddWithValue("@PublishingYear", book.PublishingYear);
            command.Parameters.AddWithValue("@Isbn", book.Isbn ?? (object)DBNull.Value);

            var authorParam = command.Parameters.AddWithValue("@AuthorIDs", authorTable);
            authorParam.SqlDbType = SqlDbType.Structured;
            authorParam.TypeName = "dbo.IDList";
        }
        private void AddParametersForGet(int id, PagingInfo page, SqlCommand command)
        {
            command.Parameters.AddWithValue("@Id", id);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForGrouping(PagingInfo page, SqlCommand command)
        {
            command.Parameters.AddWithValue("@SortDescending", false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, BookSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != BookSearchOptions.None)
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

        private AbstractBook GetBookByReader(SqlDataReader reader)
        {
            AbstractBook book;

            var AuthorIdList = new List<int>();

            string AuthorIdJson = reader["AuthorIDs"] as string;

            if (AuthorIdJson != null)
            {
                var AuthorIdObject = JsonConvert.DeserializeObject<JArray>((string)reader["AuthorIDs"]);

                foreach (var item in AuthorIdObject)
                {
                    AuthorIdList.Add((int)item["AuthorId"]);
                }
            }

            book = new Book()
            {
                Id = (int)reader["Id"],
                Name = (string)reader["Name"],
                NumberOfPages = (int)reader["NumberOfPages"],
                Annotation = reader["Annotation"] as string,
                Deleted = (bool)reader["Deleted"],
                AuthorIDs = AuthorIdList.ToArray(),
                Publisher = (string)reader["Publisher"],
                PublishingCity = (string)reader["PublishingCity"],
                PublishingYear = (int)reader["PublishingYear"],
                Isbn = reader["Isbn"] as string
            };

            return book;
        }

        private void GroupByPublisher(Dictionary<string, List<AbstractBook>> group, List<AbstractBook> bookList)
        {
            foreach (var keyItem in bookList.GroupBy(e => e.Publisher))
            {
                var list = group.ContainsKey(keyItem.Key)
                          ? group[keyItem.Key]
                          : group[keyItem.Key] = new List<AbstractBook>();

                foreach (var valueItem in keyItem)
                {
                    group[keyItem.Key].Add(valueItem);
                }
            }
        }
        private void GroupByPublishingYear(Dictionary<int, List<AbstractBook>> group, List<AbstractBook> bookList)
        {
            foreach (var keyItem in bookList.GroupBy(e => e.PublishingYear))
            {
                var list = group.ContainsKey(keyItem.Key)
                           ? group[keyItem.Key]
                           : group[keyItem.Key] = new List<AbstractBook>();

                foreach (var valueItem in keyItem)
                {
                    list.Add(valueItem);
                }
            }
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case BookSearchOptions.Name:
                    storedProcedure = "dbo.Books_SearchByName";
                    break;
                case BookSearchOptions.Publisher:
                    storedProcedure = "dbo.Books_SearchByPublisher";
                    break;
                default:
                    storedProcedure = "dbo.Books_GetAll";
                    break;
            }

            return storedProcedure;
        }
    }
}


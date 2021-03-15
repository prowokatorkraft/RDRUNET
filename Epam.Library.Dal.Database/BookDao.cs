using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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

                    AddParametrs(book, authorTable, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new AddException("Error adding data.", ex);
            }
        }

        private void AddParametrs(AbstractBook book, DataTable authorTable, SqlCommand command)
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

                    reader.Read();

                    book = GetObjectByReader(reader);
                }

                return book;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private AbstractBook GetObjectByReader(SqlDataReader reader)
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

            book = new Book(
                (int)reader["Id"],
                (string)reader["Name"],
                (int)reader["NumberOfPages"],
                reader["Annotation"] as string,
                (bool)reader["Deleted"],
                AuthorIdList.ToArray(),
                (string)reader["Publisher"],
                (string)reader["PublishingCity"],
                (int)reader["PublishingYear"],
                reader["Isbn"] as string);

            return book;
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

                    searchRequest.SearchOptions = BookSearchOptions.Publisher; // ??

                    AddParametersForSearch(searchRequest, command);

                    connection.Open();

                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        bookList.Add(GetObjectByReader(reader));
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

        private void GroupByPublisher(Dictionary<string, List<AbstractBook>> group, List<AbstractBook> bookList)
        {
            foreach (var keyItem in bookList.GroupBy(e => e.Publisher))
            {
                if (!group.Keys.Any(s => s.Equals(keyItem)))
                {
                    group[keyItem.Key] = new List<AbstractBook>();
                }

                group[keyItem.Key] = new List<AbstractBook>();

                foreach (var valueItem in keyItem)
                {
                    group[keyItem.Key].Add(valueItem);
                }
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
                    SqlCommand command = new SqlCommand("dbo.Books_GetAllByPublishingYear", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };

                    command.Parameters.AddWithValue("@SortDescending", false);
                    command.Parameters.AddWithValue("@SizePage", page != null ? page.SizePage : PagingInfo.Default.SizePage);
                    command.Parameters.AddWithValue("@Page", page != null ? page.Page : PagingInfo.Default.Page);

                    connection.Open();

                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        bookList.Add(GetObjectByReader(reader));
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

        private void GroupByPublishingYear(Dictionary<int, List<AbstractBook>> group, List<AbstractBook> bookList)
        {
            foreach (var keyItem in bookList.GroupBy(e => e.PublishingYear))
            {
                if (!group.Keys.Any(s => s.Equals(keyItem)))
                {
                    group[keyItem.Key] = new List<AbstractBook>();
                }

                group[keyItem.Key] = new List<AbstractBook>();

                foreach (var valueItem in keyItem)
                {
                    group[keyItem.Key].Add(valueItem);
                }
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

                    command.Parameters.AddWithValue("@Id", id);
                    command.Parameters.AddWithValue("@SizePage", page != null ? page.SizePage : PagingInfo.Default.SizePage);
                    command.Parameters.AddWithValue("@Page", page != null ? page.Page : PagingInfo.Default.Page);

                    connection.Open();

                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        bookList.Add(GetObjectByReader(reader));
                    }
                }

                return bookList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public bool Remove(int id) // Mark
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
                        bookList.Add(GetObjectByReader(reader));
                    }
                }

                return bookList;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, BookSearchOptions> searchRequest)
        {
            string storedProcedure;
            if (searchRequest is null)
            {
                storedProcedure = "dbo.Books_GetAll";
            }
            else
            {
                switch (searchRequest.SearchOptions)
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
            }

            return storedProcedure;
        }

        private void AddParametersForSearch(SearchRequest<SortOptions, BookSearchOptions> searchRequest, SqlCommand command)
        {
            //bool r = searchRequest.SearchOptions.HasFlag(BookSearchOptions.None); // Bug: None

            if (searchRequest != null && (int)searchRequest.SearchOptions != (int)BookSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            command.Parameters.AddWithValue("@SortDescending", searchRequest.SortOptions.HasFlag(SortOptions.Descending) ? true : false);
            command.Parameters.AddWithValue("@SizePage", searchRequest.PagingInfo != null ? searchRequest.PagingInfo.SizePage : PagingInfo.Default.SizePage);
            command.Parameters.AddWithValue("@Page", searchRequest.PagingInfo != null ? searchRequest.PagingInfo.Page : PagingInfo.Default.Page);
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

                    DataTable authorTable = WrapInTable(book.AuthorIDs);

                    AddParametrs(book, authorTable, command);

                    connection.Open();

                    command.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                throw new UpdateException("Error updating data.", ex);
            }
        }
    }
}

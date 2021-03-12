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

                    DataTable authorTable = WrapInTable(book);

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
                Direction = ParameterDirection.Output
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

        private DataTable WrapInTable(AbstractBook book)
        {
            DataTable authorTable = new DataTable();
            authorTable.Columns.Add(new DataColumn("ID", typeof(int)));

            if (book.AuthorIDs != null)
            {
                foreach (var id in book.AuthorIDs)
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

            var AuthorIdJson = JsonConvert.DeserializeObject<JArray>((string)reader["AuthorIDs"]);
            var AuthorIdList = new List<int>();

            foreach (var item in AuthorIdJson)
            {
                AuthorIdList.Add((int)item["AuthorId"]);
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

        public Dictionary<string, List<AbstractBook>> GetAllGroupsByPublisher(string searchLine)
        {
            throw new NotImplementedException();
        }

        public Dictionary<int, List<AbstractBook>> GetAllGroupsByPublishYear()
        {
            throw new NotImplementedException();
        }

        public IEnumerable<AbstractBook> GetByAuthorId(int id)
        {
            throw new NotImplementedException();
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
            throw new NotImplementedException();
        }
    }
}

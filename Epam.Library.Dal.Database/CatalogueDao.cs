using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.Exceptions;
using Epam.Library.Dal.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Epam.Library.Dal.Database
{
    public class CatalogueDao : ICatalogueDao
    {
        private readonly ConnectionStringDb _connectionStrings;

        private readonly IBookDao _bookDao;
        private readonly IPatentDao _patentDao;
        private readonly INewspaperIssueDao _newspaperIssueDao;

        public CatalogueDao(IBookDao bookDao, IPatentDao patentDao, INewspaperIssueDao newspaperIssueDao, ConnectionStringDb connectionStrings)
        {
            _connectionStrings = connectionStrings;
            _bookDao = bookDao;
            _patentDao = patentDao;
            _newspaperIssueDao = newspaperIssueDao;
        }

        public void Add(LibraryAbstractElement element)
        {
            throw new NotImplementedException();
        }

        public bool Remove(int id, RoleType role = RoleType.None)
        {
            throw new NotImplementedException();
        }

        public LibraryAbstractElement Get(int id, RoleType role = RoleType.None)
        {
            try
            {
                TypeDaoEnum typeDao;
                
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Catalogue_GetById", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    command.Parameters.AddWithValue("@Id", id);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    typeDao = reader.Read()
                           ? GetTypeDaoByReader(reader)
                           : TypeDaoEnum.None;
                }

                return GetElementByTypeDao(id, typeDao, role);
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<AbstractAuthorElement> GetByAuthorId(int id, PagingInfo page = null, RoleType role = RoleType.None)
        {
            try
            {
                List<AbstractAuthorElement> authorElements = new List<AbstractAuthorElement>();
                List<int> idList = new List<int>();

                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
                {
                    SqlCommand command = new SqlCommand("dbo.Catalogue_GetByAuthorId", connection)
                    {
                        CommandType = System.Data.CommandType.StoredProcedure
                    };
                    AddParametersForGet(id, page, command);

                    connection.Open();

                    var reader = command.ExecuteReader();
                    while (reader.Read())
                    {
                        idList.Add((reader["BookId"] as int? ?? reader["PatentId"] as int?).Value);
                    }
                }

                idList.ForEach(e => authorElements.Add(Get(e) as AbstractAuthorElement));

                return authorElements;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public IEnumerable<LibraryAbstractElement> Search(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, RoleType role = RoleType.None)
        {
            try
            {
                List<LibraryAbstractElement> elements = new List<LibraryAbstractElement>();
                List<int> idList = new List<int>();
                
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
                        idList.Add((int)reader["Id"]);
                    }
                }

                idList.ForEach(e => elements.Add(Get(e, role)));

                return elements;
            }
            catch (Exception ex)
            {
                throw new GetException("Error getting data.", ex);
            }
        }

        public int GetCount(CatalogueSearchOptions searchOptions = CatalogueSearchOptions.None, string searchLine = null, RoleType role = RoleType.None)
        {
            try
            {
                int count;

                string storedProcedure = GetProcedureForCount(searchOptions);
                using (SqlConnection connection = new SqlConnection(_connectionStrings.GetByRole(role)))
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

        private TypeDaoEnum GetTypeDaoByReader(SqlDataReader reader)
        {
            if (reader["BookId"] is int)
            {
                return TypeDaoEnum.Book;
            }
            if (reader["PatentId"] is int)
            {
                return TypeDaoEnum.Patent;
            }
            if (reader["NewspaperId"] is int)
            {
                return TypeDaoEnum.Newspaper;
            }

            return TypeDaoEnum.None;
        }

        private void AddParametersForGet(int id, PagingInfo pagingInfo, SqlCommand command)
        {
            PagingInfo page = pagingInfo ?? new PagingInfo();

            command.Parameters.AddWithValue("@Id", id);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForSearch(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest, SqlCommand command)
        {
            if (searchRequest != null && searchRequest.SearchOptions != CatalogueSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchRequest.SearchLine);
            }

            PagingInfo page = searchRequest?.PagingInfo ?? new PagingInfo();

            command.Parameters.AddWithValue("@SortDescending", searchRequest?.SortOptions.HasFlag(SortOptions.Descending) ?? false);
            command.Parameters.AddWithValue("@SizePage", page.SizePage);
            command.Parameters.AddWithValue("@Page", page.PageNumber);
        }
        private void AddParametersForCount(CatalogueSearchOptions searchOptions, string searchLine, SqlCommand command)
        {
            if (searchOptions != CatalogueSearchOptions.None)
            {
                command.Parameters.AddWithValue("@SearchLine", searchLine);
            }
        }

        private LibraryAbstractElement GetElementByTypeDao(int id, TypeDaoEnum typeDao, RoleType role)
        {
            switch (typeDao)
            {
                case TypeDaoEnum.Book:
                    return _bookDao.Get(id, role);
                case TypeDaoEnum.Patent:
                    return _patentDao.Get(id, role);
                case TypeDaoEnum.Newspaper:
                    return _newspaperIssueDao.Get(id, role);
                default:
                    return null;
            }
        }

        private string GetProcedureForSearch(SearchRequest<SortOptions, CatalogueSearchOptions> searchRequest)
        {
            string storedProcedure;

            switch (searchRequest?.SearchOptions)
            {
                case CatalogueSearchOptions.Name:
                    storedProcedure = "dbo.Catalogue_SearchByName";
                    break;
                default:
                    storedProcedure = "dbo.Catalogue_GetAll";
                    break;
            }

            return storedProcedure;
        }
        private string GetProcedureForCount(CatalogueSearchOptions searchOptions)
        {
            string storedProcedure;

            switch (searchOptions)
            {
                case CatalogueSearchOptions.Name:
                    storedProcedure = "dbo.Catalogue_CountByName";
                    break;
                default:
                    storedProcedure = "dbo.Catalogue_Count";
                    break;
            }

            return storedProcedure;
        }
    }
}

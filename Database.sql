USE [master]
GO
/****** Object:  Database [Library]    Script Date: 3/19/2021 2:02:15 PM ******/
CREATE DATABASE [Library]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Library', FILENAME = N'' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Library_log', FILENAME = N'' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Library] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Library].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Library] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Library] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Library] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Library] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Library] SET ARITHABORT OFF 
GO
ALTER DATABASE [Library] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Library] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Library] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Library] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Library] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Library] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Library] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Library] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Library] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Library] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Library] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Library] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Library] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Library] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Library] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Library] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Library] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Library] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Library] SET  MULTI_USER 
GO
ALTER DATABASE [Library] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Library] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Library] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Library] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Library] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Library] SET QUERY_STORE = OFF
GO
USE [Library]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Library]
GO
/****** Object:  DatabaseRole [db_user]    Script Date: 3/19/2021 2:02:15 PM ******/
CREATE ROLE [db_user]
GO
/****** Object:  DatabaseRole [db_librarian]    Script Date: 3/19/2021 2:02:15 PM ******/
CREATE ROLE [db_librarian]
GO
/****** Object:  DatabaseRole [db_admin]    Script Date: 3/19/2021 2:02:15 PM ******/
CREATE ROLE [db_admin]
GO
/****** Object:  UserDefinedTableType [dbo].[IDList]    Script Date: 3/19/2021 2:02:16 PM ******/
CREATE TYPE [dbo].[IDList] AS TABLE(
	[ID] [int] NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueAuthor]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CheckUniqueAuthor]
(	
	@Id int = null,
	@FirstName nvarchar(50),
	@LastName nvarchar(200)
)
RETURNS bit
AS
Begin
	declare @Count int;
	
	select @Count = Count(Id) from Authors
	where 
		Deleted <> 1 and
		FirstName = @FirstName and 
		LastName = @LastName and
		((@Id is not null and Id <> @Id) or @Id is null);

	if @Count > 0 return 0;
	
	return 1;
end;

GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueBook]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckUniqueBook]
(
	@Id int = null,
	@Name nvarchar(300),
	@PublishingYear int,
	@Isbn nvarchar(18) = null,
	@AuthorIDs dbo.IDList readonly
)
RETURNS bit
AS
BEGIN
	declare @Count int;

	if @Isbn is not null
		select @Count = Count(*) from Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where Deleted <> 1 and ISBN = @Isbn;
	else
	begin
		declare @AuthorIDsCount int;
		set @AuthorIDsCount = (select COUNT(*) from @AuthorIDs);

		select @Count = Count(Catalogue.Id) from Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where 
			Deleted <> 1 and
			[Name] = @Name and 
			PublishingYear = @PublishingYear and
			((@Id is not null and Catalogue.Id <> @Id) or @Id is null) and
			((0 = @AuthorIDsCount and 0 = (select count(*) from AuthorsBooksAndPatents where Catalogue.Id = BooksId)) or 
			 Catalogue.Id in (select BooksId from AuthorsBooksAndPatents as abap1
							where (select Count(*) from AuthorsBooksAndPatents as abap2
									where abap1.BooksId = abap2.BooksId) = @AuthorIDsCount and
									exists
											(select BooksId from AuthorsBooksAndPatents as abap3
											where abap3.BooksId = abap1.BooksId and
												 abap3.AuthorId in (select Id from @AuthorIDs))));
	end

	if @Count > 0 return 0;
	
	return 1;
END

GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueNewspaper]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckUniqueNewspaper]
(
	@Id int = null,
	@Name nvarchar(300),
	@Publisher nvarchar(300),
	@Date date
)
RETURNS bit
AS
BEGIN
	declare @Count int;

	select @Count = Count(Catalogue.Id) from Newspapers
	inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
	where 
		Deleted <> 1 and
		[Name] = @Name and
		Publisher = @Publisher and
		[Date] = @Date and
		((@Id is not null and Catalogue.Id <> @Id) or @Id is null);

	if @Count > 0 return 0;
	
	return 1;
END

GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniquePatent]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckUniquePatent]
(
	@Id int = null,
	@Country nvarchar(200),
	@RegistrationNumber nvarchar(9),
	@AuthorIDs dbo.IDList readonly
)
RETURNS bit
AS
BEGIN
	declare @Count int;

	declare @AuthorIDsCount int;
	set @AuthorIDsCount = (select COUNT(*) from @AuthorIDs);

	select @Count = Count(Catalogue.Id) from Patents
	inner join Catalogue on Patents.CatalogueId = Catalogue.Id
	where 
		Deleted <> 1 and
		Country = @Country and 
		RegistrationNumber = @RegistrationNumber and
		((@Id is not null and Catalogue.Id <> @Id) or @Id is null) and
			((0 = @AuthorIDsCount and 0 = (select count(*) from AuthorsBooksAndPatents where Catalogue.Id = BooksId)) or 
			 Catalogue.Id in (select BooksId from AuthorsBooksAndPatents as abap1
							where (select Count(*) from AuthorsBooksAndPatents as abap2
									where abap1.BooksId = abap2.BooksId) = @AuthorIDsCount and
									exists
											(select BooksId from AuthorsBooksAndPatents as abap3
											where abap3.BooksId = abap1.BooksId and
												 abap3.AuthorId in (select Id from @AuthorIDs))));

	if @Count > 0 return 0;
	
	return 1;
END

GO
/****** Object:  Table [dbo].[Authors]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Authors](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](200) NOT NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_Authors] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AuthorsBooksAndPatents]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthorsBooksAndPatents](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AuthorId] [int] NOT NULL,
	[BooksId] [int] NULL,
	[PatentsId] [int] NULL,
 CONSTRAINT [PK_AuthorsBooksAndPatents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Books]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[Publisher] [nvarchar](300) NOT NULL,
	[PublishingCity] [nvarchar](200) NOT NULL,
	[PublishingYear] [int] NOT NULL,
	[ISBN] [nvarchar](18) NULL,
	[CatalogueId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ClusteredIndex-20210312-140122]    Script Date: 3/19/2021 2:02:16 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-140122] ON [dbo].[Books]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Catalogue]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Catalogue](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[NumberOfPages] [int] NOT NULL,
	[Annotation] [nvarchar](2000) NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_Catalogue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Logs]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NOT NULL,
	[Type] [nvarchar](20) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[Annotation] [nvarchar](2000) NOT NULL,
	[UserName] [nvarchar](300) NOT NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Newspapers]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Newspapers](
	[Publisher] [nvarchar](300) NOT NULL,
	[PublishingCity] [nvarchar](200) NOT NULL,
	[Number] [nvarchar](50) NULL,
	[Date] [date] NOT NULL,
	[ISSN] [nvarchar](14) NULL,
	[CatalogueId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ClusteredIndex-20210312-141448]    Script Date: 3/19/2021 2:02:16 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-141448] ON [dbo].[Newspapers]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Patents]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patents](
	[Country] [nvarchar](200) NOT NULL,
	[RegistrationNumber] [nvarchar](9) NOT NULL,
	[ApplicationDate] [date] NULL,
	[DateOfPublication] [date] NOT NULL,
	[CatalogueId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ClusteredIndex-20210312-141341]    Script Date: 3/19/2021 2:02:16 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-141341] ON [dbo].[Patents]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents]  WITH CHECK ADD  CONSTRAINT [FK_AuthorsBooksAndPatents_Authors] FOREIGN KEY([AuthorId])
REFERENCES [dbo].[Authors] ([Id])
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents] CHECK CONSTRAINT [FK_AuthorsBooksAndPatents_Authors]
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents]  WITH CHECK ADD  CONSTRAINT [FK_AuthorsBooksAndPatents_Books] FOREIGN KEY([BooksId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents] CHECK CONSTRAINT [FK_AuthorsBooksAndPatents_Books]
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents]  WITH CHECK ADD  CONSTRAINT [FK_AuthorsBooksAndPatents_Patents] FOREIGN KEY([PatentsId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[AuthorsBooksAndPatents] CHECK CONSTRAINT [FK_AuthorsBooksAndPatents_Patents]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD  CONSTRAINT [FK_Books_Catalogue] FOREIGN KEY([CatalogueId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[Books] CHECK CONSTRAINT [FK_Books_Catalogue]
GO
ALTER TABLE [dbo].[Newspapers]  WITH CHECK ADD  CONSTRAINT [FK_Newspapers_Catalogue] FOREIGN KEY([CatalogueId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[Newspapers] CHECK CONSTRAINT [FK_Newspapers_Catalogue]
GO
ALTER TABLE [dbo].[Patents]  WITH CHECK ADD  CONSTRAINT [FK_Patents_Catalogue] FOREIGN KEY([CatalogueId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[Patents] CHECK CONSTRAINT [FK_Patents_Catalogue]
GO
/****** Object:  StoredProcedure [dbo].[Authors_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_Add]
	@Id int output,
	@FirstName nvarchar(50),
	@LastName nvarchar(200)
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueAuthor
				@FirstName = @FirstName,
				@LastName = @LastName;

			if @Unique = 0
				set @Id = null;
			else
			begin
				Insert Authors (FirstName, LastName, Deleted)
				values (@FirstName, @LastName, 0);

				set @Id = @@IDENTITY;

				EXEC [dbo].[Logs_Add]
					@Type = N'Author',
					@ObjectId = @Id,
					@Annotation = N'Add'
			end;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_Check]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_Check]
	@AuthorIDs dbo.IDList readonly
AS
BEGIN
	SET NOCOUNT ON;

	declare @AuthorIdCount int;
	set @AuthorIdCount = (select Count(*) from @AuthorIDs);

	declare @Count int;
	select @Count = count(*) from Authors
	where Id in (select ID from @AuthorIDs)

	if @AuthorIdCount = @Count
		select cast(1 as bit) as Result;
	else 
		select cast(0 as bit) as Result;
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_GetAll]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Authors_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

	if IS_ROLEMEMBER('db_admin') = 1
	begin
		if @SortDescending = 1
			select Id, FirstName, LastName, Deleted from Authors
			order by FirstName desc, LastName desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, FirstName, LastName, Deleted from Authors
			order by FirstName asc, LastName asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
	end
	else
	begin
		if @SortDescending = 1
			select Id, FirstName, LastName, Deleted from Authors
			where Deleted = 0
			order by FirstName desc, LastName desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, FirstName, LastName, Deleted from Authors
			where Deleted = 0
			order by FirstName asc, LastName asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
	end
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_GetById]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_GetById]
	@Id int
	
AS
BEGIN
	SET NOCOUNT ON;

	if IS_ROLEMEMBER('db_admin') = 1
		SELECT top(1) Id,FirstName, LastName, Deleted FROM Library.dbo.Authors
		where Library.dbo.Authors.Id = @Id;
	else
		SELECT top(1) Id,FirstName, LastName, Deleted FROM Library.dbo.Authors
		where Library.dbo.Authors.Id = @Id and Deleted = 0;
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_Mark]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_Mark]
	@Id int,
	@Deleted bit
AS
BEGIN
	begin try
		begin tran
			update Authors set
				Deleted = @Deleted
			where Id = @Id;

			declare @Annotation nvarchar(2000);
			set @Annotation = N'Mark ' + cast(@Deleted as nvarchar(10));

			EXEC [dbo].[Logs_Add]
				@Type = N'Author',
				@ObjectId = @Id,
				@Annotation = @Annotation;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_Remove]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
				delete Authors where Id = @Id

				EXEC [dbo].[Logs_Add]
					@Type = N'Author',
					@ObjectId = @Id,
					@Annotation = N'Remove'
			end
			else 
			begin
				exec dbo.Authors_Mark
				@Id = @Id, 
				@Deleted = true
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_SearchByFirstName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_SearchByFirstName]
	@SearchLine nvarchar(50) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select Id, FirstName, LastName, Deleted from Authors
			where FirstName like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by FirstName desc, LastName desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, FirstName, LastName, Deleted from Authors
			where FirstName like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by FirstName asc, LastName asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_SearchByLastName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_SearchByLastName]
	@SearchLine nvarchar(200) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select Id, FirstName, LastName, Deleted from Authors
			where LastName like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by FirstName desc, LastName desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, FirstName, LastName, Deleted from Authors
			where LastName like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by FirstName asc, LastName asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Authors_Update]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Authors_Update]
	@Id int output,
	@FirstName nvarchar(50),
	@LastName nvarchar(200)
	
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueAuthor
				@Id = @Id,
				@FirstName = @FirstName,
				@LastName = @LastName;

			if @Unique = 0
				rollback;
			else
			begin
				update Authors set 
					FirstName = @FirstName, 
					LastName = @LastName
				where Id = @Id

				EXEC [dbo].[Logs_Add]
					@Type = N'Author',
					@ObjectId = @Id,
					@Annotation = N'Update'
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[AuthorsBooksAndPatents_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AuthorsBooksAndPatents_Add]
	@AuthorIDs dbo.IDList readonly,
	@BookId int = null,
	@PatentId int = null
AS
BEGIN
		INSERT INTO AuthorsBooksAndPatents(AuthorId, BooksId, PatentsId)
		SELECT ID, @BookId, @PatentId FROM @AuthorIDs;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Books_Add]
	@Id int output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@PublishingYear int,
	@Isbn nvarchar(18) = null,
	@AuthorIDs dbo.IDList readonly
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueBook
				@Name = @Name,
				@PublishingYear = @PublishingYear,
				@Isbn = @Isbn,
				@AuthorIDs = @AuthorIDs;

			if @Unique = 0
				set @Id = null;
			else
			begin
				insert Catalogue ([Name], NumberOfPages, Annotation, Deleted)
					values (@Name, @NumberOfPages, @Annotation, 0);

				set @Id = @@IDENTITY;

				insert Books(Publisher, PublishingCity, PublishingYear, ISBN, CatalogueId)
					values (@Publisher, @PublishingCity, @PublishingYear, @Isbn, @Id);

				EXEC [dbo].AuthorsBooksAndPatents_Add
					@AuthorIDs = @AuthorIDs,
					@BookId = @Id,
					@PatentId = null;

				EXEC [dbo].[Logs_Add]
					@Type = N'Book',
					@ObjectId = @Id,
					@Annotation = N'Add';
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Books_GetAll]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Books_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_GetByAuthorId]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Books_GetByAuthorId]
	@Id int,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			PublishingYear,
			ISBN,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1) and Catalogue.Id in (select BooksId from AuthorsBooksAndPatents where AuthorId = @Id and BooksId is not null)
		order by [Name]
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_GetById]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Books_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

		SELECT top(1) 
			Catalogue.Id as Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			PublishingYear,
			ISBN,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where Catalogue.Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[Books_Mark]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Books_Mark]
	@Id int,
	@Deleted bit
AS
BEGIN
	begin try
		begin tran
			update Catalogue set
				Deleted = @Deleted
			where Id = @Id;

			declare @Annotation nvarchar(2000);
			set @Annotation = N'Mark ' + cast(@Deleted as nvarchar(10));

			EXEC [dbo].[Logs_Add]
				@Type = N'Book',
				@ObjectId = @Id,
				@Annotation = @Annotation;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Books_Remove]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Books_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
				delete AuthorsBooksAndPatents where BooksId = @Id;

				delete Books where CatalogueId = @Id;

				delete Catalogue where Catalogue.Id = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Book',
					@ObjectId = @Id,
					@Annotation = N'Remove'
			end
			else
			begin
				exec dbo.Books_Mark
				@Id = @Id, 
				@Deleted = true
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Books_SearchByName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Books_SearchByName]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where Name like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where Name like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_SearchByPublisher]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Books_SearchByPublisher]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where Publisher like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by Publisher desc, [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				PublishingYear,
				ISBN,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Books
			inner join Catalogue on Books.CatalogueId = Catalogue.Id
			where Publisher like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by Publisher asc, [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_SearchByPublishingYear]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Books_SearchByPublishingYear]
	@SearchLine int = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

	if @SortDescending = 1
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			PublishingYear,
			ISBN,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where (PublishingYear = @SearchLine or @SearchLine is null) and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
		order by PublishingYear desc, [Name] desc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
	else
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			PublishingYear,
			ISBN,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where BooksId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Books
		inner join Catalogue on Books.CatalogueId = Catalogue.Id
		where (PublishingYear = @SearchLine or @SearchLine is null) and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
		order by PublishingYear asc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Books_Update]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Books_Update]
	@Id int output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@PublishingYear int,
	@Isbn nvarchar(18) = null,
	@AuthorIDs dbo.IDList readonly
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueBook
				@Id = @Id,
				@Name = @Name,
				@PublishingYear = @PublishingYear,
				@Isbn = @Isbn;

			if @Unique = 0
				rollback;
			else
			begin
				delete AuthorsBooksAndPatents where BooksId = @Id;

				EXEC [dbo].AuthorsBooksAndPatents_Add
					@AuthorIDs = @AuthorIDs,
					@BookId = @Id,
					@PatentId = null;

				update Catalogue set 
					[Name] = @Name,
					NumberOfPages = @NumberOfPages,
					Annotation = @Annotation
				where Id = @Id;

				update Books set
					Publisher = @Publisher,
					PublishingCity = @PublishingCity,
					PublishingYear = @PublishingYear,
					Isbn = @Isbn
				where CatalogueId = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Book',
					@ObjectId = @Id,
					@Annotation = N'Update'
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_GetAll]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Catalogue_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id
			from Catalogue
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id
			from Catalogue
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_GetByAuthorId]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Catalogue_GetByAuthorId]
	@Id int,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		SELECT 
			Books.CatalogueId as BookId,
			Patents.CatalogueId as PatentId
			FROM Catalogue
		full join Books on Catalogue.Id = Books.CatalogueId
		full join Patents on Catalogue.Id = Patents.CatalogueId
		where Catalogue.Id in (select Isnull(BooksId, PatentsId) from AuthorsBooksAndPatents where AuthorId = @Id) and 
				(Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
		order by [Name]
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_GetById]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Catalogue_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

		select top(1) 
			Books.CatalogueId as BookId, 
			Patents.CatalogueId as PatentId, 
		    Newspapers.CatalogueId as NewspaperId
		from Catalogue
		full join Books on Catalogue.Id = Books.CatalogueId
		full join Patents on Catalogue.Id = Patents.CatalogueId
		full join Newspapers on Catalogue.Id = Newspapers.CatalogueId
		where Catalogue.Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_SearchByName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Catalogue_SearchByName]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id
			from Catalogue
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id
			from Catalogue
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Logs_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Logs_Add]
	@Type nvarchar(20),
	@ObjectId int,
	@Annotation nvarchar(2000)
AS
BEGIN
	insert Logs ([Date], [Type], ObjectId, Annotation, UserName)
	values (CURRENT_TIMESTAMP, @Type, @ObjectId, @Annotation, CURRENT_USER)
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Newspapers_Add]
	@Id int = null output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@Number nvarchar(50) = null,
	@Date date,
	@Issn nvarchar(14) = null
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaper
				@Name = @Name,
				@Publisher = @Publisher,
				@Date = @Date;

			if @Unique = 0
				set @Id = null;

			insert Catalogue (Name, NumberOfPages, Annotation, Deleted)
				values (@Name, @NumberOfPages, @Annotation, 0);

			set @Id = @@IDENTITY;

			insert Newspapers(Publisher, PublishingCity, Number, [Date], ISSN, CatalogueId)
				values (@Publisher, @PublishingCity, @Number, @Date, @Issn, @id);

			EXEC [dbo].[Logs_Add]
				@Type = N'Newspaper',
				@ObjectId = @Id,
				@Annotation = N'Add'
			
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END
GO
/****** Object:  StoredProcedure [dbo].[Newspapers_GetAll]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Newspapers_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				Number,
				[Date],
				ISSN
			from Newspapers
			inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				Number,
				[Date],
				ISSN
			from Newspapers
			inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_GetById]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Newspapers_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

	if IS_ROLEMEMBER('db_admin') = 1
		SELECT top(1) 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			Number,
			[Date],
			ISSN
		FROM Newspapers
		inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
		where Catalogue.Id = @Id;
	else
		SELECT top(1) 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			Number,
			[Date],
			ISSN
		FROM Newspapers
		inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
		where Catalogue.Id = @Id and Deleted = 0;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Mark]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Newspapers_Mark]
	@Id int,
	@Deleted bit
AS
BEGIN
	begin try
		begin tran
			update Catalogue set
				Deleted = @Deleted
			where Id = @Id;

			declare @Annotation nvarchar(2000);
			set @Annotation = N'Mark ' + cast(@Deleted as nvarchar(10));

			EXEC [dbo].[Logs_Add]
				@Type = N'Newspaper',
				@ObjectId = @Id,
				@Annotation = @Annotation;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Remove]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Newspapers_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
				delete top(1) Newspapers where CatalogueId = @Id

				delete top(1) Catalogue where Id = @Id

				EXEC [dbo].[Logs_Add]
					@Type = N'Newspaper',
					@ObjectId = @Id,
					@Annotation = N'Remove'
			end
			else 
			begin
				exec dbo.Newspapers_Mark
				@Id = @Id, 
				@Deleted = true
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_SearchByName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Newspapers_SearchByName]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				Number,
				[Date],
				ISSN
			from Newspapers
			inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Publisher,
				PublishingCity,
				Number,
				[Date],
				ISSN
			from Newspapers
			inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_SearchByPublishingYear]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Newspapers_SearchByPublishingYear]
	@PublishingYear int = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

	if @SortDescending = 1
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			Number,
			[Date],
			ISSN
		FROM Newspapers
		inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
		where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1) and
				(@PublishingYear is not null and [Date] between 
					CAST(('01.01.' + Cast(@PublishingYear as nvarchar(4))) as date) and 
					CAST(('01.01.' + Cast((@PublishingYear + 1) as nvarchar(4))) as date)) or
				@PublishingYear is null
		order by [Date] desc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
	else
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Publisher,
			PublishingCity,
			Number,
			[Date],
			ISSN
		FROM Newspapers
		inner join Catalogue on Newspapers.CatalogueId = Catalogue.Id
		where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1) and
				(@PublishingYear is not null and [Date] between 
					CAST(('01.01.' + Cast(@PublishingYear as nvarchar(4))) as date) and 
					CAST(('01.01.' + Cast((@PublishingYear + 1) as nvarchar(4))) as date)) or
				@PublishingYear is null
		order by [Date] asc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Update]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Newspapers_Update]
	@Id int output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@Number nvarchar(50) = null,
	@Date date,
	@Issn nvarchar(14) = null
	
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaper
				@Id = @Id,
				@Name = @Name,
				@Publisher = @Publisher,
				@Date = @Date;

			if @Unique = 0
				rollback;
			else
			begin
				update Catalogue set 
					[Name] = @Name,
					NumberOfPages = @NumberOfPages,
					Annotation = @Annotation
				where Id = @Id;

				update Newspapers set
					Publisher = @Publisher,
					PublishingCity = @PublishingCity,
					Number = @Number,
					[Date] = @Date,
					Issn = @Issn
				where CatalogueId = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Newspaper',
					@ObjectId = @Id,
					@Annotation = N'Update'
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_Add]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Patents_Add]
	@Id int = null output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Country nvarchar(200),
	@RegistrationNumber nvarchar(9),
	@ApplicationDate date = null,
	@DateOfPublication date,
	@AuthorIDs dbo.IDList readonly
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniquePatent
				@Country = @Country,
				@RegistrationNumber = @RegistrationNumber;

			if @Unique = 0
				set @Id = null;
			else
			begin
				insert Catalogue (Name, NumberOfPages, Annotation, Deleted)
					values (@Name, @NumberOfPages, @Annotation, 0);

				set @Id = @@IDENTITY;

				insert Patents(Country, RegistrationNumber, ApplicationDate, DateOfPublication, CatalogueId)
					values (@Country, @RegistrationNumber, @ApplicationDate, @DateOfPublication, @id);

				EXEC [dbo].AuthorsBooksAndPatents_Add
					@AuthorIDs = @AuthorIDs,
					@BookId = null,
					@PatentId = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Patent',
					@ObjectId = @Id,
					@Annotation = N'Add'
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END
GO
/****** Object:  StoredProcedure [dbo].[Patents_GetAll]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Patents_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Country,
				RegistrationNumber,
				ApplicationDate,
				DateOfPublication,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Patents
			inner join Catalogue on Patents.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Country,
				RegistrationNumber,
				ApplicationDate,
				DateOfPublication,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Patents
			inner join Catalogue on Patents.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_GetByAuthorId]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Patents_GetByAuthorId]
	@Id int,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Country,
			RegistrationNumber,
			ApplicationDate,
			DateOfPublication,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Patents
		inner join Catalogue on Patents.CatalogueId = Catalogue.Id
		where Catalogue.Id in (select PatentsId from AuthorsBooksAndPatents where AuthorId = @Id and PatentsId is not null) and 
				(Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
		order by [Name]
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_GetById]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Patents_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

		SELECT top(1) 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Country,
			RegistrationNumber,
			ApplicationDate,
			DateOfPublication,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
		FROM Patents
		inner join Catalogue on Patents.CatalogueId = Catalogue.Id
		where Catalogue.Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_Mark]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Patents_Mark]
	@Id int,
	@Deleted bit
AS
BEGIN
	begin try
		begin tran
			update Catalogue set
				Deleted = @Deleted
			where Id = @Id;

			declare @Annotation nvarchar(2000);
			set @Annotation = N'Mark ' + cast(@Deleted as nvarchar(10));

			EXEC [dbo].[Logs_Add]
				@Type = N'Patent',
				@ObjectId = @Id,
				@Annotation = @Annotation;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_Remove]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Patents_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
			delete AuthorsBooksAndPatents where PatentsId = @Id;

			delete top(1) Patents where CatalogueId = @Id

			delete top(1) Catalogue where Id = @Id

			EXEC [dbo].[Logs_Add]
				@Type = N'Patent',
				@ObjectId = @Id,
				@Annotation = N'Remove'
			end
			else
			begin
				exec dbo.Patents_Mark
				@Id = @Id, 
				@Deleted = true
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_SearchByName]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Patents_SearchByName]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Country,
				RegistrationNumber,
				ApplicationDate,
				DateOfPublication,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Patents
			inner join Catalogue on Patents.CatalogueId = Catalogue.Id
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Catalogue.Id, 
				[Name],
				NumberOfPages,
				Annotation,
				Deleted,
				Country,
				RegistrationNumber,
				ApplicationDate,
				DateOfPublication,
				(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
				for json auto) as AuthorIDs
			from Patents
			inner join Catalogue on Patents.CatalogueId = Catalogue.Id
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_SearchByPublishingYear]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Patents_SearchByPublishingYear]
	@PublishingYear int = null,
	@SortDescending bit,
	@SizePage int,
	@Page int

AS
BEGIN
	SET NOCOUNT ON;

	if @SortDescending = 1
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Country,
			RegistrationNumber,
			ApplicationDate,
			DateOfPublication,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Patents
		inner join Catalogue on Patents.CatalogueId = Catalogue.Id
		where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1) and
				(@PublishingYear is not null and DateOfPublication between 
					CAST(('01.01.' + Cast(@PublishingYear as nvarchar(4))) as date) and 
					CAST(('01.01.' + Cast((@PublishingYear + 1) as nvarchar(4))) as date)) or
				@PublishingYear is null
		order by DateOfPublication desc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
	else
		SELECT 
			Catalogue.Id, 
			[Name],
			NumberOfPages,
			Annotation,
			Deleted,
			Country,
			RegistrationNumber,
			ApplicationDate,
			DateOfPublication,
			(select AuthorId from 
					(Select AuthorId from AuthorsBooksAndPatents where PatentsId = Catalogue.Id) as authors
			for json auto) as AuthorIDs
		FROM Patents
		inner join Catalogue on Patents.CatalogueId = Catalogue.Id
		where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1) and
				(@PublishingYear is not null and DateOfPublication between 
					CAST(('01.01.' + Cast(@PublishingYear as nvarchar(4))) as date) and 
					CAST(('01.01.' + Cast((@PublishingYear + 1) as nvarchar(4))) as date)) or
				@PublishingYear is null
		order by DateOfPublication asc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Patents_Update]    Script Date: 3/19/2021 2:02:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Patents_Update]
	@Id int output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Country nvarchar(200),
	@RegistrationNumber nvarchar(9),
	@ApplicationDate date = null,
	@DateOfPublication date,
	@AuthorIDs dbo.IDList readonly
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniquePatent
				@Id = @Id,
				@Country = @Country,
				@RegistrationNumber = @RegistrationNumber;

			if @Unique = 0
				rollback;
			else
			begin
				delete AuthorsBooksAndPatents where PatentsId = @Id;

				EXEC [dbo].AuthorsBooksAndPatents_Add
					@AuthorIDs = @AuthorIDs,
					@BookId = null,
					@PatentId = @Id;

				update Catalogue set 
					[Name] = @Name,
					NumberOfPages = @NumberOfPages,
					Annotation = @Annotation
				where Id = @Id;

				update Patents set
					Country = @Country,
					RegistrationNumber = @RegistrationNumber,
					ApplicationDate = @ApplicationDate,
					DateOfPublication = @DateOfPublication
				where CatalogueId = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Patent',
					@ObjectId = @Id,
					@Annotation = N'Update'
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
USE [master]
GO
ALTER DATABASE [Library] SET  READ_WRITE 
GO

USE [master]
GO
/****** Object:  Database [Library]    Script Date: 4/22/2021 8:23:29 PM ******/
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
/****** Object:  User [User]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE USER [User] FOR LOGIN [User] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Librarian]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE USER [Librarian] FOR LOGIN [Librarian] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Admin]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE USER [Admin] FOR LOGIN [Admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [db_user]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE ROLE [db_user]
GO
/****** Object:  DatabaseRole [db_librarian]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE ROLE [db_librarian]
GO
/****** Object:  DatabaseRole [db_admin]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE ROLE [db_admin]
GO
ALTER ROLE [db_user] ADD MEMBER [User]
GO
ALTER ROLE [db_librarian] ADD MEMBER [Librarian]
GO
ALTER ROLE [db_admin] ADD MEMBER [Admin]
GO
/****** Object:  UserDefinedTableType [dbo].[IDList]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE TYPE [dbo].[IDList] AS TABLE(
	[ID] [int] NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueAuthor]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueBook]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueNewspaper]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckUniqueNewspaper]
(
	@Id int = null,
	@Name nvarchar(300),
	@Issn nvarchar(14)
)
RETURNS bit
AS
BEGIN
	declare @Count int;

	if @Issn is not null
		select @Count = Count(*) from Newspapers
		where Deleted <> 1 and ISSN = @Issn;
	else
	begin
		select @Count = Count(Id) from Newspapers
		where 
			Deleted <> 1 and
			ISSN is null and 
			[Name] = @Name and
			((@Id is not null and Id <> @Id) or @Id is null);
	end

	if @Count > 0 return 0;
	
	return 1;
END

GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueNewspaperIssue]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckUniqueNewspaperIssue]
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

	select @Count = Count(Catalogue.Id) from NewspaperIssues
	inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
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
/****** Object:  UserDefinedFunction [dbo].[CheckUniquePatent]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueRole]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[CheckUniqueRole]
(	
	@Id int = null,
	@Name nvarchar(50)
)
RETURNS bit
AS
Begin
	declare @Count int;
	
	select @Count = Count(Id) from Roles
	where
		[Name] = @Name and
		((@Id is not null and Id <> @Id) or @Id is null);

	if @Count > 0 return 0;
	
	return 1;
end;

GO
/****** Object:  UserDefinedFunction [dbo].[CheckUniqueUser]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[CheckUniqueUser]
(	
	@Id int = null,
	@Login nvarchar(50)
)
RETURNS bit
AS
Begin
	declare @Count int;
	
	select @Count = Count(Id) from Users
	where
		[Login] = @Login and
		((@Id is not null and Id <> @Id) or @Id is null);

	if @Count > 0 return 0;
	
	return 1;
end;

GO
/****** Object:  Table [dbo].[Authors]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Table [dbo].[AuthorsBooksAndPatents]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Table [dbo].[Books]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Index [ClusteredIndex-20210312-140122]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-140122] ON [dbo].[Books]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Catalogue]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Table [dbo].[Logging]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logging](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[DateTime] [datetime] NOT NULL,
	[Login] [nvarchar](50) NOT NULL,
	[Layer] [nvarchar](10) NOT NULL,
	[Class] [nvarchar](500) NOT NULL,
	[Method] [nvarchar](500) NOT NULL,
	[Message] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_Logging] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Logs]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Table [dbo].[NewspaperIssues]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewspaperIssues](
	[Publisher] [nvarchar](300) NOT NULL,
	[PublishingCity] [nvarchar](200) NOT NULL,
	[Number] [int] NULL,
	[Date] [date] NOT NULL,
	[CatalogueId] [int] NOT NULL,
	[NewspaperId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [ClusteredIndex-20210312-141448]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-141448] ON [dbo].[NewspaperIssues]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Newspapers]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Newspapers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](300) NOT NULL,
	[ISSN] [nvarchar](14) NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_Newspaper] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Patents]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  Index [ClusteredIndex-20210312-141341]    Script Date: 4/22/2021 8:23:30 PM ******/
CREATE CLUSTERED INDEX [ClusteredIndex-20210312-141341] ON [dbo].[Patents]
(
	[CatalogueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Login] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](200) NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Logging] ON 

INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (15, CAST(N'2021-04-20T22:22:29.960' AS DateTime), N'(null)', N'PL', N'CatalogueController', N'Display', N'INFO: Admin: "Log1" made the transition in the current direction: /Catalogue/Display?id=1958&type=Book.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (16, CAST(N'2021-04-20T22:22:29.987' AS DateTime), N'Log3', N'PL', N'BookController', N'Display', N'INFO: Admin: "Log1" made the transition in the current direction: /Book/Display?id=1958.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (17, CAST(N'2021-04-20T22:22:33.037' AS DateTime), N'(null)', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (18, CAST(N'2021-04-20T22:24:15.987' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (19, CAST(N'2021-04-20T22:24:29.857' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'Create', N'INFO: Admin: "Log1" made the transition in the current direction: /Catalogue/Create?__RequestVerificationToken=bi0J6hFo2FcO0Uxr3JcCVUSfBsLw05GlIEiF__jS36K7Zlrf1D-_zNqnAFdO3g8Yb_inhztmsL5bQENtirN07MlFGCk_BMfpgIwV8AWP_QM1&typeRadio=Book.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (20, CAST(N'2021-04-20T22:24:29.877' AS DateTime), N'Log1', N'PL', N'BookController', N'Create', N'INFO: Admin: "Log1" made the transition in the current direction: /Book/Create.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (21, CAST(N'2021-04-20T22:24:30.350' AS DateTime), N'Log1', N'PL', N'AuthorController', N'GetList', N'INFO: Admin: "Log1" made the transition in the current direction: /Author/GetList.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (22, CAST(N'2021-04-20T22:24:33.200' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (23, CAST(N'2021-04-20T22:42:41.430' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (24, CAST(N'2021-04-20T22:42:41.437' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'ERROR: Exception of type ''System.Exception'' was thrown.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (25, CAST(N'2021-04-20T23:11:29.607' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (26, CAST(N'2021-04-20T23:59:17.333' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (27, CAST(N'2021-04-21T00:21:37.860' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (28, CAST(N'2021-04-21T00:22:45.773' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (29, CAST(N'2021-04-21T00:22:45.780' AS DateTime), N'Log1', N'Dal', N'BookDao', N'Get', N'ERROR: Error getting data. Reason: Exception of type ''System.Exception'' was thrown.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (30, CAST(N'2021-04-21T00:22:45.780' AS DateTime), N'Log1', N'Dal', N'CatalogueDao', N'Get', N'ERROR: Error getting data. Reason: Error getting data.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (31, CAST(N'2021-04-21T00:22:45.780' AS DateTime), N'Log1', N'Dal', N'CatalogueDao', N'Search', N'ERROR: Error getting data. Reason: Error getting data.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (32, CAST(N'2021-04-21T00:22:45.783' AS DateTime), N'Log1', N'Bll', N'CatalogueBll', N'Search', N'ERROR: Error getting item. Reason: Error getting data.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (33, CAST(N'2021-04-21T10:44:42.097' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (34, CAST(N'2021-04-21T22:37:09.863' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (35, CAST(N'2021-04-22T18:27:20.683' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (36, CAST(N'2021-04-22T18:27:28.977' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (37, CAST(N'2021-04-22T18:27:30.717' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (38, CAST(N'2021-04-22T18:27:58.960' AS DateTime), N'Log1', N'PL', N'CatalogueController', N'GetAll', N'INFO: Admin: "Log1" made the transition in the current direction: /.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (39, CAST(N'2021-04-22T18:28:04.280' AS DateTime), N'Log1', N'PL', N'Account', N'Logout', N'INFO: User:Log1 log out.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (40, CAST(N'2021-04-22T18:28:04.283' AS DateTime), N'Log1', N'PL', N'AccountController', N'Logout', N'INFO: Admin: "Log1" made the transition in the current direction: /Account/Logout.')
INSERT [dbo].[Logging] ([Id], [DateTime], [Login], [Layer], [Class], [Method], [Message]) VALUES (41, CAST(N'2021-04-22T18:28:16.263' AS DateTime), N'Log2', N'PL', N'Account', N'Login', N'INFO: User:Log2 log in.')
SET IDENTITY_INSERT [dbo].[Logging] OFF
SET IDENTITY_INSERT [dbo].[Logs] ON 

INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1, CAST(N'2021-03-08T23:24:40.130' AS DateTime), N'Author', 5, N'Created', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2, CAST(N'2021-03-08T23:26:18.473' AS DateTime), N'Author', 3, N'Created', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3, CAST(N'2021-03-08T23:31:00.257' AS DateTime), N'Author', 8, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (4, CAST(N'2021-03-08T23:47:20.600' AS DateTime), N'Author', 9, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5, CAST(N'2021-03-09T10:50:21.640' AS DateTime), N'Author', 5, N'Mark fdf', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6, CAST(N'2021-03-09T10:52:54.327' AS DateTime), N'Author', 5, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (10, CAST(N'2021-03-09T11:43:00.857' AS DateTime), N'Books', 1, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (11, CAST(N'2021-03-09T11:44:13.217' AS DateTime), N'Books', 2, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (12, CAST(N'2021-03-09T11:56:18.383' AS DateTime), N'Books', 2, N'Remove', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (13, CAST(N'2021-03-09T11:57:51.967' AS DateTime), N'Books', 2, N'Remove', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (14, CAST(N'2021-03-09T11:59:15.417' AS DateTime), N'Books', 3, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (15, CAST(N'2021-03-09T12:00:06.080' AS DateTime), N'Books', 3, N'Remove', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (16, CAST(N'2021-03-09T13:36:49.810' AS DateTime), N'Books', 4, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (17, CAST(N'2021-03-09T17:54:47.070' AS DateTime), N'Author', 10, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (18, CAST(N'2021-03-09T17:55:28.007' AS DateTime), N'Author', 11, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (19, CAST(N'2021-03-09T18:05:20.520' AS DateTime), N'Author', 12, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (20, CAST(N'2021-03-09T18:11:26.093' AS DateTime), N'Author', 13, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (21, CAST(N'2021-03-09T18:11:58.747' AS DateTime), N'Author', 14, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (22, CAST(N'2021-03-09T18:12:01.610' AS DateTime), N'Author', 15, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (23, CAST(N'2021-03-09T20:15:11.780' AS DateTime), N'Book', 4, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (24, CAST(N'2021-03-10T22:37:17.933' AS DateTime), N'Book', 5, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (25, CAST(N'2021-03-10T22:37:42.227' AS DateTime), N'Book', 6, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (26, CAST(N'2021-03-10T22:37:56.937' AS DateTime), N'Book', 7, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (27, CAST(N'2021-03-10T22:38:10.617' AS DateTime), N'Book', 8, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (28, CAST(N'2021-03-11T15:52:39.203' AS DateTime), N'Book', 9, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (29, CAST(N'2021-03-11T15:55:59.630' AS DateTime), N'Book', 10, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (30, CAST(N'2021-03-11T16:06:45.543' AS DateTime), N'Book', 11, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (31, CAST(N'2021-03-11T17:08:16.370' AS DateTime), N'Book', 15, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (48, CAST(N'2021-03-11T19:09:10.470' AS DateTime), N'Book', 18, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (49, CAST(N'2021-03-11T19:10:24.543' AS DateTime), N'Book', 19, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (50, CAST(N'2021-03-11T19:21:42.353' AS DateTime), N'Book', 20, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (51, CAST(N'2021-03-11T19:25:11.310' AS DateTime), N'Book', 21, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (52, CAST(N'2021-03-11T19:27:12.397' AS DateTime), N'Book', 22, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (53, CAST(N'2021-03-11T19:28:05.017' AS DateTime), N'Book', 23, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (55, CAST(N'2021-03-11T19:56:27.933' AS DateTime), N'Book', 28, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (59, CAST(N'2021-03-11T20:26:33.113' AS DateTime), N'Book', 40, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (60, CAST(N'2021-03-11T20:36:33.367' AS DateTime), N'Book', 41, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (61, CAST(N'2021-03-11T20:45:47.243' AS DateTime), N'Book', 43, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (62, CAST(N'2021-03-11T21:43:50.627' AS DateTime), N'Book', 44, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (63, CAST(N'2021-03-12T14:11:04.617' AS DateTime), N'Book', 45, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (64, CAST(N'2021-03-12T17:08:16.960' AS DateTime), N'Book', 40, N'Remove', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (65, CAST(N'2021-03-12T20:41:32.083' AS DateTime), N'Book', 46, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (66, CAST(N'2021-03-12T20:44:19.830' AS DateTime), N'Book', 47, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (67, CAST(N'2021-03-12T20:45:22.263' AS DateTime), N'Book', 48, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (71, CAST(N'2021-03-15T13:52:48.757' AS DateTime), N'Book', 43, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (72, CAST(N'2021-03-15T13:54:41.607' AS DateTime), N'Book', 43, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (73, CAST(N'2021-03-15T13:55:23.667' AS DateTime), N'Book', 49, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (74, CAST(N'2021-03-15T13:59:00.087' AS DateTime), N'Book', 43, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (75, CAST(N'2021-03-16T15:45:03.340' AS DateTime), N'Author', 16, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (76, CAST(N'2021-03-16T23:41:30.150' AS DateTime), N'Book', 7, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (77, CAST(N'2021-03-17T12:41:11.747' AS DateTime), N'Author', 8, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (78, CAST(N'2021-03-17T12:42:12.547' AS DateTime), N'Author', 8, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (79, CAST(N'2021-03-17T13:17:48.917' AS DateTime), N'Patent', 50, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (80, CAST(N'2021-03-17T13:21:59.513' AS DateTime), N'Patent', 51, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (81, CAST(N'2021-03-17T14:44:32.407' AS DateTime), N'Patent', 50, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (82, CAST(N'2021-03-17T15:39:29.163' AS DateTime), N'Newspaper', 52, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (83, CAST(N'2021-03-17T15:40:24.647' AS DateTime), N'Newspaper', 53, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (84, CAST(N'2021-03-17T15:45:06.793' AS DateTime), N'Newspaper', 52, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (85, CAST(N'2021-03-17T16:28:13.120' AS DateTime), N'Newspaper', 53, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (86, CAST(N'2021-03-17T16:28:57.820' AS DateTime), N'Newspaper', 53, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (87, CAST(N'2021-03-17T16:31:47.873' AS DateTime), N'Patent', 51, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (92, CAST(N'2021-03-17T16:44:15.623' AS DateTime), N'Author', 9, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (93, CAST(N'2021-03-18T00:13:43.190' AS DateTime), N'Book', 4, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (94, CAST(N'2021-03-18T13:46:47.113' AS DateTime), N'Author', 17, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (95, CAST(N'2021-03-18T13:46:47.187' AS DateTime), N'Author', 18, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (96, CAST(N'2021-03-18T13:46:47.187' AS DateTime), N'Author', 19, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (97, CAST(N'2021-03-18T13:46:47.187' AS DateTime), N'Author', 20, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (98, CAST(N'2021-03-18T13:46:47.190' AS DateTime), N'Author', 21, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (99, CAST(N'2021-03-18T13:46:47.203' AS DateTime), N'Author', 22, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (100, CAST(N'2021-03-18T13:46:47.227' AS DateTime), N'Patent', 54, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (101, CAST(N'2021-03-18T13:46:47.370' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (102, CAST(N'2021-03-18T13:46:47.420' AS DateTime), N'Author', 23, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (103, CAST(N'2021-03-18T13:46:47.420' AS DateTime), N'Author', 23, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (104, CAST(N'2021-03-18T13:46:47.423' AS DateTime), N'Author', 24, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (105, CAST(N'2021-03-18T13:46:47.427' AS DateTime), N'Author', 25, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (106, CAST(N'2021-03-18T13:46:47.427' AS DateTime), N'Author', 26, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (107, CAST(N'2021-03-18T13:46:47.430' AS DateTime), N'Author', 27, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (108, CAST(N'2021-03-18T13:46:47.443' AS DateTime), N'Patent', 54, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (109, CAST(N'2021-03-18T13:46:47.447' AS DateTime), N'Author', 17, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (110, CAST(N'2021-03-18T13:46:47.447' AS DateTime), N'Author', 18, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (111, CAST(N'2021-03-18T13:46:47.447' AS DateTime), N'Author', 19, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (112, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 20, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (113, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 21, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (114, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 22, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (115, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 24, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (116, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 25, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (117, CAST(N'2021-03-18T13:46:47.450' AS DateTime), N'Author', 26, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (118, CAST(N'2021-03-18T13:46:47.453' AS DateTime), N'Author', 27, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (119, CAST(N'2021-03-18T13:46:47.497' AS DateTime), N'Book', 55, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (120, CAST(N'2021-03-18T13:46:47.507' AS DateTime), N'Book', 56, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (121, CAST(N'2021-03-18T13:46:47.510' AS DateTime), N'Book', 57, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (122, CAST(N'2021-03-18T13:46:47.513' AS DateTime), N'Book', 58, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (123, CAST(N'2021-03-18T13:46:47.517' AS DateTime), N'Book', 59, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (124, CAST(N'2021-03-18T13:46:47.520' AS DateTime), N'Author', 28, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (125, CAST(N'2021-03-18T13:46:47.540' AS DateTime), N'Author', 29, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (126, CAST(N'2021-03-18T13:46:47.540' AS DateTime), N'Book', 60, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (127, CAST(N'2021-03-18T13:46:47.550' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (128, CAST(N'2021-03-18T13:46:47.553' AS DateTime), N'Book', 61, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (129, CAST(N'2021-03-18T13:46:47.557' AS DateTime), N'Book', 62, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (130, CAST(N'2021-03-18T13:46:47.560' AS DateTime), N'Book', 63, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (131, CAST(N'2021-03-18T13:46:47.563' AS DateTime), N'Book', 64, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (132, CAST(N'2021-03-18T13:46:47.580' AS DateTime), N'Book', 65, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (133, CAST(N'2021-03-18T13:46:47.590' AS DateTime), N'Author', 28, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (134, CAST(N'2021-03-18T13:46:47.603' AS DateTime), N'Newspaper', 66, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (135, CAST(N'2021-03-18T13:46:47.607' AS DateTime), N'Newspaper', 67, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (136, CAST(N'2021-03-18T13:46:47.610' AS DateTime), N'Newspaper', 68, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (137, CAST(N'2021-03-18T13:46:47.617' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (138, CAST(N'2021-03-18T13:46:47.620' AS DateTime), N'Newspaper', 69, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (139, CAST(N'2021-03-18T13:46:47.620' AS DateTime), N'Newspaper', 70, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (140, CAST(N'2021-03-18T13:46:47.623' AS DateTime), N'Newspaper', 71, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (141, CAST(N'2021-03-18T13:46:47.623' AS DateTime), N'Newspaper', 72, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (142, CAST(N'2021-03-18T13:46:47.647' AS DateTime), N'Patent', 73, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (143, CAST(N'2021-03-18T13:46:47.650' AS DateTime), N'Patent', 74, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (144, CAST(N'2021-03-18T13:46:47.657' AS DateTime), N'Patent', 75, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (145, CAST(N'2021-03-18T13:46:47.660' AS DateTime), N'Patent', 76, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (146, CAST(N'2021-03-18T13:46:47.680' AS DateTime), N'Patent', 77, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (147, CAST(N'2021-03-18T13:46:47.693' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (148, CAST(N'2021-03-18T13:46:47.700' AS DateTime), N'Patent', 78, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (149, CAST(N'2021-03-18T13:46:47.700' AS DateTime), N'Patent', 78, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (150, CAST(N'2021-03-18T13:46:47.707' AS DateTime), N'Patent', 79, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (151, CAST(N'2021-03-18T13:46:47.710' AS DateTime), N'Patent', 80, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (152, CAST(N'2021-03-18T13:46:47.713' AS DateTime), N'Patent', 81, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (153, CAST(N'2021-03-18T13:46:47.723' AS DateTime), N'Patent', 73, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (154, CAST(N'2021-03-18T13:46:47.723' AS DateTime), N'Patent', 74, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (155, CAST(N'2021-03-18T13:46:47.723' AS DateTime), N'Patent', 75, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (156, CAST(N'2021-03-18T13:46:47.723' AS DateTime), N'Patent', 76, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (157, CAST(N'2021-03-18T13:46:47.723' AS DateTime), N'Patent', 77, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (158, CAST(N'2021-03-18T13:46:47.727' AS DateTime), N'Patent', 79, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (159, CAST(N'2021-03-18T13:46:47.727' AS DateTime), N'Patent', 80, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (160, CAST(N'2021-03-18T13:46:47.727' AS DateTime), N'Patent', 81, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (161, CAST(N'2021-03-18T13:46:47.753' AS DateTime), N'Book', 82, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (162, CAST(N'2021-03-18T13:46:47.773' AS DateTime), N'Author', 30, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (163, CAST(N'2021-03-18T13:46:47.780' AS DateTime), N'Patent', 83, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (164, CAST(N'2021-03-18T13:46:47.797' AS DateTime), N'Author', 31, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (165, CAST(N'2021-03-18T13:46:47.800' AS DateTime), N'Book', 84, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (166, CAST(N'2021-03-18T13:46:47.880' AS DateTime), N'Patent', 83, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (167, CAST(N'2021-03-18T13:46:47.883' AS DateTime), N'Author', 30, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (168, CAST(N'2021-03-18T13:52:00.617' AS DateTime), N'Author', 32, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (169, CAST(N'2021-03-18T13:52:00.700' AS DateTime), N'Author', 33, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (170, CAST(N'2021-03-18T13:52:00.703' AS DateTime), N'Author', 34, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (171, CAST(N'2021-03-18T13:52:00.703' AS DateTime), N'Author', 35, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (172, CAST(N'2021-03-18T13:52:00.707' AS DateTime), N'Author', 36, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (173, CAST(N'2021-03-18T13:52:00.717' AS DateTime), N'Author', 37, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (174, CAST(N'2021-03-18T13:52:00.733' AS DateTime), N'Patent', 85, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (175, CAST(N'2021-03-18T13:52:00.857' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (176, CAST(N'2021-03-18T13:52:00.903' AS DateTime), N'Author', 38, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (177, CAST(N'2021-03-18T13:52:00.920' AS DateTime), N'Author', 38, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (178, CAST(N'2021-03-18T13:52:00.927' AS DateTime), N'Author', 39, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (179, CAST(N'2021-03-18T13:52:00.933' AS DateTime), N'Author', 40, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (180, CAST(N'2021-03-18T13:52:00.940' AS DateTime), N'Author', 41, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (181, CAST(N'2021-03-18T13:52:00.943' AS DateTime), N'Author', 42, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (182, CAST(N'2021-03-18T13:52:00.957' AS DateTime), N'Patent', 85, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (183, CAST(N'2021-03-18T13:52:00.963' AS DateTime), N'Author', 32, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (184, CAST(N'2021-03-18T13:52:00.967' AS DateTime), N'Author', 33, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (185, CAST(N'2021-03-18T13:52:00.967' AS DateTime), N'Author', 34, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (186, CAST(N'2021-03-18T13:52:00.970' AS DateTime), N'Author', 35, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (187, CAST(N'2021-03-18T13:52:00.970' AS DateTime), N'Author', 36, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (188, CAST(N'2021-03-18T13:52:00.973' AS DateTime), N'Author', 37, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (189, CAST(N'2021-03-18T13:52:00.973' AS DateTime), N'Author', 39, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (190, CAST(N'2021-03-18T13:52:00.977' AS DateTime), N'Author', 40, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (191, CAST(N'2021-03-18T13:52:00.977' AS DateTime), N'Author', 41, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (192, CAST(N'2021-03-18T13:52:00.977' AS DateTime), N'Author', 42, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (193, CAST(N'2021-03-18T13:52:01.000' AS DateTime), N'Book', 86, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (194, CAST(N'2021-03-18T13:52:01.013' AS DateTime), N'Book', 87, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (195, CAST(N'2021-03-18T13:52:01.030' AS DateTime), N'Book', 88, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (196, CAST(N'2021-03-18T13:52:01.050' AS DateTime), N'Book', 89, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (197, CAST(N'2021-03-18T13:52:01.073' AS DateTime), N'Book', 90, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (198, CAST(N'2021-03-18T13:52:01.087' AS DateTime), N'Author', 43, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (199, CAST(N'2021-03-18T13:52:01.103' AS DateTime), N'Author', 44, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (200, CAST(N'2021-03-18T13:52:01.120' AS DateTime), N'Book', 91, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (201, CAST(N'2021-03-18T13:52:01.140' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (202, CAST(N'2021-03-18T13:52:01.163' AS DateTime), N'Book', 92, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (203, CAST(N'2021-03-18T13:52:01.183' AS DateTime), N'Book', 93, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (204, CAST(N'2021-03-18T13:52:01.197' AS DateTime), N'Book', 94, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (205, CAST(N'2021-03-18T13:52:01.200' AS DateTime), N'Book', 95, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (206, CAST(N'2021-03-18T13:52:01.210' AS DateTime), N'Book', 96, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (207, CAST(N'2021-03-18T13:52:01.227' AS DateTime), N'Author', 43, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (208, CAST(N'2021-03-18T13:52:01.240' AS DateTime), N'Newspaper', 97, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (209, CAST(N'2021-03-18T13:52:01.247' AS DateTime), N'Newspaper', 98, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (210, CAST(N'2021-03-18T13:52:01.253' AS DateTime), N'Newspaper', 99, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (211, CAST(N'2021-03-18T13:52:01.260' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (212, CAST(N'2021-03-18T13:52:01.263' AS DateTime), N'Newspaper', 100, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (213, CAST(N'2021-03-18T13:52:01.263' AS DateTime), N'Newspaper', 101, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (214, CAST(N'2021-03-18T13:52:01.267' AS DateTime), N'Newspaper', 102, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (215, CAST(N'2021-03-18T13:52:01.267' AS DateTime), N'Newspaper', 103, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (216, CAST(N'2021-03-18T13:52:01.320' AS DateTime), N'Patent', 104, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (217, CAST(N'2021-03-18T13:52:01.343' AS DateTime), N'Patent', 105, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (218, CAST(N'2021-03-18T13:52:01.370' AS DateTime), N'Patent', 106, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (219, CAST(N'2021-03-18T13:52:01.393' AS DateTime), N'Patent', 107, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (220, CAST(N'2021-03-18T13:52:01.443' AS DateTime), N'Patent', 108, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (221, CAST(N'2021-03-18T13:52:01.467' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (222, CAST(N'2021-03-18T13:52:01.470' AS DateTime), N'Patent', 109, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (223, CAST(N'2021-03-18T13:52:01.473' AS DateTime), N'Patent', 109, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (224, CAST(N'2021-03-18T13:52:01.477' AS DateTime), N'Patent', 110, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (225, CAST(N'2021-03-18T13:52:01.480' AS DateTime), N'Patent', 111, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (226, CAST(N'2021-03-18T13:52:01.483' AS DateTime), N'Patent', 112, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (227, CAST(N'2021-03-18T13:52:01.493' AS DateTime), N'Patent', 104, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (228, CAST(N'2021-03-18T13:52:01.493' AS DateTime), N'Patent', 105, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (229, CAST(N'2021-03-18T13:52:01.493' AS DateTime), N'Patent', 106, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (230, CAST(N'2021-03-18T13:52:01.497' AS DateTime), N'Patent', 107, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (231, CAST(N'2021-03-18T13:52:01.497' AS DateTime), N'Patent', 108, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (232, CAST(N'2021-03-18T13:52:01.497' AS DateTime), N'Patent', 110, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (233, CAST(N'2021-03-18T13:52:01.497' AS DateTime), N'Patent', 111, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (234, CAST(N'2021-03-18T13:52:01.497' AS DateTime), N'Patent', 112, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (235, CAST(N'2021-03-18T13:52:01.643' AS DateTime), N'Book', 113, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (236, CAST(N'2021-03-18T13:52:01.660' AS DateTime), N'Author', 45, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (237, CAST(N'2021-03-18T13:52:01.673' AS DateTime), N'Patent', 114, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (238, CAST(N'2021-03-18T13:52:01.693' AS DateTime), N'Author', 46, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (239, CAST(N'2021-03-18T13:52:01.693' AS DateTime), N'Book', 115, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (240, CAST(N'2021-03-18T13:52:01.743' AS DateTime), N'Patent', 114, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (241, CAST(N'2021-03-18T13:52:01.747' AS DateTime), N'Author', 45, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (242, CAST(N'2021-03-18T14:03:43.047' AS DateTime), N'Book', 116, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (243, CAST(N'2021-03-18T14:07:04.080' AS DateTime), N'Book', 117, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (244, CAST(N'2021-03-18T14:19:32.120' AS DateTime), N'Book', 118, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (245, CAST(N'2021-03-18T19:31:31.647' AS DateTime), N'Newspaper', 119, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (246, CAST(N'2021-03-18T19:38:41.973' AS DateTime), N'Newspaper', 120, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (247, CAST(N'2021-03-18T19:41:22.520' AS DateTime), N'Newspaper', 121, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (248, CAST(N'2021-03-18T19:47:37.567' AS DateTime), N'Newspaper', 122, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (249, CAST(N'2021-03-18T19:49:08.070' AS DateTime), N'Newspaper', 123, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (250, CAST(N'2021-03-18T19:50:06.833' AS DateTime), N'Newspaper', 124, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (251, CAST(N'2021-03-18T19:50:22.360' AS DateTime), N'Newspaper', 125, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (252, CAST(N'2021-03-18T19:50:31.637' AS DateTime), N'Newspaper', 126, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (253, CAST(N'2021-03-18T19:52:28.843' AS DateTime), N'Newspaper', 127, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (254, CAST(N'2021-03-18T19:52:28.923' AS DateTime), N'Newspaper', 127, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (255, CAST(N'2021-03-18T19:52:45.250' AS DateTime), N'Newspaper', 128, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (256, CAST(N'2021-03-18T19:52:45.330' AS DateTime), N'Newspaper', 128, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (257, CAST(N'2021-03-18T19:53:01.000' AS DateTime), N'Newspaper', 129, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (258, CAST(N'2021-03-18T19:53:01.017' AS DateTime), N'Newspaper', 130, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (259, CAST(N'2021-03-18T19:53:01.027' AS DateTime), N'Newspaper', 131, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (260, CAST(N'2021-03-18T19:53:01.027' AS DateTime), N'Newspaper', 132, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (261, CAST(N'2021-03-18T19:53:01.037' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (262, CAST(N'2021-03-18T19:53:01.090' AS DateTime), N'Newspaper', 133, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (263, CAST(N'2021-03-18T19:53:01.090' AS DateTime), N'Newspaper', 133, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (264, CAST(N'2021-03-18T19:53:01.093' AS DateTime), N'Newspaper', 134, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (265, CAST(N'2021-03-18T19:53:01.093' AS DateTime), N'Newspaper', 135, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (266, CAST(N'2021-03-18T19:53:01.097' AS DateTime), N'Newspaper', 136, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (267, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 129, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (268, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 130, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (269, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 131, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (270, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 132, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (271, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 134, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (272, CAST(N'2021-03-18T19:53:01.110' AS DateTime), N'Newspaper', 135, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (273, CAST(N'2021-03-18T19:53:01.113' AS DateTime), N'Newspaper', 136, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (274, CAST(N'2021-03-18T19:53:31.993' AS DateTime), N'Newspaper', 137, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (275, CAST(N'2021-03-18T19:53:32.010' AS DateTime), N'Newspaper', 138, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (276, CAST(N'2021-03-18T19:53:32.020' AS DateTime), N'Newspaper', 139, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (277, CAST(N'2021-03-18T19:53:32.020' AS DateTime), N'Newspaper', 140, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (278, CAST(N'2021-03-18T19:53:32.030' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (279, CAST(N'2021-03-18T19:53:32.070' AS DateTime), N'Newspaper', 141, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (280, CAST(N'2021-03-18T19:53:32.073' AS DateTime), N'Newspaper', 141, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (281, CAST(N'2021-03-18T19:53:32.073' AS DateTime), N'Newspaper', 142, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (282, CAST(N'2021-03-18T19:53:32.077' AS DateTime), N'Newspaper', 143, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (283, CAST(N'2021-03-18T19:53:32.080' AS DateTime), N'Newspaper', 144, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (284, CAST(N'2021-03-18T19:53:32.083' AS DateTime), N'Newspaper', 137, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (285, CAST(N'2021-03-18T19:53:32.087' AS DateTime), N'Newspaper', 138, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (286, CAST(N'2021-03-18T19:53:32.087' AS DateTime), N'Newspaper', 139, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (287, CAST(N'2021-03-18T19:53:32.090' AS DateTime), N'Newspaper', 140, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (288, CAST(N'2021-03-18T19:53:32.090' AS DateTime), N'Newspaper', 142, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (289, CAST(N'2021-03-18T19:53:32.093' AS DateTime), N'Newspaper', 143, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (290, CAST(N'2021-03-18T19:53:32.093' AS DateTime), N'Newspaper', 144, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (291, CAST(N'2021-03-18T21:13:12.857' AS DateTime), N'Newspaper', 145, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (292, CAST(N'2021-03-18T21:13:12.877' AS DateTime), N'Newspaper', 146, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (293, CAST(N'2021-03-18T21:13:12.887' AS DateTime), N'Newspaper', 147, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (294, CAST(N'2021-03-18T21:13:12.890' AS DateTime), N'Newspaper', 148, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (295, CAST(N'2021-03-18T21:13:12.900' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (296, CAST(N'2021-03-18T21:13:12.937' AS DateTime), N'Newspaper', 149, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (297, CAST(N'2021-03-18T21:13:12.937' AS DateTime), N'Newspaper', 149, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (298, CAST(N'2021-03-18T21:13:12.940' AS DateTime), N'Newspaper', 150, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (299, CAST(N'2021-03-18T21:13:12.940' AS DateTime), N'Newspaper', 151, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (300, CAST(N'2021-03-18T21:13:12.943' AS DateTime), N'Newspaper', 152, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (301, CAST(N'2021-03-18T21:13:12.953' AS DateTime), N'Newspaper', 145, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (302, CAST(N'2021-03-18T21:13:12.953' AS DateTime), N'Newspaper', 146, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (303, CAST(N'2021-03-18T21:13:12.953' AS DateTime), N'Newspaper', 147, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (304, CAST(N'2021-03-18T21:13:12.953' AS DateTime), N'Newspaper', 148, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (305, CAST(N'2021-03-18T21:13:12.957' AS DateTime), N'Newspaper', 150, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (306, CAST(N'2021-03-18T21:13:12.957' AS DateTime), N'Newspaper', 151, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (307, CAST(N'2021-03-18T21:13:12.957' AS DateTime), N'Newspaper', 152, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (308, CAST(N'2021-03-18T21:19:16.133' AS DateTime), N'Author', 47, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (309, CAST(N'2021-03-18T21:19:16.240' AS DateTime), N'Author', 47, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (310, CAST(N'2021-03-18T21:19:23.893' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (311, CAST(N'2021-03-18T21:19:35.973' AS DateTime), N'Patent', 153, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (312, CAST(N'2021-03-18T21:19:36.013' AS DateTime), N'Patent', 154, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (313, CAST(N'2021-03-18T21:19:36.030' AS DateTime), N'Patent', 155, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (314, CAST(N'2021-03-18T21:19:36.033' AS DateTime), N'Patent', 156, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (315, CAST(N'2021-03-18T21:19:36.077' AS DateTime), N'Author', 48, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (316, CAST(N'2021-03-18T21:19:36.100' AS DateTime), N'Patent', 157, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (317, CAST(N'2021-03-18T21:19:36.207' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (318, CAST(N'2021-03-18T21:19:36.230' AS DateTime), N'Patent', 158, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (319, CAST(N'2021-03-18T21:19:36.230' AS DateTime), N'Patent', 158, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (320, CAST(N'2021-03-18T21:19:36.237' AS DateTime), N'Patent', 159, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (321, CAST(N'2021-03-18T21:19:36.240' AS DateTime), N'Patent', 160, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (322, CAST(N'2021-03-18T21:19:36.243' AS DateTime), N'Patent', 161, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (323, CAST(N'2021-03-18T21:19:36.250' AS DateTime), N'Patent', 153, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (324, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 154, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (325, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 155, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (326, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 156, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (327, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 157, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (328, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 159, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (329, CAST(N'2021-03-18T21:19:36.253' AS DateTime), N'Patent', 160, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (330, CAST(N'2021-03-18T21:19:36.257' AS DateTime), N'Patent', 161, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (331, CAST(N'2021-03-18T21:19:36.267' AS DateTime), N'Author', 48, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (332, CAST(N'2021-03-18T21:19:56.747' AS DateTime), N'Patent', 162, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (333, CAST(N'2021-03-18T21:19:56.780' AS DateTime), N'Patent', 163, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (334, CAST(N'2021-03-18T21:19:56.797' AS DateTime), N'Patent', 164, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (335, CAST(N'2021-03-18T21:19:56.800' AS DateTime), N'Patent', 165, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (336, CAST(N'2021-03-18T21:19:56.843' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (337, CAST(N'2021-03-18T21:19:56.863' AS DateTime), N'Patent', 166, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (338, CAST(N'2021-03-18T21:19:56.863' AS DateTime), N'Patent', 166, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (339, CAST(N'2021-03-18T21:19:56.867' AS DateTime), N'Patent', 167, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (340, CAST(N'2021-03-18T21:19:56.870' AS DateTime), N'Patent', 168, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (341, CAST(N'2021-03-18T21:19:56.873' AS DateTime), N'Patent', 169, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (342, CAST(N'2021-03-18T21:19:56.877' AS DateTime), N'Patent', 162, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (343, CAST(N'2021-03-18T21:19:56.877' AS DateTime), N'Patent', 163, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (344, CAST(N'2021-03-18T21:19:56.880' AS DateTime), N'Patent', 164, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (345, CAST(N'2021-03-18T21:19:56.880' AS DateTime), N'Patent', 165, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (346, CAST(N'2021-03-18T21:19:56.880' AS DateTime), N'Patent', 167, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (347, CAST(N'2021-03-18T21:19:56.880' AS DateTime), N'Patent', 168, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (348, CAST(N'2021-03-18T21:19:56.880' AS DateTime), N'Patent', 169, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (349, CAST(N'2021-03-18T21:20:33.643' AS DateTime), N'Author', 49, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (350, CAST(N'2021-03-18T21:20:33.727' AS DateTime), N'Author', 50, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (351, CAST(N'2021-03-18T21:20:33.810' AS DateTime), N'Patent', 170, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (352, CAST(N'2021-03-18T21:20:33.920' AS DateTime), N'Patent', 170, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (353, CAST(N'2021-03-18T21:20:33.930' AS DateTime), N'Author', 49, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (354, CAST(N'2021-03-18T21:20:33.930' AS DateTime), N'Author', 50, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (355, CAST(N'2021-03-18T21:22:36.040' AS DateTime), N'Author', 51, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (356, CAST(N'2021-03-18T21:22:36.130' AS DateTime), N'Author', 52, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (357, CAST(N'2021-03-18T21:22:36.200' AS DateTime), N'Patent', 171, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (358, CAST(N'2021-03-18T21:22:36.323' AS DateTime), N'Patent', 171, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (359, CAST(N'2021-03-18T21:22:36.337' AS DateTime), N'Author', 51, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (360, CAST(N'2021-03-18T21:22:36.347' AS DateTime), N'Author', 52, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (361, CAST(N'2021-03-18T21:26:39.450' AS DateTime), N'Author', 53, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (362, CAST(N'2021-03-18T21:26:39.527' AS DateTime), N'Author', 54, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (363, CAST(N'2021-03-18T21:26:39.613' AS DateTime), N'Patent', 172, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (364, CAST(N'2021-03-18T21:26:39.723' AS DateTime), N'Patent', 172, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (365, CAST(N'2021-03-18T21:26:39.737' AS DateTime), N'Author', 53, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (366, CAST(N'2021-03-18T21:26:39.737' AS DateTime), N'Author', 54, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (367, CAST(N'2021-03-18T21:31:07.293' AS DateTime), N'Patent', 173, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (368, CAST(N'2021-03-18T21:31:57.367' AS DateTime), N'Patent', 174, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (369, CAST(N'2021-03-18T21:32:48.060' AS DateTime), N'Patent', 174, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (370, CAST(N'2021-03-18T21:32:48.080' AS DateTime), N'Patent', 175, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (371, CAST(N'2021-03-18T21:33:02.337' AS DateTime), N'Patent', 174, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (372, CAST(N'2021-03-18T21:33:15.747' AS DateTime), N'Patent', 175, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (373, CAST(N'2021-03-18T21:33:15.753' AS DateTime), N'Patent', 176, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (374, CAST(N'2021-03-18T21:37:21.430' AS DateTime), N'Author', 55, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (375, CAST(N'2021-03-18T21:37:21.507' AS DateTime), N'Author', 56, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (376, CAST(N'2021-03-18T21:37:21.577' AS DateTime), N'Patent', 177, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (377, CAST(N'2021-03-18T21:37:21.687' AS DateTime), N'Patent', 177, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (378, CAST(N'2021-03-18T21:37:21.700' AS DateTime), N'Author', 55, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (379, CAST(N'2021-03-18T21:37:21.700' AS DateTime), N'Author', 56, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (380, CAST(N'2021-03-18T21:37:26.800' AS DateTime), N'Author', 57, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (381, CAST(N'2021-03-18T21:37:26.867' AS DateTime), N'Author', 58, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (382, CAST(N'2021-03-18T21:37:26.930' AS DateTime), N'Patent', 178, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (383, CAST(N'2021-03-18T21:37:26.943' AS DateTime), N'Patent', 178, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (384, CAST(N'2021-03-18T21:37:26.947' AS DateTime), N'Author', 57, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (385, CAST(N'2021-03-18T21:37:26.947' AS DateTime), N'Author', 58, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (386, CAST(N'2021-03-18T21:37:33.297' AS DateTime), N'Patent', 179, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (387, CAST(N'2021-03-18T21:37:33.323' AS DateTime), N'Patent', 180, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (388, CAST(N'2021-03-18T21:37:33.337' AS DateTime), N'Patent', 181, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (389, CAST(N'2021-03-18T21:37:33.340' AS DateTime), N'Patent', 182, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (390, CAST(N'2021-03-18T21:37:33.357' AS DateTime), N'Author', 59, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (391, CAST(N'2021-03-18T21:37:33.360' AS DateTime), N'Author', 60, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (392, CAST(N'2021-03-18T21:37:33.387' AS DateTime), N'Patent', 183, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (393, CAST(N'2021-03-18T21:37:33.393' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (394, CAST(N'2021-03-18T21:37:33.440' AS DateTime), N'Patent', 184, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (395, CAST(N'2021-03-18T21:37:33.440' AS DateTime), N'Patent', 184, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (396, CAST(N'2021-03-18T21:37:33.443' AS DateTime), N'Patent', 185, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (397, CAST(N'2021-03-18T21:37:33.447' AS DateTime), N'Patent', 186, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (398, CAST(N'2021-03-18T21:37:33.450' AS DateTime), N'Patent', 187, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (399, CAST(N'2021-03-18T21:37:33.460' AS DateTime), N'Patent', 179, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (400, CAST(N'2021-03-18T21:37:33.460' AS DateTime), N'Patent', 180, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (401, CAST(N'2021-03-18T21:37:33.460' AS DateTime), N'Patent', 181, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (402, CAST(N'2021-03-18T21:37:33.460' AS DateTime), N'Patent', 182, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (403, CAST(N'2021-03-18T21:37:33.460' AS DateTime), N'Patent', 183, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (404, CAST(N'2021-03-18T21:37:33.463' AS DateTime), N'Patent', 185, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (405, CAST(N'2021-03-18T21:37:33.463' AS DateTime), N'Patent', 186, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (406, CAST(N'2021-03-18T21:37:33.463' AS DateTime), N'Patent', 187, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (407, CAST(N'2021-03-18T21:37:33.467' AS DateTime), N'Author', 59, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (408, CAST(N'2021-03-18T21:37:33.467' AS DateTime), N'Author', 60, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (409, CAST(N'2021-03-18T21:38:10.823' AS DateTime), N'Author', 61, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (410, CAST(N'2021-03-18T21:38:10.890' AS DateTime), N'Author', 62, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (411, CAST(N'2021-03-18T21:38:10.893' AS DateTime), N'Author', 63, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (412, CAST(N'2021-03-18T21:38:10.893' AS DateTime), N'Author', 64, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (413, CAST(N'2021-03-18T21:38:10.897' AS DateTime), N'Author', 65, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (414, CAST(N'2021-03-18T21:38:10.907' AS DateTime), N'Author', 66, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (415, CAST(N'2021-03-18T21:38:10.923' AS DateTime), N'Patent', 188, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (416, CAST(N'2021-03-18T21:38:11.030' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (417, CAST(N'2021-03-18T21:38:11.083' AS DateTime), N'Author', 67, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (418, CAST(N'2021-03-18T21:38:11.087' AS DateTime), N'Author', 67, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (419, CAST(N'2021-03-18T21:38:11.090' AS DateTime), N'Author', 68, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (420, CAST(N'2021-03-18T21:38:11.090' AS DateTime), N'Author', 69, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (421, CAST(N'2021-03-18T21:38:11.093' AS DateTime), N'Author', 70, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (422, CAST(N'2021-03-18T21:38:11.097' AS DateTime), N'Author', 71, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (423, CAST(N'2021-03-18T21:38:11.107' AS DateTime), N'Patent', 188, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (424, CAST(N'2021-03-18T21:38:11.110' AS DateTime), N'Author', 61, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (425, CAST(N'2021-03-18T21:38:11.110' AS DateTime), N'Author', 62, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (426, CAST(N'2021-03-18T21:38:11.110' AS DateTime), N'Author', 63, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (427, CAST(N'2021-03-18T21:38:11.110' AS DateTime), N'Author', 64, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (428, CAST(N'2021-03-18T21:38:11.110' AS DateTime), N'Author', 65, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (429, CAST(N'2021-03-18T21:38:11.113' AS DateTime), N'Author', 66, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (430, CAST(N'2021-03-18T21:38:11.113' AS DateTime), N'Author', 68, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (431, CAST(N'2021-03-18T21:38:11.113' AS DateTime), N'Author', 69, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (432, CAST(N'2021-03-18T21:38:11.113' AS DateTime), N'Author', 70, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (433, CAST(N'2021-03-18T21:38:11.117' AS DateTime), N'Author', 71, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (434, CAST(N'2021-03-18T21:38:11.140' AS DateTime), N'Book', 189, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (435, CAST(N'2021-03-18T21:38:11.153' AS DateTime), N'Book', 190, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (436, CAST(N'2021-03-18T21:38:11.160' AS DateTime), N'Book', 191, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (437, CAST(N'2021-03-18T21:38:11.160' AS DateTime), N'Book', 192, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (438, CAST(N'2021-03-18T21:38:11.163' AS DateTime), N'Book', 193, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (439, CAST(N'2021-03-18T21:38:11.167' AS DateTime), N'Author', 72, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (440, CAST(N'2021-03-18T21:38:11.180' AS DateTime), N'Author', 73, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (441, CAST(N'2021-03-18T21:38:11.180' AS DateTime), N'Book', 194, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (442, CAST(N'2021-03-18T21:38:11.187' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (443, CAST(N'2021-03-18T21:38:11.190' AS DateTime), N'Book', 195, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (444, CAST(N'2021-03-18T21:38:11.190' AS DateTime), N'Book', 196, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (445, CAST(N'2021-03-18T21:38:11.193' AS DateTime), N'Book', 197, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (446, CAST(N'2021-03-18T21:38:11.197' AS DateTime), N'Book', 198, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (447, CAST(N'2021-03-18T21:38:11.207' AS DateTime), N'Book', 199, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (448, CAST(N'2021-03-18T21:38:11.223' AS DateTime), N'Author', 72, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (449, CAST(N'2021-03-18T21:38:11.237' AS DateTime), N'Newspaper', 200, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (450, CAST(N'2021-03-18T21:38:11.243' AS DateTime), N'Newspaper', 201, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (451, CAST(N'2021-03-18T21:38:11.247' AS DateTime), N'Newspaper', 202, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (452, CAST(N'2021-03-18T21:38:11.250' AS DateTime), N'Newspaper', 203, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (453, CAST(N'2021-03-18T21:38:11.260' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (454, CAST(N'2021-03-18T21:38:11.263' AS DateTime), N'Newspaper', 204, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (455, CAST(N'2021-03-18T21:38:11.267' AS DateTime), N'Newspaper', 204, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (456, CAST(N'2021-03-18T21:38:11.267' AS DateTime), N'Newspaper', 205, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (457, CAST(N'2021-03-18T21:38:11.270' AS DateTime), N'Newspaper', 206, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (458, CAST(N'2021-03-18T21:38:11.270' AS DateTime), N'Newspaper', 207, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (459, CAST(N'2021-03-18T21:38:11.277' AS DateTime), N'Newspaper', 200, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (460, CAST(N'2021-03-18T21:38:11.277' AS DateTime), N'Newspaper', 201, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (461, CAST(N'2021-03-18T21:38:11.280' AS DateTime), N'Newspaper', 202, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (462, CAST(N'2021-03-18T21:38:11.280' AS DateTime), N'Newspaper', 203, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (463, CAST(N'2021-03-18T21:38:11.280' AS DateTime), N'Newspaper', 205, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (464, CAST(N'2021-03-18T21:38:11.280' AS DateTime), N'Newspaper', 206, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (465, CAST(N'2021-03-18T21:38:11.280' AS DateTime), N'Newspaper', 207, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (466, CAST(N'2021-03-18T21:38:11.293' AS DateTime), N'Patent', 208, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (467, CAST(N'2021-03-18T21:38:11.300' AS DateTime), N'Patent', 209, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (468, CAST(N'2021-03-18T21:38:11.303' AS DateTime), N'Patent', 210, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (469, CAST(N'2021-03-18T21:38:11.307' AS DateTime), N'Patent', 211, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (470, CAST(N'2021-03-18T21:38:11.317' AS DateTime), N'Author', 74, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (471, CAST(N'2021-03-18T21:38:11.333' AS DateTime), N'Patent', 212, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (472, CAST(N'2021-03-18T21:38:11.337' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (473, CAST(N'2021-03-18T21:38:11.340' AS DateTime), N'Patent', 213, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (474, CAST(N'2021-03-18T21:38:11.343' AS DateTime), N'Patent', 213, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (475, CAST(N'2021-03-18T21:38:11.350' AS DateTime), N'Patent', 214, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (476, CAST(N'2021-03-18T21:38:11.350' AS DateTime), N'Patent', 215, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (477, CAST(N'2021-03-18T21:38:11.357' AS DateTime), N'Patent', 216, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (478, CAST(N'2021-03-18T21:38:11.363' AS DateTime), N'Patent', 208, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (479, CAST(N'2021-03-18T21:38:11.363' AS DateTime), N'Patent', 209, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (480, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 210, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (481, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 211, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (482, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 212, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (483, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 214, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (484, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 215, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (485, CAST(N'2021-03-18T21:38:11.367' AS DateTime), N'Patent', 216, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (486, CAST(N'2021-03-18T21:38:11.370' AS DateTime), N'Author', 74, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (487, CAST(N'2021-03-18T21:38:11.380' AS DateTime), N'Author', 75, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (488, CAST(N'2021-03-18T21:38:11.383' AS DateTime), N'Book', 217, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (489, CAST(N'2021-03-18T21:38:11.390' AS DateTime), N'Author', 76, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (490, CAST(N'2021-03-18T21:38:11.397' AS DateTime), N'Patent', 218, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (491, CAST(N'2021-03-18T21:38:11.403' AS DateTime), N'Author', 77, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (492, CAST(N'2021-03-18T21:38:11.403' AS DateTime), N'Book', 219, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (493, CAST(N'2021-03-18T21:38:11.440' AS DateTime), N'Patent', 218, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (494, CAST(N'2021-03-18T21:38:11.440' AS DateTime), N'Author', 75, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (495, CAST(N'2021-03-18T21:38:11.440' AS DateTime), N'Author', 76, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (496, CAST(N'2021-03-18T21:39:32.167' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (497, CAST(N'2021-03-18T21:39:32.283' AS DateTime), N'Book', 220, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (498, CAST(N'2021-03-18T21:39:32.317' AS DateTime), N'Book', 221, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (499, CAST(N'2021-03-18T21:39:32.320' AS DateTime), N'Book', 222, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (500, CAST(N'2021-03-18T21:39:32.323' AS DateTime), N'Book', 223, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (501, CAST(N'2021-03-18T21:39:32.323' AS DateTime), N'Book', 224, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (502, CAST(N'2021-03-18T21:39:32.333' AS DateTime), N'Author', 78, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (503, CAST(N'2021-03-18T21:39:32.357' AS DateTime), N'Book', 225, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (504, CAST(N'2021-03-18T21:39:32.440' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (505, CAST(N'2021-03-18T21:39:32.450' AS DateTime), N'Book', 226, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (506, CAST(N'2021-03-18T21:39:32.453' AS DateTime), N'Book', 227, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (507, CAST(N'2021-03-18T21:39:32.453' AS DateTime), N'Book', 228, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (508, CAST(N'2021-03-18T21:39:32.457' AS DateTime), N'Book', 229, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (509, CAST(N'2021-03-18T21:39:32.460' AS DateTime), N'Book', 230, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (510, CAST(N'2021-03-18T21:39:32.483' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (511, CAST(N'2021-03-18T21:39:32.497' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (512, CAST(N'2021-03-18T21:39:32.517' AS DateTime), N'Book', 231, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (513, CAST(N'2021-03-18T21:39:32.523' AS DateTime), N'Author', 79, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (514, CAST(N'2021-03-18T21:39:32.527' AS DateTime), N'Book', 232, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (515, CAST(N'2021-03-18T21:41:08.563' AS DateTime), N'Book', 233, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (516, CAST(N'2021-03-18T21:48:04.197' AS DateTime), N'Book', 234, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (517, CAST(N'2021-03-18T21:48:28.133' AS DateTime), N'Book', 235, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (518, CAST(N'2021-03-18T22:36:45.720' AS DateTime), N'Book', 236, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (519, CAST(N'2021-03-18T22:36:45.760' AS DateTime), N'Book', 237, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (520, CAST(N'2021-03-18T22:36:45.770' AS DateTime), N'Book', 238, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (521, CAST(N'2021-03-18T22:36:45.773' AS DateTime), N'Book', 239, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (522, CAST(N'2021-03-18T22:36:45.803' AS DateTime), N'Book', 240, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (523, CAST(N'2021-03-18T22:36:45.803' AS DateTime), N'Book', 241, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (524, CAST(N'2021-03-18T22:36:45.817' AS DateTime), N'Book', 242, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (525, CAST(N'2021-03-18T22:36:45.820' AS DateTime), N'Book', 243, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (526, CAST(N'2021-03-18T22:36:45.833' AS DateTime), N'Author', 80, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (527, CAST(N'2021-03-18T22:36:45.860' AS DateTime), N'Book', 244, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (528, CAST(N'2021-03-18T22:36:45.963' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (529, CAST(N'2021-03-18T22:36:45.987' AS DateTime), N'Book', 245, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (530, CAST(N'2021-03-18T22:36:45.987' AS DateTime), N'Book', 245, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (531, CAST(N'2021-03-18T22:36:45.993' AS DateTime), N'Book', 246, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (532, CAST(N'2021-03-18T22:36:45.997' AS DateTime), N'Book', 247, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (533, CAST(N'2021-03-18T22:36:46.000' AS DateTime), N'Book', 248, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (534, CAST(N'2021-03-18T22:36:46.007' AS DateTime), N'Book', 249, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (535, CAST(N'2021-03-18T22:36:46.010' AS DateTime), N'Book', 236, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (536, CAST(N'2021-03-18T22:36:46.010' AS DateTime), N'Book', 237, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (537, CAST(N'2021-03-18T22:36:46.010' AS DateTime), N'Book', 238, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (538, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 239, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (539, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 240, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (540, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 241, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (541, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 242, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (542, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 243, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (543, CAST(N'2021-03-18T22:36:46.013' AS DateTime), N'Book', 244, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (544, CAST(N'2021-03-18T22:36:46.017' AS DateTime), N'Book', 246, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (545, CAST(N'2021-03-18T22:36:46.017' AS DateTime), N'Book', 247, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (546, CAST(N'2021-03-18T22:36:46.017' AS DateTime), N'Book', 248, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (547, CAST(N'2021-03-18T22:36:46.017' AS DateTime), N'Book', 249, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (548, CAST(N'2021-03-18T22:36:46.027' AS DateTime), N'Author', 80, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (549, CAST(N'2021-03-18T22:43:39.710' AS DateTime), N'Book', 250, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (550, CAST(N'2021-03-18T22:43:39.757' AS DateTime), N'Book', 251, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (551, CAST(N'2021-03-18T22:43:39.813' AS DateTime), N'Book', 250, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (552, CAST(N'2021-03-18T22:43:39.813' AS DateTime), N'Book', 251, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (553, CAST(N'2021-03-18T22:49:19.287' AS DateTime), N'Book', 252, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (554, CAST(N'2021-03-18T22:49:19.347' AS DateTime), N'Book', 253, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (555, CAST(N'2021-03-18T22:49:19.407' AS DateTime), N'Book', 252, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (556, CAST(N'2021-03-18T22:49:19.410' AS DateTime), N'Book', 253, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (557, CAST(N'2021-03-18T22:50:35.190' AS DateTime), N'Book', 254, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (558, CAST(N'2021-03-18T22:50:35.233' AS DateTime), N'Book', 255, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (559, CAST(N'2021-03-18T22:50:35.297' AS DateTime), N'Book', 254, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (560, CAST(N'2021-03-18T22:50:35.297' AS DateTime), N'Book', 255, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (561, CAST(N'2021-03-18T22:57:21.400' AS DateTime), N'Book', 256, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (562, CAST(N'2021-03-18T22:57:21.490' AS DateTime), N'Book', 257, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (563, CAST(N'2021-03-18T22:57:21.560' AS DateTime), N'Book', 256, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (564, CAST(N'2021-03-18T22:57:21.563' AS DateTime), N'Book', 257, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (565, CAST(N'2021-03-18T22:57:30.253' AS DateTime), N'Book', 258, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (566, CAST(N'2021-03-18T22:57:30.303' AS DateTime), N'Book', 259, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (567, CAST(N'2021-03-18T22:57:30.370' AS DateTime), N'Book', 258, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (568, CAST(N'2021-03-18T22:57:30.370' AS DateTime), N'Book', 259, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (569, CAST(N'2021-03-18T22:59:34.010' AS DateTime), N'Book', 260, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (570, CAST(N'2021-03-18T22:59:34.053' AS DateTime), N'Book', 261, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (571, CAST(N'2021-03-18T22:59:34.137' AS DateTime), N'Book', 260, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (572, CAST(N'2021-03-18T22:59:34.140' AS DateTime), N'Book', 261, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (573, CAST(N'2021-03-18T23:01:57.423' AS DateTime), N'Book', 262, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (574, CAST(N'2021-03-18T23:01:57.483' AS DateTime), N'Book', 263, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (575, CAST(N'2021-03-18T23:10:31.087' AS DateTime), N'Book', 262, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (576, CAST(N'2021-03-18T23:10:31.090' AS DateTime), N'Book', 263, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (577, CAST(N'2021-03-18T23:15:55.553' AS DateTime), N'Author', 81, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (578, CAST(N'2021-03-18T23:15:55.633' AS DateTime), N'Author', 82, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (579, CAST(N'2021-03-18T23:15:55.633' AS DateTime), N'Author', 83, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (580, CAST(N'2021-03-18T23:15:55.633' AS DateTime), N'Author', 84, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (581, CAST(N'2021-03-18T23:15:55.640' AS DateTime), N'Author', 85, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (582, CAST(N'2021-03-18T23:15:55.647' AS DateTime), N'Author', 86, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (583, CAST(N'2021-03-18T23:15:55.663' AS DateTime), N'Patent', 264, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (584, CAST(N'2021-03-18T23:15:55.770' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (585, CAST(N'2021-03-18T23:15:55.810' AS DateTime), N'Author', 87, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (586, CAST(N'2021-03-18T23:15:55.810' AS DateTime), N'Author', 87, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (587, CAST(N'2021-03-18T23:15:55.817' AS DateTime), N'Author', 88, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (588, CAST(N'2021-03-18T23:15:55.817' AS DateTime), N'Author', 89, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (589, CAST(N'2021-03-18T23:15:55.820' AS DateTime), N'Author', 90, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (590, CAST(N'2021-03-18T23:15:55.820' AS DateTime), N'Author', 91, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (591, CAST(N'2021-03-18T23:15:55.830' AS DateTime), N'Patent', 264, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (592, CAST(N'2021-03-18T23:15:55.833' AS DateTime), N'Author', 81, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (593, CAST(N'2021-03-18T23:15:55.833' AS DateTime), N'Author', 82, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (594, CAST(N'2021-03-18T23:15:55.833' AS DateTime), N'Author', 83, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (595, CAST(N'2021-03-18T23:15:55.837' AS DateTime), N'Author', 84, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (596, CAST(N'2021-03-18T23:15:55.837' AS DateTime), N'Author', 85, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (597, CAST(N'2021-03-18T23:15:55.837' AS DateTime), N'Author', 86, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (598, CAST(N'2021-03-18T23:15:55.837' AS DateTime), N'Author', 88, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (599, CAST(N'2021-03-18T23:15:55.840' AS DateTime), N'Author', 89, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (600, CAST(N'2021-03-18T23:15:55.840' AS DateTime), N'Author', 90, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (601, CAST(N'2021-03-18T23:15:55.840' AS DateTime), N'Author', 91, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (602, CAST(N'2021-03-18T23:16:15.523' AS DateTime), N'Author', 92, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (603, CAST(N'2021-03-18T23:16:15.587' AS DateTime), N'Author', 93, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (604, CAST(N'2021-03-18T23:16:15.590' AS DateTime), N'Author', 94, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (605, CAST(N'2021-03-18T23:16:15.590' AS DateTime), N'Author', 95, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (606, CAST(N'2021-03-18T23:16:15.593' AS DateTime), N'Author', 96, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (607, CAST(N'2021-03-18T23:16:15.600' AS DateTime), N'Author', 97, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (608, CAST(N'2021-03-18T23:16:15.613' AS DateTime), N'Patent', 265, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (609, CAST(N'2021-03-18T23:16:15.703' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (610, CAST(N'2021-03-18T23:16:15.743' AS DateTime), N'Author', 98, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (611, CAST(N'2021-03-18T23:16:15.750' AS DateTime), N'Author', 98, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (612, CAST(N'2021-03-18T23:16:15.750' AS DateTime), N'Author', 99, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (613, CAST(N'2021-03-18T23:16:15.750' AS DateTime), N'Author', 100, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (614, CAST(N'2021-03-18T23:16:15.753' AS DateTime), N'Author', 101, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (615, CAST(N'2021-03-18T23:16:15.753' AS DateTime), N'Author', 102, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (616, CAST(N'2021-03-18T23:16:15.760' AS DateTime), N'Patent', 265, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (617, CAST(N'2021-03-18T23:16:15.760' AS DateTime), N'Author', 92, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (618, CAST(N'2021-03-18T23:16:15.760' AS DateTime), N'Author', 93, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (619, CAST(N'2021-03-18T23:16:15.760' AS DateTime), N'Author', 94, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (620, CAST(N'2021-03-18T23:16:15.760' AS DateTime), N'Author', 95, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (621, CAST(N'2021-03-18T23:16:15.763' AS DateTime), N'Author', 96, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (622, CAST(N'2021-03-18T23:16:15.763' AS DateTime), N'Author', 97, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (623, CAST(N'2021-03-18T23:16:15.763' AS DateTime), N'Author', 99, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (624, CAST(N'2021-03-18T23:16:15.763' AS DateTime), N'Author', 100, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (625, CAST(N'2021-03-18T23:16:15.767' AS DateTime), N'Author', 101, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (626, CAST(N'2021-03-18T23:16:15.767' AS DateTime), N'Author', 102, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (627, CAST(N'2021-03-18T23:16:15.790' AS DateTime), N'Book', 266, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (628, CAST(N'2021-03-18T23:16:15.800' AS DateTime), N'Book', 267, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (629, CAST(N'2021-03-18T23:16:15.807' AS DateTime), N'Book', 268, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (630, CAST(N'2021-03-18T23:16:15.810' AS DateTime), N'Book', 269, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (631, CAST(N'2021-03-18T23:16:15.820' AS DateTime), N'Book', 270, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (632, CAST(N'2021-03-18T23:16:15.823' AS DateTime), N'Book', 271, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (633, CAST(N'2021-03-18T23:16:15.827' AS DateTime), N'Book', 272, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (634, CAST(N'2021-03-18T23:16:15.827' AS DateTime), N'Book', 273, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (635, CAST(N'2021-03-18T23:16:15.840' AS DateTime), N'Author', 103, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (636, CAST(N'2021-03-18T23:16:15.850' AS DateTime), N'Author', 104, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (637, CAST(N'2021-03-18T23:16:15.853' AS DateTime), N'Book', 274, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (638, CAST(N'2021-03-18T23:16:15.860' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (639, CAST(N'2021-03-18T23:16:15.863' AS DateTime), N'Book', 275, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (640, CAST(N'2021-03-18T23:16:15.867' AS DateTime), N'Book', 275, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (641, CAST(N'2021-03-18T23:16:15.867' AS DateTime), N'Book', 276, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (642, CAST(N'2021-03-18T23:16:15.870' AS DateTime), N'Book', 277, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (643, CAST(N'2021-03-18T23:16:15.873' AS DateTime), N'Book', 278, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (644, CAST(N'2021-03-18T23:16:15.880' AS DateTime), N'Book', 279, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (645, CAST(N'2021-03-18T23:16:15.883' AS DateTime), N'Book', 266, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (646, CAST(N'2021-03-18T23:16:15.883' AS DateTime), N'Book', 267, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (647, CAST(N'2021-03-18T23:16:15.887' AS DateTime), N'Book', 268, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (648, CAST(N'2021-03-18T23:16:15.887' AS DateTime), N'Book', 269, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (649, CAST(N'2021-03-18T23:16:15.887' AS DateTime), N'Book', 270, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (650, CAST(N'2021-03-18T23:16:15.887' AS DateTime), N'Book', 271, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (651, CAST(N'2021-03-18T23:16:15.887' AS DateTime), N'Book', 272, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (652, CAST(N'2021-03-18T23:16:15.890' AS DateTime), N'Book', 273, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (653, CAST(N'2021-03-18T23:16:15.890' AS DateTime), N'Book', 276, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (654, CAST(N'2021-03-18T23:16:15.890' AS DateTime), N'Book', 277, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (655, CAST(N'2021-03-18T23:16:15.890' AS DateTime), N'Book', 278, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (656, CAST(N'2021-03-18T23:16:15.890' AS DateTime), N'Book', 279, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (657, CAST(N'2021-03-18T23:16:15.900' AS DateTime), N'Author', 103, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (658, CAST(N'2021-03-18T23:16:15.913' AS DateTime), N'Newspaper', 280, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (659, CAST(N'2021-03-18T23:16:15.920' AS DateTime), N'Newspaper', 281, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (660, CAST(N'2021-03-18T23:16:15.927' AS DateTime), N'Newspaper', 282, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (661, CAST(N'2021-03-18T23:16:15.927' AS DateTime), N'Newspaper', 283, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (662, CAST(N'2021-03-18T23:16:15.937' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (663, CAST(N'2021-03-18T23:16:15.940' AS DateTime), N'Newspaper', 284, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (664, CAST(N'2021-03-18T23:16:15.940' AS DateTime), N'Newspaper', 284, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (665, CAST(N'2021-03-18T23:16:15.943' AS DateTime), N'Newspaper', 285, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (666, CAST(N'2021-03-18T23:16:15.943' AS DateTime), N'Newspaper', 286, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (667, CAST(N'2021-03-18T23:16:15.947' AS DateTime), N'Newspaper', 287, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (668, CAST(N'2021-03-18T23:16:15.950' AS DateTime), N'Newspaper', 280, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (669, CAST(N'2021-03-18T23:16:15.950' AS DateTime), N'Newspaper', 281, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (670, CAST(N'2021-03-18T23:16:15.950' AS DateTime), N'Newspaper', 282, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (671, CAST(N'2021-03-18T23:16:15.953' AS DateTime), N'Newspaper', 283, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (672, CAST(N'2021-03-18T23:16:15.953' AS DateTime), N'Newspaper', 285, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (673, CAST(N'2021-03-18T23:16:15.953' AS DateTime), N'Newspaper', 286, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (674, CAST(N'2021-03-18T23:16:15.953' AS DateTime), N'Newspaper', 287, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (675, CAST(N'2021-03-18T23:16:15.970' AS DateTime), N'Patent', 288, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (676, CAST(N'2021-03-18T23:16:15.977' AS DateTime), N'Patent', 289, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (677, CAST(N'2021-03-18T23:16:15.980' AS DateTime), N'Patent', 290, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (678, CAST(N'2021-03-18T23:16:15.983' AS DateTime), N'Patent', 291, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (679, CAST(N'2021-03-18T23:16:15.993' AS DateTime), N'Author', 105, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (680, CAST(N'2021-03-18T23:16:16.010' AS DateTime), N'Patent', 292, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (681, CAST(N'2021-03-18T23:16:16.013' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (682, CAST(N'2021-03-18T23:16:16.020' AS DateTime), N'Patent', 293, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (683, CAST(N'2021-03-18T23:16:16.020' AS DateTime), N'Patent', 293, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (684, CAST(N'2021-03-18T23:16:16.027' AS DateTime), N'Patent', 294, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (685, CAST(N'2021-03-18T23:16:16.030' AS DateTime), N'Patent', 295, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (686, CAST(N'2021-03-18T23:16:16.033' AS DateTime), N'Patent', 296, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (687, CAST(N'2021-03-18T23:16:16.040' AS DateTime), N'Patent', 288, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (688, CAST(N'2021-03-18T23:16:16.043' AS DateTime), N'Patent', 289, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (689, CAST(N'2021-03-18T23:16:16.043' AS DateTime), N'Patent', 290, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (690, CAST(N'2021-03-18T23:16:16.043' AS DateTime), N'Patent', 291, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (691, CAST(N'2021-03-18T23:16:16.043' AS DateTime), N'Patent', 292, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (692, CAST(N'2021-03-18T23:16:16.043' AS DateTime), N'Patent', 294, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (693, CAST(N'2021-03-18T23:16:16.047' AS DateTime), N'Patent', 295, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (694, CAST(N'2021-03-18T23:16:16.047' AS DateTime), N'Patent', 296, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (695, CAST(N'2021-03-18T23:16:16.047' AS DateTime), N'Author', 105, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (696, CAST(N'2021-03-18T23:16:16.050' AS DateTime), N'Book', 297, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (697, CAST(N'2021-03-18T23:16:16.057' AS DateTime), N'Author', 106, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (698, CAST(N'2021-03-18T23:16:16.060' AS DateTime), N'Book', 298, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (699, CAST(N'2021-03-18T23:16:16.070' AS DateTime), N'Author', 107, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (700, CAST(N'2021-03-18T23:16:16.070' AS DateTime), N'Patent', 299, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (701, CAST(N'2021-03-18T23:16:16.077' AS DateTime), N'Author', 108, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (702, CAST(N'2021-03-18T23:16:16.080' AS DateTime), N'Book', 300, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (703, CAST(N'2021-03-18T23:16:16.083' AS DateTime), N'Patent', 301, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (704, CAST(N'2021-03-18T23:16:16.093' AS DateTime), N'Book', 302, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (705, CAST(N'2021-03-18T23:16:16.100' AS DateTime), N'Book', 303, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (706, CAST(N'2021-03-18T23:16:16.110' AS DateTime), N'Book', 304, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (707, CAST(N'2021-03-18T23:16:16.120' AS DateTime), N'Book', 297, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (708, CAST(N'2021-03-18T23:16:16.120' AS DateTime), N'Book', 298, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (709, CAST(N'2021-03-18T23:16:16.120' AS DateTime), N'Book', 300, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (710, CAST(N'2021-03-18T23:16:16.123' AS DateTime), N'Book', 302, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (711, CAST(N'2021-03-18T23:16:16.123' AS DateTime), N'Book', 303, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (712, CAST(N'2021-03-18T23:16:16.123' AS DateTime), N'Book', 304, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (713, CAST(N'2021-03-18T23:16:16.123' AS DateTime), N'Patent', 299, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (714, CAST(N'2021-03-18T23:16:16.123' AS DateTime), N'Patent', 301, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (715, CAST(N'2021-03-18T23:16:16.127' AS DateTime), N'Author', 106, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (716, CAST(N'2021-03-18T23:16:16.127' AS DateTime), N'Author', 107, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (717, CAST(N'2021-03-18T23:16:16.127' AS DateTime), N'Author', 108, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (718, CAST(N'2021-03-18T23:23:15.360' AS DateTime), N'Author', 109, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (719, CAST(N'2021-03-18T23:24:20.977' AS DateTime), N'Book', 305, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (720, CAST(N'2021-03-18T23:26:58.347' AS DateTime), N'Book', 305, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (721, CAST(N'2021-03-18T23:26:58.360' AS DateTime), N'Author', 109, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (722, CAST(N'2021-03-18T23:28:00.573' AS DateTime), N'Author', 110, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (723, CAST(N'2021-03-18T23:28:00.643' AS DateTime), N'Author', 111, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (724, CAST(N'2021-03-18T23:28:00.647' AS DateTime), N'Author', 112, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (725, CAST(N'2021-03-18T23:28:00.647' AS DateTime), N'Author', 113, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (726, CAST(N'2021-03-18T23:28:00.650' AS DateTime), N'Author', 114, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (727, CAST(N'2021-03-18T23:28:00.660' AS DateTime), N'Author', 115, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (728, CAST(N'2021-03-18T23:28:00.677' AS DateTime), N'Patent', 306, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (729, CAST(N'2021-03-18T23:28:00.783' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (730, CAST(N'2021-03-18T23:28:00.820' AS DateTime), N'Author', 116, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (731, CAST(N'2021-03-18T23:28:00.827' AS DateTime), N'Author', 116, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (732, CAST(N'2021-03-18T23:28:00.827' AS DateTime), N'Author', 117, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (733, CAST(N'2021-03-18T23:28:00.830' AS DateTime), N'Author', 118, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (734, CAST(N'2021-03-18T23:28:00.830' AS DateTime), N'Author', 119, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (735, CAST(N'2021-03-18T23:28:00.833' AS DateTime), N'Author', 120, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (736, CAST(N'2021-03-18T23:28:00.843' AS DateTime), N'Patent', 306, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (737, CAST(N'2021-03-18T23:28:00.847' AS DateTime), N'Author', 110, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (738, CAST(N'2021-03-18T23:28:00.847' AS DateTime), N'Author', 111, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (739, CAST(N'2021-03-18T23:28:00.847' AS DateTime), N'Author', 112, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (740, CAST(N'2021-03-18T23:28:00.847' AS DateTime), N'Author', 113, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (741, CAST(N'2021-03-18T23:28:00.850' AS DateTime), N'Author', 114, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (742, CAST(N'2021-03-18T23:28:00.850' AS DateTime), N'Author', 115, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (743, CAST(N'2021-03-18T23:28:00.850' AS DateTime), N'Author', 117, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (744, CAST(N'2021-03-18T23:28:00.850' AS DateTime), N'Author', 118, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (745, CAST(N'2021-03-18T23:28:00.850' AS DateTime), N'Author', 119, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (746, CAST(N'2021-03-18T23:28:00.853' AS DateTime), N'Author', 120, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (747, CAST(N'2021-03-18T23:28:00.880' AS DateTime), N'Book', 307, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (748, CAST(N'2021-03-18T23:28:00.883' AS DateTime), N'Book', 308, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (749, CAST(N'2021-03-18T23:28:00.890' AS DateTime), N'Book', 309, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (750, CAST(N'2021-03-18T23:28:00.890' AS DateTime), N'Book', 310, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (751, CAST(N'2021-03-18T23:28:00.900' AS DateTime), N'Book', 311, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (752, CAST(N'2021-03-18T23:28:00.903' AS DateTime), N'Book', 312, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (753, CAST(N'2021-03-18T23:28:00.907' AS DateTime), N'Book', 313, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (754, CAST(N'2021-03-18T23:28:00.907' AS DateTime), N'Book', 314, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (755, CAST(N'2021-03-18T23:28:00.920' AS DateTime), N'Author', 121, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (756, CAST(N'2021-03-18T23:28:00.930' AS DateTime), N'Author', 122, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (757, CAST(N'2021-03-18T23:28:00.933' AS DateTime), N'Book', 315, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (758, CAST(N'2021-03-18T23:28:00.940' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (759, CAST(N'2021-03-18T23:28:00.943' AS DateTime), N'Book', 316, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (760, CAST(N'2021-03-18T23:28:00.947' AS DateTime), N'Book', 316, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (761, CAST(N'2021-03-18T23:28:00.950' AS DateTime), N'Book', 317, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (762, CAST(N'2021-03-18T23:28:00.950' AS DateTime), N'Book', 318, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (763, CAST(N'2021-03-18T23:28:00.953' AS DateTime), N'Book', 319, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (764, CAST(N'2021-03-18T23:28:00.963' AS DateTime), N'Book', 320, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (765, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 307, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (766, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 308, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (767, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 309, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (768, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 310, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (769, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 311, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (770, CAST(N'2021-03-18T23:28:00.967' AS DateTime), N'Book', 312, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (771, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 313, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (772, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 314, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (773, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 317, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (774, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 318, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (775, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 319, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (776, CAST(N'2021-03-18T23:28:00.970' AS DateTime), N'Book', 320, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (777, CAST(N'2021-03-18T23:28:00.973' AS DateTime), N'Author', 121, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (778, CAST(N'2021-03-18T23:28:00.987' AS DateTime), N'Newspaper', 321, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (779, CAST(N'2021-03-18T23:28:00.993' AS DateTime), N'Newspaper', 322, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (780, CAST(N'2021-03-18T23:28:00.997' AS DateTime), N'Newspaper', 323, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (781, CAST(N'2021-03-18T23:28:00.997' AS DateTime), N'Newspaper', 324, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (782, CAST(N'2021-03-18T23:28:01.007' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (783, CAST(N'2021-03-18T23:28:01.010' AS DateTime), N'Newspaper', 325, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (784, CAST(N'2021-03-18T23:28:01.010' AS DateTime), N'Newspaper', 325, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (785, CAST(N'2021-03-18T23:28:01.013' AS DateTime), N'Newspaper', 326, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (786, CAST(N'2021-03-18T23:28:01.017' AS DateTime), N'Newspaper', 327, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (787, CAST(N'2021-03-18T23:28:01.017' AS DateTime), N'Newspaper', 328, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (788, CAST(N'2021-03-18T23:28:01.023' AS DateTime), N'Newspaper', 321, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (789, CAST(N'2021-03-18T23:28:01.023' AS DateTime), N'Newspaper', 322, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (790, CAST(N'2021-03-18T23:28:01.027' AS DateTime), N'Newspaper', 323, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (791, CAST(N'2021-03-18T23:28:01.027' AS DateTime), N'Newspaper', 324, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (792, CAST(N'2021-03-18T23:28:01.027' AS DateTime), N'Newspaper', 326, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (793, CAST(N'2021-03-18T23:28:01.030' AS DateTime), N'Newspaper', 327, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (794, CAST(N'2021-03-18T23:28:01.030' AS DateTime), N'Newspaper', 328, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (795, CAST(N'2021-03-18T23:28:01.050' AS DateTime), N'Patent', 329, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (796, CAST(N'2021-03-18T23:28:01.053' AS DateTime), N'Patent', 330, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (797, CAST(N'2021-03-18T23:28:01.060' AS DateTime), N'Patent', 331, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (798, CAST(N'2021-03-18T23:28:01.060' AS DateTime), N'Patent', 332, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (799, CAST(N'2021-03-18T23:28:01.070' AS DateTime), N'Author', 123, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (800, CAST(N'2021-03-18T23:28:01.087' AS DateTime), N'Patent', 333, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (801, CAST(N'2021-03-18T23:28:01.090' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (802, CAST(N'2021-03-18T23:28:01.097' AS DateTime), N'Patent', 334, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (803, CAST(N'2021-03-18T23:28:01.097' AS DateTime), N'Patent', 334, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (804, CAST(N'2021-03-18T23:28:01.103' AS DateTime), N'Patent', 335, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (805, CAST(N'2021-03-18T23:28:01.107' AS DateTime), N'Patent', 336, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (806, CAST(N'2021-03-18T23:28:01.110' AS DateTime), N'Patent', 337, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (807, CAST(N'2021-03-18T23:28:01.120' AS DateTime), N'Patent', 329, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (808, CAST(N'2021-03-18T23:28:01.120' AS DateTime), N'Patent', 330, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (809, CAST(N'2021-03-18T23:28:01.120' AS DateTime), N'Patent', 331, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (810, CAST(N'2021-03-18T23:28:01.120' AS DateTime), N'Patent', 332, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (811, CAST(N'2021-03-18T23:28:01.120' AS DateTime), N'Patent', 333, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (812, CAST(N'2021-03-18T23:28:01.123' AS DateTime), N'Patent', 335, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (813, CAST(N'2021-03-18T23:28:01.123' AS DateTime), N'Patent', 336, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (814, CAST(N'2021-03-18T23:28:01.123' AS DateTime), N'Patent', 337, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (815, CAST(N'2021-03-18T23:28:01.123' AS DateTime), N'Author', 123, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (816, CAST(N'2021-03-18T23:28:01.127' AS DateTime), N'Book', 338, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (817, CAST(N'2021-03-18T23:28:01.130' AS DateTime), N'Author', 124, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (818, CAST(N'2021-03-18T23:28:01.133' AS DateTime), N'Book', 339, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (819, CAST(N'2021-03-18T23:28:01.143' AS DateTime), N'Author', 125, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (820, CAST(N'2021-03-18T23:28:01.147' AS DateTime), N'Patent', 340, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (821, CAST(N'2021-03-18T23:28:01.150' AS DateTime), N'Author', 126, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (822, CAST(N'2021-03-18T23:28:01.153' AS DateTime), N'Book', 341, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (823, CAST(N'2021-03-18T23:28:01.160' AS DateTime), N'Patent', 342, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (824, CAST(N'2021-03-18T23:28:01.163' AS DateTime), N'Book', 343, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (825, CAST(N'2021-03-18T23:28:01.173' AS DateTime), N'Book', 344, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (826, CAST(N'2021-03-18T23:28:01.183' AS DateTime), N'Book', 345, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (827, CAST(N'2021-03-18T23:28:01.193' AS DateTime), N'Book', 338, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (828, CAST(N'2021-03-18T23:28:01.193' AS DateTime), N'Book', 339, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (829, CAST(N'2021-03-18T23:28:01.193' AS DateTime), N'Book', 341, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (830, CAST(N'2021-03-18T23:28:01.193' AS DateTime), N'Book', 343, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (831, CAST(N'2021-03-18T23:28:01.197' AS DateTime), N'Book', 344, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (832, CAST(N'2021-03-18T23:28:01.197' AS DateTime), N'Book', 345, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (833, CAST(N'2021-03-18T23:28:01.197' AS DateTime), N'Patent', 340, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (834, CAST(N'2021-03-18T23:28:01.197' AS DateTime), N'Patent', 342, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (835, CAST(N'2021-03-18T23:28:01.197' AS DateTime), N'Author', 124, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (836, CAST(N'2021-03-18T23:28:01.200' AS DateTime), N'Author', 125, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (837, CAST(N'2021-03-18T23:28:01.200' AS DateTime), N'Author', 126, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (838, CAST(N'2021-03-18T23:28:38.167' AS DateTime), N'Author', 127, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (839, CAST(N'2021-03-18T23:28:38.257' AS DateTime), N'Author', 128, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (840, CAST(N'2021-03-18T23:28:38.263' AS DateTime), N'Author', 129, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (841, CAST(N'2021-03-18T23:28:38.263' AS DateTime), N'Author', 130, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (842, CAST(N'2021-03-18T23:28:38.270' AS DateTime), N'Author', 131, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (843, CAST(N'2021-03-18T23:28:38.280' AS DateTime), N'Author', 132, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (844, CAST(N'2021-03-18T23:28:38.297' AS DateTime), N'Patent', 346, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (845, CAST(N'2021-03-18T23:28:38.430' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (846, CAST(N'2021-03-18T23:28:38.480' AS DateTime), N'Author', 133, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (847, CAST(N'2021-03-18T23:28:38.497' AS DateTime), N'Author', 133, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (848, CAST(N'2021-03-18T23:28:38.503' AS DateTime), N'Author', 134, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (849, CAST(N'2021-03-18T23:28:38.510' AS DateTime), N'Author', 135, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (850, CAST(N'2021-03-18T23:28:38.513' AS DateTime), N'Author', 136, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (851, CAST(N'2021-03-18T23:28:38.520' AS DateTime), N'Author', 137, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (852, CAST(N'2021-03-18T23:28:38.530' AS DateTime), N'Patent', 346, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (853, CAST(N'2021-03-18T23:28:38.537' AS DateTime), N'Author', 127, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (854, CAST(N'2021-03-18T23:28:38.540' AS DateTime), N'Author', 128, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (855, CAST(N'2021-03-18T23:28:38.540' AS DateTime), N'Author', 129, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (856, CAST(N'2021-03-18T23:28:38.540' AS DateTime), N'Author', 130, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (857, CAST(N'2021-03-18T23:28:38.540' AS DateTime), N'Author', 131, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (858, CAST(N'2021-03-18T23:28:38.547' AS DateTime), N'Author', 132, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (859, CAST(N'2021-03-18T23:28:38.547' AS DateTime), N'Author', 134, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (860, CAST(N'2021-03-18T23:28:38.547' AS DateTime), N'Author', 135, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (861, CAST(N'2021-03-18T23:28:38.547' AS DateTime), N'Author', 136, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (862, CAST(N'2021-03-18T23:28:38.550' AS DateTime), N'Author', 137, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (863, CAST(N'2021-03-18T23:28:38.570' AS DateTime), N'Book', 347, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (864, CAST(N'2021-03-18T23:28:38.583' AS DateTime), N'Book', 348, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (865, CAST(N'2021-03-18T23:28:38.590' AS DateTime), N'Book', 349, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (866, CAST(N'2021-03-18T23:28:38.590' AS DateTime), N'Book', 350, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (867, CAST(N'2021-03-18T23:28:38.617' AS DateTime), N'Book', 351, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (868, CAST(N'2021-03-18T23:28:38.640' AS DateTime), N'Book', 352, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (869, CAST(N'2021-03-18T23:28:38.673' AS DateTime), N'Book', 353, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (870, CAST(N'2021-03-18T23:28:38.693' AS DateTime), N'Book', 354, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (871, CAST(N'2021-03-18T23:28:38.717' AS DateTime), N'Author', 138, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (872, CAST(N'2021-03-18T23:28:38.733' AS DateTime), N'Author', 139, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (873, CAST(N'2021-03-18T23:28:38.757' AS DateTime), N'Book', 355, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (874, CAST(N'2021-03-18T23:28:38.770' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (875, CAST(N'2021-03-18T23:28:38.787' AS DateTime), N'Book', 356, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (876, CAST(N'2021-03-18T23:28:38.790' AS DateTime), N'Book', 356, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (877, CAST(N'2021-03-18T23:28:38.790' AS DateTime), N'Book', 357, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (878, CAST(N'2021-03-18T23:28:38.793' AS DateTime), N'Book', 358, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (879, CAST(N'2021-03-18T23:28:38.797' AS DateTime), N'Book', 359, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (880, CAST(N'2021-03-18T23:28:38.803' AS DateTime), N'Book', 360, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (881, CAST(N'2021-03-18T23:28:38.813' AS DateTime), N'Book', 347, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (882, CAST(N'2021-03-18T23:28:38.813' AS DateTime), N'Book', 348, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (883, CAST(N'2021-03-18T23:28:38.813' AS DateTime), N'Book', 349, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (884, CAST(N'2021-03-18T23:28:38.817' AS DateTime), N'Book', 350, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (885, CAST(N'2021-03-18T23:28:38.817' AS DateTime), N'Book', 351, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (886, CAST(N'2021-03-18T23:28:38.817' AS DateTime), N'Book', 352, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (887, CAST(N'2021-03-18T23:28:38.817' AS DateTime), N'Book', 353, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (888, CAST(N'2021-03-18T23:28:38.817' AS DateTime), N'Book', 354, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (889, CAST(N'2021-03-18T23:28:38.820' AS DateTime), N'Book', 357, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (890, CAST(N'2021-03-18T23:28:38.820' AS DateTime), N'Book', 358, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (891, CAST(N'2021-03-18T23:28:38.820' AS DateTime), N'Book', 359, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (892, CAST(N'2021-03-18T23:28:38.820' AS DateTime), N'Book', 360, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (893, CAST(N'2021-03-18T23:28:38.833' AS DateTime), N'Author', 138, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (894, CAST(N'2021-03-18T23:28:38.857' AS DateTime), N'Newspaper', 361, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (895, CAST(N'2021-03-18T23:28:38.870' AS DateTime), N'Newspaper', 362, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (896, CAST(N'2021-03-18T23:28:38.883' AS DateTime), N'Newspaper', 363, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (897, CAST(N'2021-03-18T23:28:38.893' AS DateTime), N'Newspaper', 364, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (898, CAST(N'2021-03-18T23:28:38.913' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (899, CAST(N'2021-03-18T23:28:38.927' AS DateTime), N'Newspaper', 365, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (900, CAST(N'2021-03-18T23:28:38.933' AS DateTime), N'Newspaper', 365, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (901, CAST(N'2021-03-18T23:28:38.943' AS DateTime), N'Newspaper', 366, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (902, CAST(N'2021-03-18T23:28:38.953' AS DateTime), N'Newspaper', 367, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (903, CAST(N'2021-03-18T23:28:38.963' AS DateTime), N'Newspaper', 368, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (904, CAST(N'2021-03-18T23:28:38.983' AS DateTime), N'Newspaper', 361, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (905, CAST(N'2021-03-18T23:28:38.987' AS DateTime), N'Newspaper', 362, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (906, CAST(N'2021-03-18T23:28:38.990' AS DateTime), N'Newspaper', 363, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (907, CAST(N'2021-03-18T23:28:38.990' AS DateTime), N'Newspaper', 364, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (908, CAST(N'2021-03-18T23:28:38.990' AS DateTime), N'Newspaper', 366, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (909, CAST(N'2021-03-18T23:28:38.990' AS DateTime), N'Newspaper', 367, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (910, CAST(N'2021-03-18T23:28:38.993' AS DateTime), N'Newspaper', 368, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (911, CAST(N'2021-03-18T23:28:39.033' AS DateTime), N'Patent', 369, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (912, CAST(N'2021-03-18T23:28:39.040' AS DateTime), N'Patent', 370, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (913, CAST(N'2021-03-18T23:28:39.047' AS DateTime), N'Patent', 371, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (914, CAST(N'2021-03-18T23:28:39.050' AS DateTime), N'Patent', 372, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (915, CAST(N'2021-03-18T23:28:39.060' AS DateTime), N'Author', 140, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (916, CAST(N'2021-03-18T23:28:39.083' AS DateTime), N'Patent', 373, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (917, CAST(N'2021-03-18T23:28:39.087' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (918, CAST(N'2021-03-18T23:28:39.093' AS DateTime), N'Patent', 374, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (919, CAST(N'2021-03-18T23:28:39.097' AS DateTime), N'Patent', 374, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (920, CAST(N'2021-03-18T23:28:39.113' AS DateTime), N'Patent', 375, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (921, CAST(N'2021-03-18T23:28:39.140' AS DateTime), N'Patent', 376, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (922, CAST(N'2021-03-18T23:28:39.167' AS DateTime), N'Patent', 377, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (923, CAST(N'2021-03-18T23:28:39.193' AS DateTime), N'Patent', 369, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (924, CAST(N'2021-03-18T23:28:39.193' AS DateTime), N'Patent', 370, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (925, CAST(N'2021-03-18T23:28:39.193' AS DateTime), N'Patent', 371, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (926, CAST(N'2021-03-18T23:28:39.193' AS DateTime), N'Patent', 372, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (927, CAST(N'2021-03-18T23:28:39.197' AS DateTime), N'Patent', 373, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (928, CAST(N'2021-03-18T23:28:39.197' AS DateTime), N'Patent', 375, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (929, CAST(N'2021-03-18T23:28:39.197' AS DateTime), N'Patent', 376, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (930, CAST(N'2021-03-18T23:28:39.200' AS DateTime), N'Patent', 377, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (931, CAST(N'2021-03-18T23:28:39.213' AS DateTime), N'Author', 140, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (932, CAST(N'2021-03-18T23:28:39.247' AS DateTime), N'Book', 378, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (933, CAST(N'2021-03-18T23:28:39.270' AS DateTime), N'Author', 141, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (934, CAST(N'2021-03-18T23:28:39.300' AS DateTime), N'Book', 379, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (935, CAST(N'2021-03-18T23:28:39.310' AS DateTime), N'Author', 142, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (936, CAST(N'2021-03-18T23:28:39.320' AS DateTime), N'Patent', 380, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (937, CAST(N'2021-03-18T23:28:39.327' AS DateTime), N'Author', 143, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (938, CAST(N'2021-03-18T23:28:39.330' AS DateTime), N'Book', 381, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (939, CAST(N'2021-03-18T23:28:39.337' AS DateTime), N'Patent', 382, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (940, CAST(N'2021-03-18T23:28:39.340' AS DateTime), N'Book', 383, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (941, CAST(N'2021-03-18T23:28:39.410' AS DateTime), N'Book', 384, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (942, CAST(N'2021-03-18T23:28:39.520' AS DateTime), N'Book', 385, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (943, CAST(N'2021-03-18T23:28:39.540' AS DateTime), N'Book', 378, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (944, CAST(N'2021-03-18T23:28:39.540' AS DateTime), N'Book', 379, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (945, CAST(N'2021-03-18T23:28:39.540' AS DateTime), N'Book', 381, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (946, CAST(N'2021-03-18T23:28:39.540' AS DateTime), N'Book', 383, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (947, CAST(N'2021-03-18T23:28:39.540' AS DateTime), N'Book', 384, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (948, CAST(N'2021-03-18T23:28:39.543' AS DateTime), N'Book', 385, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (949, CAST(N'2021-03-18T23:28:39.547' AS DateTime), N'Patent', 380, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (950, CAST(N'2021-03-18T23:28:39.547' AS DateTime), N'Patent', 382, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (951, CAST(N'2021-03-18T23:28:39.557' AS DateTime), N'Author', 141, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (952, CAST(N'2021-03-18T23:28:39.560' AS DateTime), N'Author', 142, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (953, CAST(N'2021-03-18T23:28:39.560' AS DateTime), N'Author', 143, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (954, CAST(N'2021-03-18T23:32:12.840' AS DateTime), N'Author', 144, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (955, CAST(N'2021-03-18T23:32:12.910' AS DateTime), N'Author', 145, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (956, CAST(N'2021-03-18T23:32:12.913' AS DateTime), N'Author', 146, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (957, CAST(N'2021-03-18T23:32:12.917' AS DateTime), N'Author', 147, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (958, CAST(N'2021-03-18T23:32:12.920' AS DateTime), N'Author', 148, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (959, CAST(N'2021-03-18T23:32:12.927' AS DateTime), N'Author', 149, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (960, CAST(N'2021-03-18T23:32:12.943' AS DateTime), N'Patent', 386, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (961, CAST(N'2021-03-18T23:32:13.053' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (962, CAST(N'2021-03-18T23:32:13.090' AS DateTime), N'Author', 150, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (963, CAST(N'2021-03-18T23:32:13.097' AS DateTime), N'Author', 150, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (964, CAST(N'2021-03-18T23:32:13.097' AS DateTime), N'Author', 151, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (965, CAST(N'2021-03-18T23:32:13.100' AS DateTime), N'Author', 152, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (966, CAST(N'2021-03-18T23:32:13.100' AS DateTime), N'Author', 153, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (967, CAST(N'2021-03-18T23:32:13.107' AS DateTime), N'Author', 154, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (968, CAST(N'2021-03-18T23:32:13.117' AS DateTime), N'Patent', 386, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (969, CAST(N'2021-03-18T23:32:13.117' AS DateTime), N'Author', 144, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (970, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 145, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (971, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 146, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (972, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 147, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (973, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 148, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (974, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 149, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (975, CAST(N'2021-03-18T23:32:13.120' AS DateTime), N'Author', 151, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (976, CAST(N'2021-03-18T23:32:13.123' AS DateTime), N'Author', 152, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (977, CAST(N'2021-03-18T23:32:13.123' AS DateTime), N'Author', 153, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (978, CAST(N'2021-03-18T23:32:13.123' AS DateTime), N'Author', 154, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (979, CAST(N'2021-03-18T23:32:13.153' AS DateTime), N'Book', 387, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (980, CAST(N'2021-03-18T23:32:13.167' AS DateTime), N'Book', 388, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (981, CAST(N'2021-03-18T23:32:13.173' AS DateTime), N'Book', 389, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (982, CAST(N'2021-03-18T23:32:13.177' AS DateTime), N'Book', 390, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (983, CAST(N'2021-03-18T23:32:13.187' AS DateTime), N'Book', 391, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (984, CAST(N'2021-03-18T23:32:13.190' AS DateTime), N'Book', 392, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (985, CAST(N'2021-03-18T23:32:13.190' AS DateTime), N'Book', 393, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (986, CAST(N'2021-03-18T23:32:13.193' AS DateTime), N'Book', 394, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (987, CAST(N'2021-03-18T23:32:13.203' AS DateTime), N'Author', 155, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (988, CAST(N'2021-03-18T23:32:13.217' AS DateTime), N'Author', 156, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (989, CAST(N'2021-03-18T23:32:13.217' AS DateTime), N'Book', 395, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (990, CAST(N'2021-03-18T23:32:13.227' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (991, CAST(N'2021-03-18T23:32:13.230' AS DateTime), N'Book', 396, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (992, CAST(N'2021-03-18T23:32:13.230' AS DateTime), N'Book', 396, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (993, CAST(N'2021-03-18T23:32:13.233' AS DateTime), N'Book', 397, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (994, CAST(N'2021-03-18T23:32:13.237' AS DateTime), N'Book', 398, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (995, CAST(N'2021-03-18T23:32:13.240' AS DateTime), N'Book', 399, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (996, CAST(N'2021-03-18T23:32:13.247' AS DateTime), N'Book', 400, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (997, CAST(N'2021-03-18T23:32:13.250' AS DateTime), N'Book', 387, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (998, CAST(N'2021-03-18T23:32:13.250' AS DateTime), N'Book', 388, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (999, CAST(N'2021-03-18T23:32:13.250' AS DateTime), N'Book', 389, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1000, CAST(N'2021-03-18T23:32:13.250' AS DateTime), N'Book', 390, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1001, CAST(N'2021-03-18T23:32:13.253' AS DateTime), N'Book', 391, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1002, CAST(N'2021-03-18T23:32:13.253' AS DateTime), N'Book', 392, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1003, CAST(N'2021-03-18T23:32:13.253' AS DateTime), N'Book', 393, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1004, CAST(N'2021-03-18T23:32:13.253' AS DateTime), N'Book', 394, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1005, CAST(N'2021-03-18T23:32:13.257' AS DateTime), N'Book', 397, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1006, CAST(N'2021-03-18T23:32:13.257' AS DateTime), N'Book', 398, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1007, CAST(N'2021-03-18T23:32:13.257' AS DateTime), N'Book', 399, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1008, CAST(N'2021-03-18T23:32:13.257' AS DateTime), N'Book', 400, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1009, CAST(N'2021-03-18T23:32:13.267' AS DateTime), N'Author', 155, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1010, CAST(N'2021-03-18T23:32:13.280' AS DateTime), N'Newspaper', 401, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1011, CAST(N'2021-03-18T23:32:13.287' AS DateTime), N'Newspaper', 402, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1012, CAST(N'2021-03-18T23:32:13.290' AS DateTime), N'Newspaper', 403, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1013, CAST(N'2021-03-18T23:32:13.293' AS DateTime), N'Newspaper', 404, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1014, CAST(N'2021-03-18T23:32:13.300' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1015, CAST(N'2021-03-18T23:32:13.303' AS DateTime), N'Newspaper', 405, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1016, CAST(N'2021-03-18T23:32:13.307' AS DateTime), N'Newspaper', 405, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1017, CAST(N'2021-03-18T23:32:13.307' AS DateTime), N'Newspaper', 406, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1018, CAST(N'2021-03-18T23:32:13.310' AS DateTime), N'Newspaper', 407, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1019, CAST(N'2021-03-18T23:32:13.310' AS DateTime), N'Newspaper', 408, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1020, CAST(N'2021-03-18T23:32:13.317' AS DateTime), N'Newspaper', 401, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1021, CAST(N'2021-03-18T23:32:13.317' AS DateTime), N'Newspaper', 402, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1022, CAST(N'2021-03-18T23:32:13.317' AS DateTime), N'Newspaper', 403, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1023, CAST(N'2021-03-18T23:32:13.320' AS DateTime), N'Newspaper', 404, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1024, CAST(N'2021-03-18T23:32:13.320' AS DateTime), N'Newspaper', 406, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1025, CAST(N'2021-03-18T23:32:13.320' AS DateTime), N'Newspaper', 407, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1026, CAST(N'2021-03-18T23:32:13.320' AS DateTime), N'Newspaper', 408, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1027, CAST(N'2021-03-18T23:32:13.343' AS DateTime), N'Patent', 409, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1028, CAST(N'2021-03-18T23:32:13.350' AS DateTime), N'Patent', 410, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1029, CAST(N'2021-03-18T23:32:13.353' AS DateTime), N'Patent', 411, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1030, CAST(N'2021-03-18T23:32:13.363' AS DateTime), N'Patent', 412, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1031, CAST(N'2021-03-18T23:32:13.373' AS DateTime), N'Author', 157, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1032, CAST(N'2021-03-18T23:32:13.390' AS DateTime), N'Patent', 413, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1033, CAST(N'2021-03-18T23:32:13.390' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1034, CAST(N'2021-03-18T23:32:13.397' AS DateTime), N'Patent', 414, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1035, CAST(N'2021-03-18T23:32:13.400' AS DateTime), N'Patent', 414, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1036, CAST(N'2021-03-18T23:32:13.403' AS DateTime), N'Patent', 415, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1037, CAST(N'2021-03-18T23:32:13.407' AS DateTime), N'Patent', 416, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1038, CAST(N'2021-03-18T23:32:13.413' AS DateTime), N'Patent', 417, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1039, CAST(N'2021-03-18T23:32:13.420' AS DateTime), N'Patent', 409, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1040, CAST(N'2021-03-18T23:32:13.420' AS DateTime), N'Patent', 410, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1041, CAST(N'2021-03-18T23:32:13.420' AS DateTime), N'Patent', 411, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1042, CAST(N'2021-03-18T23:32:13.423' AS DateTime), N'Patent', 412, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1043, CAST(N'2021-03-18T23:32:13.423' AS DateTime), N'Patent', 413, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1044, CAST(N'2021-03-18T23:32:13.423' AS DateTime), N'Patent', 415, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1045, CAST(N'2021-03-18T23:32:13.423' AS DateTime), N'Patent', 416, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1046, CAST(N'2021-03-18T23:32:13.423' AS DateTime), N'Patent', 417, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1047, CAST(N'2021-03-18T23:32:13.427' AS DateTime), N'Author', 157, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1048, CAST(N'2021-03-18T23:32:13.430' AS DateTime), N'Book', 418, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1049, CAST(N'2021-03-18T23:32:13.433' AS DateTime), N'Author', 158, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1050, CAST(N'2021-03-18T23:32:13.440' AS DateTime), N'Book', 419, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1051, CAST(N'2021-03-18T23:32:13.450' AS DateTime), N'Author', 159, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1052, CAST(N'2021-03-18T23:32:13.453' AS DateTime), N'Patent', 420, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1053, CAST(N'2021-03-18T23:32:13.457' AS DateTime), N'Author', 160, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1054, CAST(N'2021-03-18T23:32:13.460' AS DateTime), N'Book', 421, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1055, CAST(N'2021-03-18T23:32:13.467' AS DateTime), N'Patent', 422, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1056, CAST(N'2021-03-18T23:32:13.473' AS DateTime), N'Book', 423, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1057, CAST(N'2021-03-18T23:32:13.480' AS DateTime), N'Book', 424, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1058, CAST(N'2021-03-18T23:32:13.490' AS DateTime), N'Book', 425, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1059, CAST(N'2021-03-18T23:32:13.500' AS DateTime), N'Book', 418, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1060, CAST(N'2021-03-18T23:32:13.500' AS DateTime), N'Book', 419, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1061, CAST(N'2021-03-18T23:32:13.503' AS DateTime), N'Book', 421, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1062, CAST(N'2021-03-18T23:32:13.503' AS DateTime), N'Book', 423, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1063, CAST(N'2021-03-18T23:32:13.503' AS DateTime), N'Book', 424, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1064, CAST(N'2021-03-18T23:32:13.503' AS DateTime), N'Book', 425, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1065, CAST(N'2021-03-18T23:32:13.507' AS DateTime), N'Patent', 420, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1066, CAST(N'2021-03-18T23:32:13.507' AS DateTime), N'Patent', 422, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1067, CAST(N'2021-03-18T23:32:13.507' AS DateTime), N'Author', 158, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1068, CAST(N'2021-03-18T23:32:13.507' AS DateTime), N'Author', 159, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1069, CAST(N'2021-03-18T23:32:13.510' AS DateTime), N'Author', 160, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1070, CAST(N'2021-03-18T23:32:57.567' AS DateTime), N'Author', 161, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1071, CAST(N'2021-03-18T23:33:19.073' AS DateTime), N'Book', 426, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1072, CAST(N'2021-03-18T23:33:54.203' AS DateTime), N'Book', 426, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1073, CAST(N'2021-03-18T23:33:54.213' AS DateTime), N'Author', 161, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1074, CAST(N'2021-03-18T23:34:24.560' AS DateTime), N'Author', 162, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1075, CAST(N'2021-03-18T23:34:24.640' AS DateTime), N'Author', 163, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1076, CAST(N'2021-03-18T23:34:24.640' AS DateTime), N'Author', 164, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1077, CAST(N'2021-03-18T23:34:24.640' AS DateTime), N'Author', 165, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1078, CAST(N'2021-03-18T23:34:24.647' AS DateTime), N'Author', 166, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1079, CAST(N'2021-03-18T23:34:25.757' AS DateTime), N'Author', 167, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1080, CAST(N'2021-03-18T23:34:25.777' AS DateTime), N'Patent', 427, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1081, CAST(N'2021-03-18T23:34:25.897' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1082, CAST(N'2021-03-18T23:34:28.540' AS DateTime), N'Author', 168, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1083, CAST(N'2021-03-18T23:34:28.540' AS DateTime), N'Author', 168, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1084, CAST(N'2021-03-18T23:34:28.543' AS DateTime), N'Author', 169, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1085, CAST(N'2021-03-18T23:34:28.550' AS DateTime), N'Author', 170, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1086, CAST(N'2021-03-18T23:34:28.550' AS DateTime), N'Author', 171, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1087, CAST(N'2021-03-18T23:34:28.553' AS DateTime), N'Author', 172, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1088, CAST(N'2021-03-18T23:34:28.563' AS DateTime), N'Patent', 427, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1089, CAST(N'2021-03-18T23:34:28.567' AS DateTime), N'Author', 162, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1090, CAST(N'2021-03-18T23:34:28.567' AS DateTime), N'Author', 163, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1091, CAST(N'2021-03-18T23:34:28.567' AS DateTime), N'Author', 164, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1092, CAST(N'2021-03-18T23:34:28.567' AS DateTime), N'Author', 165, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1093, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 166, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1094, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 167, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1095, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 169, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1096, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 170, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1097, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 171, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1098, CAST(N'2021-03-18T23:34:28.570' AS DateTime), N'Author', 172, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1099, CAST(N'2021-03-18T23:34:29.977' AS DateTime), N'Book', 428, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1100, CAST(N'2021-03-18T23:34:29.980' AS DateTime), N'Book', 429, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1101, CAST(N'2021-03-18T23:34:31.097' AS DateTime), N'Book', 430, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1102, CAST(N'2021-03-18T23:34:31.103' AS DateTime), N'Book', 431, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1103, CAST(N'2021-03-18T23:34:31.123' AS DateTime), N'Book', 432, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1104, CAST(N'2021-03-18T23:34:31.123' AS DateTime), N'Book', 433, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1105, CAST(N'2021-03-18T23:34:31.127' AS DateTime), N'Book', 434, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1106, CAST(N'2021-03-18T23:34:31.130' AS DateTime), N'Book', 435, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1107, CAST(N'2021-03-18T23:34:37.823' AS DateTime), N'Author', 173, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1108, CAST(N'2021-03-18T23:34:58.777' AS DateTime), N'Author', 174, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1109, CAST(N'2021-03-18T23:35:04.940' AS DateTime), N'Book', 436, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1110, CAST(N'2021-03-18T23:49:20.307' AS DateTime), N'Author', 175, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1111, CAST(N'2021-03-18T23:49:20.383' AS DateTime), N'Author', 176, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1112, CAST(N'2021-03-18T23:49:20.387' AS DateTime), N'Author', 177, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1113, CAST(N'2021-03-18T23:49:20.390' AS DateTime), N'Author', 178, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1114, CAST(N'2021-03-18T23:49:20.390' AS DateTime), N'Author', 179, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1115, CAST(N'2021-03-18T23:49:20.400' AS DateTime), N'Author', 180, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1116, CAST(N'2021-03-18T23:49:20.417' AS DateTime), N'Patent', 437, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1117, CAST(N'2021-03-18T23:49:20.523' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1118, CAST(N'2021-03-18T23:49:20.560' AS DateTime), N'Author', 181, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1119, CAST(N'2021-03-18T23:49:20.567' AS DateTime), N'Author', 181, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1120, CAST(N'2021-03-18T23:49:20.567' AS DateTime), N'Author', 182, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1121, CAST(N'2021-03-18T23:49:20.570' AS DateTime), N'Author', 183, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1122, CAST(N'2021-03-18T23:49:20.570' AS DateTime), N'Author', 184, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1123, CAST(N'2021-03-18T23:49:20.573' AS DateTime), N'Author', 185, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1124, CAST(N'2021-03-18T23:49:20.583' AS DateTime), N'Patent', 437, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1125, CAST(N'2021-03-18T23:49:20.583' AS DateTime), N'Author', 175, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1126, CAST(N'2021-03-18T23:49:20.587' AS DateTime), N'Author', 176, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1127, CAST(N'2021-03-18T23:49:20.587' AS DateTime), N'Author', 177, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1128, CAST(N'2021-03-18T23:49:20.587' AS DateTime), N'Author', 178, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1129, CAST(N'2021-03-18T23:49:20.587' AS DateTime), N'Author', 179, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1130, CAST(N'2021-03-18T23:49:20.590' AS DateTime), N'Author', 180, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1131, CAST(N'2021-03-18T23:49:20.590' AS DateTime), N'Author', 182, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1132, CAST(N'2021-03-18T23:49:20.590' AS DateTime), N'Author', 183, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1133, CAST(N'2021-03-18T23:49:20.590' AS DateTime), N'Author', 184, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1134, CAST(N'2021-03-18T23:49:20.590' AS DateTime), N'Author', 185, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1135, CAST(N'2021-03-18T23:49:20.617' AS DateTime), N'Book', 438, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1136, CAST(N'2021-03-18T23:49:20.627' AS DateTime), N'Book', 439, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1137, CAST(N'2021-03-18T23:49:20.633' AS DateTime), N'Book', 440, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1138, CAST(N'2021-03-18T23:49:20.633' AS DateTime), N'Book', 441, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1139, CAST(N'2021-03-18T23:49:20.647' AS DateTime), N'Book', 442, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1140, CAST(N'2021-03-18T23:49:20.647' AS DateTime), N'Book', 443, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1141, CAST(N'2021-03-18T23:49:20.650' AS DateTime), N'Book', 444, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1142, CAST(N'2021-03-18T23:49:20.650' AS DateTime), N'Book', 445, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1143, CAST(N'2021-03-18T23:49:20.663' AS DateTime), N'Author', 186, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1144, CAST(N'2021-03-18T23:49:20.673' AS DateTime), N'Author', 187, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1145, CAST(N'2021-03-18T23:49:20.677' AS DateTime), N'Book', 446, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1146, CAST(N'2021-03-18T23:49:20.683' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1147, CAST(N'2021-03-18T23:49:20.687' AS DateTime), N'Book', 447, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1148, CAST(N'2021-03-18T23:49:20.690' AS DateTime), N'Book', 447, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1149, CAST(N'2021-03-18T23:49:20.690' AS DateTime), N'Book', 448, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1150, CAST(N'2021-03-18T23:49:20.693' AS DateTime), N'Book', 449, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1151, CAST(N'2021-03-18T23:49:20.697' AS DateTime), N'Book', 450, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1152, CAST(N'2021-03-18T23:49:20.703' AS DateTime), N'Book', 451, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1153, CAST(N'2021-03-18T23:49:20.707' AS DateTime), N'Book', 438, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1154, CAST(N'2021-03-18T23:49:20.707' AS DateTime), N'Book', 439, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1155, CAST(N'2021-03-18T23:49:20.707' AS DateTime), N'Book', 440, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1156, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 441, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1157, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 442, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1158, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 443, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1159, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 444, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1160, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 445, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1161, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 448, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1162, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 449, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1163, CAST(N'2021-03-18T23:49:20.710' AS DateTime), N'Book', 450, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1164, CAST(N'2021-03-18T23:49:20.713' AS DateTime), N'Book', 451, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1165, CAST(N'2021-03-18T23:49:20.723' AS DateTime), N'Author', 186, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1166, CAST(N'2021-03-18T23:49:20.737' AS DateTime), N'Newspaper', 452, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1167, CAST(N'2021-03-18T23:49:20.743' AS DateTime), N'Newspaper', 453, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1168, CAST(N'2021-03-18T23:49:20.750' AS DateTime), N'Newspaper', 454, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1169, CAST(N'2021-03-18T23:49:20.750' AS DateTime), N'Newspaper', 455, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1170, CAST(N'2021-03-18T23:49:20.760' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1171, CAST(N'2021-03-18T23:49:20.763' AS DateTime), N'Newspaper', 456, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1172, CAST(N'2021-03-18T23:49:20.763' AS DateTime), N'Newspaper', 456, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1173, CAST(N'2021-03-18T23:49:20.767' AS DateTime), N'Newspaper', 457, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1174, CAST(N'2021-03-18T23:49:20.767' AS DateTime), N'Newspaper', 458, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1175, CAST(N'2021-03-18T23:49:20.770' AS DateTime), N'Newspaper', 459, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1176, CAST(N'2021-03-18T23:49:20.773' AS DateTime), N'Newspaper', 452, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1177, CAST(N'2021-03-18T23:49:20.773' AS DateTime), N'Newspaper', 453, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1178, CAST(N'2021-03-18T23:49:20.773' AS DateTime), N'Newspaper', 454, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1179, CAST(N'2021-03-18T23:49:20.777' AS DateTime), N'Newspaper', 455, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1180, CAST(N'2021-03-18T23:49:20.777' AS DateTime), N'Newspaper', 457, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1181, CAST(N'2021-03-18T23:49:20.777' AS DateTime), N'Newspaper', 458, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1182, CAST(N'2021-03-18T23:49:20.777' AS DateTime), N'Newspaper', 459, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1183, CAST(N'2021-03-18T23:49:20.797' AS DateTime), N'Patent', 460, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1184, CAST(N'2021-03-18T23:49:20.803' AS DateTime), N'Patent', 461, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1185, CAST(N'2021-03-18T23:49:20.807' AS DateTime), N'Patent', 462, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1186, CAST(N'2021-03-18T23:49:20.810' AS DateTime), N'Patent', 463, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1187, CAST(N'2021-03-18T23:49:20.820' AS DateTime), N'Author', 188, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1188, CAST(N'2021-03-18T23:49:20.833' AS DateTime), N'Author', 189, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1189, CAST(N'2021-03-18T23:49:20.837' AS DateTime), N'Patent', 464, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1190, CAST(N'2021-03-18T23:49:20.840' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1191, CAST(N'2021-03-18T23:49:20.843' AS DateTime), N'Patent', 465, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1192, CAST(N'2021-03-18T23:49:20.843' AS DateTime), N'Patent', 465, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1193, CAST(N'2021-03-18T23:49:20.850' AS DateTime), N'Patent', 466, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1194, CAST(N'2021-03-18T23:49:20.853' AS DateTime), N'Patent', 467, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1195, CAST(N'2021-03-18T23:49:20.857' AS DateTime), N'Patent', 468, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1196, CAST(N'2021-03-18T23:49:20.867' AS DateTime), N'Patent', 460, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1197, CAST(N'2021-03-18T23:49:20.867' AS DateTime), N'Patent', 461, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1198, CAST(N'2021-03-18T23:49:20.867' AS DateTime), N'Patent', 462, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1199, CAST(N'2021-03-18T23:49:20.867' AS DateTime), N'Patent', 463, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1200, CAST(N'2021-03-18T23:49:20.867' AS DateTime), N'Patent', 464, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1201, CAST(N'2021-03-18T23:49:20.870' AS DateTime), N'Patent', 466, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1202, CAST(N'2021-03-18T23:49:20.870' AS DateTime), N'Patent', 467, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1203, CAST(N'2021-03-18T23:49:20.870' AS DateTime), N'Patent', 468, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1204, CAST(N'2021-03-18T23:49:20.870' AS DateTime), N'Author', 188, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1205, CAST(N'2021-03-18T23:49:20.870' AS DateTime), N'Author', 189, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1206, CAST(N'2021-03-18T23:49:20.873' AS DateTime), N'Book', 469, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1207, CAST(N'2021-03-18T23:49:20.880' AS DateTime), N'Author', 190, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1208, CAST(N'2021-03-18T23:49:20.880' AS DateTime), N'Author', 191, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1209, CAST(N'2021-03-18T23:49:20.883' AS DateTime), N'Book', 470, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1210, CAST(N'2021-03-18T23:49:20.887' AS DateTime), N'Author', 192, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1211, CAST(N'2021-03-18T23:49:20.890' AS DateTime), N'Patent', 471, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1212, CAST(N'2021-03-18T23:49:20.897' AS DateTime), N'Author', 193, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1213, CAST(N'2021-03-18T23:49:20.900' AS DateTime), N'Book', 472, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1214, CAST(N'2021-03-18T23:49:20.903' AS DateTime), N'Patent', 473, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1215, CAST(N'2021-03-18T23:49:20.910' AS DateTime), N'Book', 474, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1216, CAST(N'2021-03-18T23:49:20.920' AS DateTime), N'Book', 475, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1217, CAST(N'2021-03-18T23:49:20.927' AS DateTime), N'Book', 476, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1218, CAST(N'2021-03-18T23:49:20.937' AS DateTime), N'Book', 469, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1219, CAST(N'2021-03-18T23:49:20.937' AS DateTime), N'Book', 470, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1220, CAST(N'2021-03-18T23:49:20.937' AS DateTime), N'Book', 472, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1221, CAST(N'2021-03-18T23:49:20.937' AS DateTime), N'Book', 474, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1222, CAST(N'2021-03-18T23:49:20.940' AS DateTime), N'Book', 475, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1223, CAST(N'2021-03-18T23:49:20.940' AS DateTime), N'Book', 476, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1224, CAST(N'2021-03-18T23:49:20.940' AS DateTime), N'Patent', 471, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1225, CAST(N'2021-03-18T23:49:20.940' AS DateTime), N'Patent', 473, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1226, CAST(N'2021-03-18T23:49:20.940' AS DateTime), N'Author', 190, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1227, CAST(N'2021-03-18T23:49:20.943' AS DateTime), N'Author', 191, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1228, CAST(N'2021-03-18T23:49:20.943' AS DateTime), N'Author', 192, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1229, CAST(N'2021-03-18T23:49:20.943' AS DateTime), N'Author', 193, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1230, CAST(N'2021-03-18T23:53:38.230' AS DateTime), N'Author', 194, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1231, CAST(N'2021-03-18T23:53:38.290' AS DateTime), N'Author', 195, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1232, CAST(N'2021-03-18T23:53:38.290' AS DateTime), N'Author', 196, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1233, CAST(N'2021-03-18T23:53:38.293' AS DateTime), N'Author', 197, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1234, CAST(N'2021-03-18T23:53:38.297' AS DateTime), N'Author', 198, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1235, CAST(N'2021-03-18T23:53:38.303' AS DateTime), N'Author', 199, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1236, CAST(N'2021-03-18T23:53:38.320' AS DateTime), N'Patent', 477, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1237, CAST(N'2021-03-18T23:53:38.430' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1238, CAST(N'2021-03-18T23:53:38.467' AS DateTime), N'Author', 200, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1239, CAST(N'2021-03-18T23:53:38.470' AS DateTime), N'Author', 200, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1240, CAST(N'2021-03-18T23:53:38.473' AS DateTime), N'Author', 201, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1241, CAST(N'2021-03-18T23:53:38.473' AS DateTime), N'Author', 202, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1242, CAST(N'2021-03-18T23:53:38.477' AS DateTime), N'Author', 203, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1243, CAST(N'2021-03-18T23:53:38.480' AS DateTime), N'Author', 204, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1244, CAST(N'2021-03-18T23:53:38.490' AS DateTime), N'Patent', 477, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1245, CAST(N'2021-03-18T23:53:38.490' AS DateTime), N'Author', 194, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1246, CAST(N'2021-03-18T23:53:38.490' AS DateTime), N'Author', 195, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1247, CAST(N'2021-03-18T23:53:38.490' AS DateTime), N'Author', 196, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1248, CAST(N'2021-03-18T23:53:38.493' AS DateTime), N'Author', 197, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1249, CAST(N'2021-03-18T23:53:38.493' AS DateTime), N'Author', 198, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1250, CAST(N'2021-03-18T23:53:38.493' AS DateTime), N'Author', 199, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1251, CAST(N'2021-03-18T23:53:38.493' AS DateTime), N'Author', 201, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1252, CAST(N'2021-03-18T23:53:38.493' AS DateTime), N'Author', 202, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1253, CAST(N'2021-03-18T23:53:38.497' AS DateTime), N'Author', 203, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1254, CAST(N'2021-03-18T23:53:38.497' AS DateTime), N'Author', 204, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1255, CAST(N'2021-03-18T23:53:38.523' AS DateTime), N'Book', 478, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1256, CAST(N'2021-03-18T23:53:38.530' AS DateTime), N'Book', 479, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1257, CAST(N'2021-03-18T23:53:38.533' AS DateTime), N'Book', 480, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1258, CAST(N'2021-03-18T23:53:38.533' AS DateTime), N'Book', 481, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1259, CAST(N'2021-03-18T23:53:38.547' AS DateTime), N'Book', 482, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1260, CAST(N'2021-03-18T23:53:38.547' AS DateTime), N'Book', 483, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1261, CAST(N'2021-03-18T23:53:38.550' AS DateTime), N'Book', 484, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1262, CAST(N'2021-03-18T23:53:38.550' AS DateTime), N'Book', 485, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1263, CAST(N'2021-03-18T23:53:38.563' AS DateTime), N'Author', 205, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1264, CAST(N'2021-03-18T23:53:38.577' AS DateTime), N'Author', 206, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1265, CAST(N'2021-03-18T23:53:38.580' AS DateTime), N'Book', 486, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1266, CAST(N'2021-03-18T23:53:38.587' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1267, CAST(N'2021-03-18T23:53:38.590' AS DateTime), N'Book', 487, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1268, CAST(N'2021-03-18T23:53:38.590' AS DateTime), N'Book', 487, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1269, CAST(N'2021-03-18T23:53:38.593' AS DateTime), N'Book', 488, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1270, CAST(N'2021-03-18T23:53:38.597' AS DateTime), N'Book', 489, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1271, CAST(N'2021-03-18T23:53:38.600' AS DateTime), N'Book', 490, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1272, CAST(N'2021-03-18T23:53:38.607' AS DateTime), N'Book', 491, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1273, CAST(N'2021-03-18T23:53:38.610' AS DateTime), N'Book', 478, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1274, CAST(N'2021-03-18T23:53:38.610' AS DateTime), N'Book', 479, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1275, CAST(N'2021-03-18T23:53:38.610' AS DateTime), N'Book', 480, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1276, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 481, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1277, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 482, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1278, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 483, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1279, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 484, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1280, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 485, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1281, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 488, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1282, CAST(N'2021-03-18T23:53:38.613' AS DateTime), N'Book', 489, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1283, CAST(N'2021-03-18T23:53:38.617' AS DateTime), N'Book', 490, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1284, CAST(N'2021-03-18T23:53:38.617' AS DateTime), N'Book', 491, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1285, CAST(N'2021-03-18T23:53:38.617' AS DateTime), N'Author', 205, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1286, CAST(N'2021-03-18T23:53:38.630' AS DateTime), N'Newspaper', 492, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1287, CAST(N'2021-03-18T23:53:38.630' AS DateTime), N'Newspaper', 493, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1288, CAST(N'2021-03-18T23:53:38.637' AS DateTime), N'Newspaper', 494, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1289, CAST(N'2021-03-18T23:53:38.640' AS DateTime), N'Newspaper', 495, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1290, CAST(N'2021-03-18T23:53:38.647' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1291, CAST(N'2021-03-18T23:53:38.650' AS DateTime), N'Newspaper', 496, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1292, CAST(N'2021-03-18T23:53:38.653' AS DateTime), N'Newspaper', 496, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1293, CAST(N'2021-03-18T23:53:38.653' AS DateTime), N'Newspaper', 497, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1294, CAST(N'2021-03-18T23:53:38.657' AS DateTime), N'Newspaper', 498, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1295, CAST(N'2021-03-18T23:53:38.657' AS DateTime), N'Newspaper', 499, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1296, CAST(N'2021-03-18T23:53:38.663' AS DateTime), N'Newspaper', 492, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1297, CAST(N'2021-03-18T23:53:38.663' AS DateTime), N'Newspaper', 493, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1298, CAST(N'2021-03-18T23:53:38.663' AS DateTime), N'Newspaper', 494, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1299, CAST(N'2021-03-18T23:53:38.667' AS DateTime), N'Newspaper', 495, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1300, CAST(N'2021-03-18T23:53:38.667' AS DateTime), N'Newspaper', 497, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1301, CAST(N'2021-03-18T23:53:38.667' AS DateTime), N'Newspaper', 498, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1302, CAST(N'2021-03-18T23:53:38.667' AS DateTime), N'Newspaper', 499, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1303, CAST(N'2021-03-18T23:53:38.683' AS DateTime), N'Patent', 500, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1304, CAST(N'2021-03-18T23:53:38.687' AS DateTime), N'Patent', 501, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1305, CAST(N'2021-03-18T23:53:38.690' AS DateTime), N'Patent', 502, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1306, CAST(N'2021-03-18T23:53:38.693' AS DateTime), N'Patent', 503, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1307, CAST(N'2021-03-18T23:53:38.703' AS DateTime), N'Author', 207, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1308, CAST(N'2021-03-18T23:53:38.720' AS DateTime), N'Patent', 504, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1309, CAST(N'2021-03-18T23:53:38.723' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1310, CAST(N'2021-03-18T23:53:38.730' AS DateTime), N'Patent', 505, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1311, CAST(N'2021-03-18T23:53:38.730' AS DateTime), N'Patent', 505, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1312, CAST(N'2021-03-18T23:53:38.737' AS DateTime), N'Patent', 506, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1313, CAST(N'2021-03-18T23:53:38.740' AS DateTime), N'Patent', 507, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1314, CAST(N'2021-03-18T23:53:38.743' AS DateTime), N'Patent', 508, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1315, CAST(N'2021-03-18T23:53:38.750' AS DateTime), N'Patent', 500, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1316, CAST(N'2021-03-18T23:53:38.750' AS DateTime), N'Patent', 501, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1317, CAST(N'2021-03-18T23:53:38.750' AS DateTime), N'Patent', 502, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1318, CAST(N'2021-03-18T23:53:38.753' AS DateTime), N'Patent', 503, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1319, CAST(N'2021-03-18T23:53:38.753' AS DateTime), N'Patent', 504, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1320, CAST(N'2021-03-18T23:53:38.753' AS DateTime), N'Patent', 506, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1321, CAST(N'2021-03-18T23:53:38.753' AS DateTime), N'Patent', 507, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1322, CAST(N'2021-03-18T23:53:38.753' AS DateTime), N'Patent', 508, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1323, CAST(N'2021-03-18T23:53:38.757' AS DateTime), N'Author', 207, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1324, CAST(N'2021-03-18T23:53:38.760' AS DateTime), N'Book', 509, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1325, CAST(N'2021-03-18T23:53:38.763' AS DateTime), N'Author', 208, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1326, CAST(N'2021-03-18T23:53:38.767' AS DateTime), N'Book', 510, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1327, CAST(N'2021-03-18T23:53:38.777' AS DateTime), N'Author', 209, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1328, CAST(N'2021-03-18T23:53:38.780' AS DateTime), N'Patent', 511, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1329, CAST(N'2021-03-18T23:53:38.787' AS DateTime), N'Author', 210, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1330, CAST(N'2021-03-18T23:53:38.787' AS DateTime), N'Book', 512, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1331, CAST(N'2021-03-18T23:53:38.793' AS DateTime), N'Patent', 513, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1332, CAST(N'2021-03-18T23:53:38.800' AS DateTime), N'Book', 514, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1333, CAST(N'2021-03-18T23:53:38.813' AS DateTime), N'Book', 515, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1334, CAST(N'2021-03-18T23:53:38.823' AS DateTime), N'Book', 516, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1335, CAST(N'2021-03-18T23:53:38.830' AS DateTime), N'Book', 509, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1336, CAST(N'2021-03-18T23:53:38.830' AS DateTime), N'Book', 510, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1337, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Book', 512, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1338, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Book', 514, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1339, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Book', 515, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1340, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Book', 516, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1341, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Patent', 511, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1342, CAST(N'2021-03-18T23:53:38.833' AS DateTime), N'Patent', 513, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1343, CAST(N'2021-03-18T23:53:38.837' AS DateTime), N'Author', 208, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1344, CAST(N'2021-03-18T23:53:38.837' AS DateTime), N'Author', 209, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1345, CAST(N'2021-03-18T23:53:38.840' AS DateTime), N'Author', 210, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1346, CAST(N'2021-03-18T23:56:45.590' AS DateTime), N'Author', 211, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1347, CAST(N'2021-03-18T23:56:45.657' AS DateTime), N'Author', 212, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1348, CAST(N'2021-03-18T23:56:45.657' AS DateTime), N'Author', 213, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1349, CAST(N'2021-03-18T23:56:45.660' AS DateTime), N'Author', 214, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1350, CAST(N'2021-03-18T23:56:45.660' AS DateTime), N'Author', 215, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1351, CAST(N'2021-03-18T23:56:45.670' AS DateTime), N'Author', 216, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1352, CAST(N'2021-03-18T23:56:45.687' AS DateTime), N'Patent', 517, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1353, CAST(N'2021-03-18T23:56:45.797' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1354, CAST(N'2021-03-18T23:56:45.840' AS DateTime), N'Author', 217, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1355, CAST(N'2021-03-18T23:56:45.840' AS DateTime), N'Author', 217, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1356, CAST(N'2021-03-18T23:56:45.843' AS DateTime), N'Author', 218, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1357, CAST(N'2021-03-18T23:56:45.843' AS DateTime), N'Author', 219, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1358, CAST(N'2021-03-18T23:56:45.847' AS DateTime), N'Author', 220, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1359, CAST(N'2021-03-18T23:56:45.850' AS DateTime), N'Author', 221, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1360, CAST(N'2021-03-18T23:56:45.860' AS DateTime), N'Patent', 517, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1361, CAST(N'2021-03-18T23:56:45.860' AS DateTime), N'Author', 211, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1362, CAST(N'2021-03-18T23:56:45.860' AS DateTime), N'Author', 212, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1363, CAST(N'2021-03-18T23:56:45.860' AS DateTime), N'Author', 213, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1364, CAST(N'2021-03-18T23:56:45.863' AS DateTime), N'Author', 214, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1365, CAST(N'2021-03-18T23:56:45.863' AS DateTime), N'Author', 215, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1366, CAST(N'2021-03-18T23:56:45.863' AS DateTime), N'Author', 216, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1367, CAST(N'2021-03-18T23:56:45.863' AS DateTime), N'Author', 218, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1368, CAST(N'2021-03-18T23:56:45.867' AS DateTime), N'Author', 219, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1369, CAST(N'2021-03-18T23:56:45.867' AS DateTime), N'Author', 220, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1370, CAST(N'2021-03-18T23:56:45.867' AS DateTime), N'Author', 221, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1371, CAST(N'2021-03-18T23:56:45.890' AS DateTime), N'Book', 518, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1372, CAST(N'2021-03-18T23:56:45.893' AS DateTime), N'Book', 519, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1373, CAST(N'2021-03-18T23:56:45.897' AS DateTime), N'Book', 520, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1374, CAST(N'2021-03-18T23:56:45.900' AS DateTime), N'Book', 521, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1375, CAST(N'2021-03-18T23:56:45.910' AS DateTime), N'Book', 522, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1376, CAST(N'2021-03-18T23:56:45.913' AS DateTime), N'Book', 523, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1377, CAST(N'2021-03-18T23:56:45.917' AS DateTime), N'Book', 524, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1378, CAST(N'2021-03-18T23:56:45.917' AS DateTime), N'Book', 525, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1379, CAST(N'2021-03-18T23:56:45.930' AS DateTime), N'Author', 222, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1380, CAST(N'2021-03-18T23:56:45.953' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1381, CAST(N'2021-03-18T23:56:45.957' AS DateTime), N'Book', 526, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1382, CAST(N'2021-03-18T23:56:45.957' AS DateTime), N'Book', 526, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1383, CAST(N'2021-03-18T23:56:45.960' AS DateTime), N'Book', 527, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1384, CAST(N'2021-03-18T23:56:45.960' AS DateTime), N'Book', 528, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1385, CAST(N'2021-03-18T23:56:45.963' AS DateTime), N'Book', 529, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1386, CAST(N'2021-03-18T23:56:45.973' AS DateTime), N'Book', 530, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1387, CAST(N'2021-03-18T23:56:45.977' AS DateTime), N'Book', 518, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1388, CAST(N'2021-03-18T23:56:45.977' AS DateTime), N'Book', 519, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1389, CAST(N'2021-03-18T23:56:45.977' AS DateTime), N'Book', 520, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1390, CAST(N'2021-03-18T23:56:45.977' AS DateTime), N'Book', 521, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1391, CAST(N'2021-03-18T23:56:45.977' AS DateTime), N'Book', 522, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1392, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 523, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1393, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 524, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1394, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 525, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1395, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 527, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1396, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 528, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1397, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 529, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1398, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Book', 530, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1399, CAST(N'2021-03-18T23:56:45.980' AS DateTime), N'Author', 222, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1400, CAST(N'2021-03-18T23:56:45.993' AS DateTime), N'Newspaper', 531, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1401, CAST(N'2021-03-18T23:56:45.997' AS DateTime), N'Newspaper', 532, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1402, CAST(N'2021-03-18T23:56:46.000' AS DateTime), N'Newspaper', 533, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1403, CAST(N'2021-03-18T23:56:46.003' AS DateTime), N'Newspaper', 534, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1404, CAST(N'2021-03-18T23:56:46.013' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1405, CAST(N'2021-03-18T23:56:46.017' AS DateTime), N'Newspaper', 535, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1406, CAST(N'2021-03-18T23:56:46.020' AS DateTime), N'Newspaper', 535, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1407, CAST(N'2021-03-18T23:56:46.020' AS DateTime), N'Newspaper', 536, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1408, CAST(N'2021-03-18T23:56:46.020' AS DateTime), N'Newspaper', 537, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1409, CAST(N'2021-03-18T23:56:46.023' AS DateTime), N'Newspaper', 538, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1410, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 531, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1411, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 532, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1412, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 533, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1413, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 534, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1414, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 536, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1415, CAST(N'2021-03-18T23:56:46.030' AS DateTime), N'Newspaper', 537, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1416, CAST(N'2021-03-18T23:56:46.033' AS DateTime), N'Newspaper', 538, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1417, CAST(N'2021-03-18T23:56:46.050' AS DateTime), N'Patent', 539, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1418, CAST(N'2021-03-18T23:56:46.053' AS DateTime), N'Patent', 540, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1419, CAST(N'2021-03-18T23:56:46.057' AS DateTime), N'Patent', 541, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1420, CAST(N'2021-03-18T23:56:46.060' AS DateTime), N'Patent', 542, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1421, CAST(N'2021-03-18T23:56:46.070' AS DateTime), N'Author', 223, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1422, CAST(N'2021-03-18T23:56:46.090' AS DateTime), N'Patent', 543, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1423, CAST(N'2021-03-18T23:56:46.090' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1424, CAST(N'2021-03-18T23:56:46.097' AS DateTime), N'Patent', 544, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1425, CAST(N'2021-03-18T23:56:46.097' AS DateTime), N'Patent', 544, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1426, CAST(N'2021-03-18T23:56:46.103' AS DateTime), N'Patent', 545, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1427, CAST(N'2021-03-18T23:56:46.107' AS DateTime), N'Patent', 546, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1428, CAST(N'2021-03-18T23:56:46.110' AS DateTime), N'Patent', 547, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1429, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 539, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1430, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 540, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1431, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 541, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1432, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 542, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1433, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 543, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1434, CAST(N'2021-03-18T23:56:46.120' AS DateTime), N'Patent', 545, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1435, CAST(N'2021-03-18T23:56:46.123' AS DateTime), N'Patent', 546, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1436, CAST(N'2021-03-18T23:56:46.123' AS DateTime), N'Patent', 547, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1437, CAST(N'2021-03-18T23:56:46.123' AS DateTime), N'Author', 223, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1438, CAST(N'2021-03-18T23:56:46.127' AS DateTime), N'Book', 548, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1439, CAST(N'2021-03-18T23:56:46.130' AS DateTime), N'Author', 224, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1440, CAST(N'2021-03-18T23:56:46.133' AS DateTime), N'Book', 549, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1441, CAST(N'2021-03-18T23:56:46.143' AS DateTime), N'Author', 225, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1442, CAST(N'2021-03-18T23:56:46.147' AS DateTime), N'Patent', 550, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1443, CAST(N'2021-03-18T23:56:46.153' AS DateTime), N'Author', 226, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1444, CAST(N'2021-03-18T23:56:46.157' AS DateTime), N'Book', 551, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1445, CAST(N'2021-03-18T23:56:46.163' AS DateTime), N'Patent', 552, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1446, CAST(N'2021-03-18T23:56:46.170' AS DateTime), N'Book', 553, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1447, CAST(N'2021-03-18T23:56:46.180' AS DateTime), N'Book', 554, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1448, CAST(N'2021-03-18T23:56:46.190' AS DateTime), N'Book', 555, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1449, CAST(N'2021-03-18T23:56:46.200' AS DateTime), N'Book', 548, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1450, CAST(N'2021-03-18T23:56:46.200' AS DateTime), N'Book', 549, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1451, CAST(N'2021-03-18T23:56:46.200' AS DateTime), N'Book', 551, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1452, CAST(N'2021-03-18T23:56:46.203' AS DateTime), N'Book', 553, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1453, CAST(N'2021-03-18T23:56:46.203' AS DateTime), N'Book', 554, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1454, CAST(N'2021-03-18T23:56:46.203' AS DateTime), N'Book', 555, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1455, CAST(N'2021-03-18T23:56:46.203' AS DateTime), N'Patent', 550, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1456, CAST(N'2021-03-18T23:56:46.203' AS DateTime), N'Patent', 552, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1457, CAST(N'2021-03-18T23:56:46.207' AS DateTime), N'Author', 224, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1458, CAST(N'2021-03-18T23:56:46.207' AS DateTime), N'Author', 225, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1459, CAST(N'2021-03-18T23:56:46.207' AS DateTime), N'Author', 226, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1460, CAST(N'2021-03-18T23:57:08.687' AS DateTime), N'Book', 556, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1461, CAST(N'2021-03-18T23:57:08.910' AS DateTime), N'Book', 556, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1462, CAST(N'2021-03-18T23:57:31.487' AS DateTime), N'Author', 227, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1463, CAST(N'2021-03-18T23:57:31.587' AS DateTime), N'Book', 557, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1464, CAST(N'2021-03-18T23:57:31.740' AS DateTime), N'Book', 557, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1465, CAST(N'2021-03-18T23:57:31.750' AS DateTime), N'Author', 227, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1466, CAST(N'2021-03-18T23:57:37.637' AS DateTime), N'Author', 228, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1467, CAST(N'2021-03-18T23:57:37.733' AS DateTime), N'Book', 558, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1468, CAST(N'2021-03-18T23:57:37.873' AS DateTime), N'Book', 558, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1469, CAST(N'2021-03-18T23:57:37.877' AS DateTime), N'Author', 228, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1470, CAST(N'2021-03-19T00:01:15.820' AS DateTime), N'Author', 229, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1471, CAST(N'2021-03-19T00:01:15.890' AS DateTime), N'Author', 230, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1472, CAST(N'2021-03-19T00:01:15.893' AS DateTime), N'Author', 231, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1473, CAST(N'2021-03-19T00:01:15.893' AS DateTime), N'Author', 232, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1474, CAST(N'2021-03-19T00:01:15.897' AS DateTime), N'Author', 233, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1475, CAST(N'2021-03-19T00:01:15.907' AS DateTime), N'Author', 234, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1476, CAST(N'2021-03-19T00:01:15.923' AS DateTime), N'Patent', 559, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1477, CAST(N'2021-03-19T00:01:16.027' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1478, CAST(N'2021-03-19T00:01:16.063' AS DateTime), N'Author', 235, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1479, CAST(N'2021-03-19T00:01:16.067' AS DateTime), N'Author', 235, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1480, CAST(N'2021-03-19T00:01:16.067' AS DateTime), N'Author', 236, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1481, CAST(N'2021-03-19T00:01:16.070' AS DateTime), N'Author', 237, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1482, CAST(N'2021-03-19T00:01:16.070' AS DateTime), N'Author', 238, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1483, CAST(N'2021-03-19T00:01:16.073' AS DateTime), N'Author', 239, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1484, CAST(N'2021-03-19T00:01:16.083' AS DateTime), N'Patent', 559, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1485, CAST(N'2021-03-19T00:01:16.083' AS DateTime), N'Author', 229, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1486, CAST(N'2021-03-19T00:01:16.083' AS DateTime), N'Author', 230, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1487, CAST(N'2021-03-19T00:01:16.083' AS DateTime), N'Author', 231, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1488, CAST(N'2021-03-19T00:01:16.087' AS DateTime), N'Author', 232, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1489, CAST(N'2021-03-19T00:01:16.087' AS DateTime), N'Author', 233, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1490, CAST(N'2021-03-19T00:01:16.087' AS DateTime), N'Author', 234, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1491, CAST(N'2021-03-19T00:01:16.087' AS DateTime), N'Author', 236, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1492, CAST(N'2021-03-19T00:01:16.090' AS DateTime), N'Author', 237, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1493, CAST(N'2021-03-19T00:01:16.090' AS DateTime), N'Author', 238, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1494, CAST(N'2021-03-19T00:01:16.090' AS DateTime), N'Author', 239, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1495, CAST(N'2021-03-19T00:01:16.113' AS DateTime), N'Book', 560, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1496, CAST(N'2021-03-19T00:01:16.127' AS DateTime), N'Book', 561, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1497, CAST(N'2021-03-19T00:01:16.130' AS DateTime), N'Book', 562, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1498, CAST(N'2021-03-19T00:01:16.133' AS DateTime), N'Book', 563, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1499, CAST(N'2021-03-19T00:01:16.143' AS DateTime), N'Book', 564, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1500, CAST(N'2021-03-19T00:01:16.147' AS DateTime), N'Book', 565, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1501, CAST(N'2021-03-19T00:01:16.150' AS DateTime), N'Book', 566, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1502, CAST(N'2021-03-19T00:01:16.150' AS DateTime), N'Book', 567, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1503, CAST(N'2021-03-19T00:01:16.160' AS DateTime), N'Author', 240, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1504, CAST(N'2021-03-19T00:01:16.180' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1505, CAST(N'2021-03-19T00:01:16.183' AS DateTime), N'Book', 568, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1506, CAST(N'2021-03-19T00:01:16.187' AS DateTime), N'Book', 568, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1507, CAST(N'2021-03-19T00:01:16.187' AS DateTime), N'Book', 569, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1508, CAST(N'2021-03-19T00:01:16.190' AS DateTime), N'Book', 570, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1509, CAST(N'2021-03-19T00:01:16.193' AS DateTime), N'Book', 571, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1510, CAST(N'2021-03-19T00:01:16.200' AS DateTime), N'Book', 572, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1511, CAST(N'2021-03-19T00:01:16.203' AS DateTime), N'Book', 560, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1512, CAST(N'2021-03-19T00:01:16.207' AS DateTime), N'Book', 561, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1513, CAST(N'2021-03-19T00:01:16.207' AS DateTime), N'Book', 562, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1514, CAST(N'2021-03-19T00:01:16.207' AS DateTime), N'Book', 563, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1515, CAST(N'2021-03-19T00:01:16.207' AS DateTime), N'Book', 564, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1516, CAST(N'2021-03-19T00:01:16.207' AS DateTime), N'Book', 565, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1517, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 566, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1518, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 567, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1519, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 569, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1520, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 570, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1521, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 571, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1522, CAST(N'2021-03-19T00:01:16.210' AS DateTime), N'Book', 572, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1523, CAST(N'2021-03-19T00:01:16.217' AS DateTime), N'Author', 240, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1524, CAST(N'2021-03-19T00:01:16.230' AS DateTime), N'Newspaper', 573, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1525, CAST(N'2021-03-19T00:01:16.237' AS DateTime), N'Newspaper', 574, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1526, CAST(N'2021-03-19T00:01:16.240' AS DateTime), N'Newspaper', 575, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1527, CAST(N'2021-03-19T00:01:16.243' AS DateTime), N'Newspaper', 576, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1528, CAST(N'2021-03-19T00:01:16.253' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1529, CAST(N'2021-03-19T00:01:16.257' AS DateTime), N'Newspaper', 577, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1530, CAST(N'2021-03-19T00:01:16.257' AS DateTime), N'Newspaper', 577, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1531, CAST(N'2021-03-19T00:01:16.260' AS DateTime), N'Newspaper', 578, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1532, CAST(N'2021-03-19T00:01:16.260' AS DateTime), N'Newspaper', 579, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1533, CAST(N'2021-03-19T00:01:16.263' AS DateTime), N'Newspaper', 580, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1534, CAST(N'2021-03-19T00:01:16.267' AS DateTime), N'Newspaper', 573, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1535, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 574, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1536, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 575, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1537, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 576, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1538, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 578, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1539, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 579, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1540, CAST(N'2021-03-19T00:01:16.270' AS DateTime), N'Newspaper', 580, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1541, CAST(N'2021-03-19T00:01:16.293' AS DateTime), N'Patent', 581, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1542, CAST(N'2021-03-19T00:01:16.300' AS DateTime), N'Patent', 582, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1543, CAST(N'2021-03-19T00:01:16.303' AS DateTime), N'Patent', 583, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1544, CAST(N'2021-03-19T00:01:16.307' AS DateTime), N'Patent', 584, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1545, CAST(N'2021-03-19T00:01:16.317' AS DateTime), N'Author', 241, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1546, CAST(N'2021-03-19T00:01:16.330' AS DateTime), N'Author', 242, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1547, CAST(N'2021-03-19T00:01:16.333' AS DateTime), N'Patent', 585, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1548, CAST(N'2021-03-19T00:01:16.333' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1549, CAST(N'2021-03-19T00:01:16.340' AS DateTime), N'Patent', 586, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1550, CAST(N'2021-03-19T00:01:16.340' AS DateTime), N'Patent', 586, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1551, CAST(N'2021-03-19T00:01:16.347' AS DateTime), N'Patent', 587, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1552, CAST(N'2021-03-19T00:01:16.350' AS DateTime), N'Patent', 588, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1553, CAST(N'2021-03-19T00:01:16.353' AS DateTime), N'Patent', 589, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1554, CAST(N'2021-03-19T00:01:16.360' AS DateTime), N'Patent', 581, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1555, CAST(N'2021-03-19T00:01:16.360' AS DateTime), N'Patent', 582, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1556, CAST(N'2021-03-19T00:01:16.363' AS DateTime), N'Patent', 583, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1557, CAST(N'2021-03-19T00:01:16.363' AS DateTime), N'Patent', 584, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1558, CAST(N'2021-03-19T00:01:16.363' AS DateTime), N'Patent', 585, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1559, CAST(N'2021-03-19T00:01:16.363' AS DateTime), N'Patent', 587, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1560, CAST(N'2021-03-19T00:01:16.363' AS DateTime), N'Patent', 588, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1561, CAST(N'2021-03-19T00:01:16.367' AS DateTime), N'Patent', 589, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1562, CAST(N'2021-03-19T00:01:16.367' AS DateTime), N'Author', 241, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1563, CAST(N'2021-03-19T00:01:16.367' AS DateTime), N'Author', 242, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1564, CAST(N'2021-03-19T00:01:16.370' AS DateTime), N'Book', 590, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1565, CAST(N'2021-03-19T00:01:16.377' AS DateTime), N'Author', 243, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1566, CAST(N'2021-03-19T00:01:16.377' AS DateTime), N'Author', 244, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1567, CAST(N'2021-03-19T00:01:16.380' AS DateTime), N'Book', 591, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1568, CAST(N'2021-03-19T00:01:16.383' AS DateTime), N'Author', 245, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1569, CAST(N'2021-03-19T00:01:16.390' AS DateTime), N'Patent', 592, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1570, CAST(N'2021-03-19T00:01:16.393' AS DateTime), N'Author', 246, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1571, CAST(N'2021-03-19T00:01:16.393' AS DateTime), N'Book', 593, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1572, CAST(N'2021-03-19T00:01:16.400' AS DateTime), N'Patent', 594, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1573, CAST(N'2021-03-19T00:01:16.407' AS DateTime), N'Book', 595, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1574, CAST(N'2021-03-19T00:01:16.413' AS DateTime), N'Book', 596, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1575, CAST(N'2021-03-19T00:01:16.423' AS DateTime), N'Book', 597, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1576, CAST(N'2021-03-19T00:01:16.433' AS DateTime), N'Book', 590, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1577, CAST(N'2021-03-19T00:01:16.433' AS DateTime), N'Book', 591, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1578, CAST(N'2021-03-19T00:01:16.433' AS DateTime), N'Book', 593, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1579, CAST(N'2021-03-19T00:01:16.433' AS DateTime), N'Book', 595, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1580, CAST(N'2021-03-19T00:01:16.437' AS DateTime), N'Book', 596, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1581, CAST(N'2021-03-19T00:01:16.437' AS DateTime), N'Book', 597, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1582, CAST(N'2021-03-19T00:01:16.437' AS DateTime), N'Patent', 592, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1583, CAST(N'2021-03-19T00:01:16.437' AS DateTime), N'Patent', 594, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1584, CAST(N'2021-03-19T00:01:16.437' AS DateTime), N'Author', 243, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1585, CAST(N'2021-03-19T00:01:16.440' AS DateTime), N'Author', 244, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1586, CAST(N'2021-03-19T00:01:16.440' AS DateTime), N'Author', 245, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1587, CAST(N'2021-03-19T00:01:16.440' AS DateTime), N'Author', 246, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1588, CAST(N'2021-03-19T00:02:24.373' AS DateTime), N'Author', 247, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1589, CAST(N'2021-03-19T00:02:24.440' AS DateTime), N'Author', 248, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1590, CAST(N'2021-03-19T00:02:24.443' AS DateTime), N'Author', 249, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1591, CAST(N'2021-03-19T00:02:24.447' AS DateTime), N'Author', 250, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1592, CAST(N'2021-03-19T00:02:24.450' AS DateTime), N'Author', 251, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1593, CAST(N'2021-03-19T00:02:24.460' AS DateTime), N'Author', 252, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1594, CAST(N'2021-03-19T00:02:24.480' AS DateTime), N'Patent', 598, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1595, CAST(N'2021-03-19T00:02:24.587' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1596, CAST(N'2021-03-19T00:02:24.623' AS DateTime), N'Author', 253, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1597, CAST(N'2021-03-19T00:02:24.627' AS DateTime), N'Author', 253, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1598, CAST(N'2021-03-19T00:02:24.627' AS DateTime), N'Author', 254, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1599, CAST(N'2021-03-19T00:02:24.630' AS DateTime), N'Author', 255, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1600, CAST(N'2021-03-19T00:02:24.630' AS DateTime), N'Author', 256, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1601, CAST(N'2021-03-19T00:02:24.637' AS DateTime), N'Author', 257, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1602, CAST(N'2021-03-19T00:02:24.650' AS DateTime), N'Patent', 598, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1603, CAST(N'2021-03-19T00:02:24.667' AS DateTime), N'Author', 247, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1604, CAST(N'2021-03-19T00:02:24.677' AS DateTime), N'Author', 248, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1605, CAST(N'2021-03-19T00:02:24.690' AS DateTime), N'Author', 249, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1606, CAST(N'2021-03-19T00:02:24.700' AS DateTime), N'Author', 250, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1607, CAST(N'2021-03-19T00:02:24.720' AS DateTime), N'Author', 251, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1608, CAST(N'2021-03-19T00:02:24.733' AS DateTime), N'Author', 252, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1609, CAST(N'2021-03-19T00:02:24.750' AS DateTime), N'Author', 254, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1610, CAST(N'2021-03-19T00:02:24.763' AS DateTime), N'Author', 255, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1611, CAST(N'2021-03-19T00:02:24.773' AS DateTime), N'Author', 256, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1612, CAST(N'2021-03-19T00:02:24.787' AS DateTime), N'Author', 257, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1613, CAST(N'2021-03-19T00:02:24.823' AS DateTime), N'Book', 599, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1614, CAST(N'2021-03-19T00:02:24.827' AS DateTime), N'Book', 600, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1615, CAST(N'2021-03-19T00:02:24.833' AS DateTime), N'Book', 601, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1616, CAST(N'2021-03-19T00:02:24.833' AS DateTime), N'Book', 602, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1617, CAST(N'2021-03-19T00:02:24.843' AS DateTime), N'Book', 603, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1618, CAST(N'2021-03-19T00:02:24.847' AS DateTime), N'Book', 604, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1619, CAST(N'2021-03-19T00:02:24.850' AS DateTime), N'Book', 605, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1620, CAST(N'2021-03-19T00:02:24.850' AS DateTime), N'Book', 606, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1621, CAST(N'2021-03-19T00:02:24.863' AS DateTime), N'Author', 258, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1622, CAST(N'2021-03-19T00:02:24.883' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1623, CAST(N'2021-03-19T00:02:24.887' AS DateTime), N'Book', 607, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1624, CAST(N'2021-03-19T00:02:24.900' AS DateTime), N'Book', 607, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1625, CAST(N'2021-03-19T00:02:24.920' AS DateTime), N'Book', 608, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1626, CAST(N'2021-03-19T00:02:24.937' AS DateTime), N'Book', 609, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1627, CAST(N'2021-03-19T00:02:24.957' AS DateTime), N'Book', 610, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1628, CAST(N'2021-03-19T00:02:24.993' AS DateTime), N'Book', 611, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1629, CAST(N'2021-03-19T00:02:25.013' AS DateTime), N'Book', 599, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1630, CAST(N'2021-03-19T00:02:25.013' AS DateTime), N'Book', 600, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1631, CAST(N'2021-03-19T00:02:25.017' AS DateTime), N'Book', 601, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1632, CAST(N'2021-03-19T00:02:25.020' AS DateTime), N'Book', 602, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1633, CAST(N'2021-03-19T00:02:25.020' AS DateTime), N'Book', 603, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1634, CAST(N'2021-03-19T00:02:25.020' AS DateTime), N'Book', 604, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1635, CAST(N'2021-03-19T00:02:25.020' AS DateTime), N'Book', 605, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1636, CAST(N'2021-03-19T00:02:25.027' AS DateTime), N'Book', 606, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1637, CAST(N'2021-03-19T00:02:25.030' AS DateTime), N'Book', 608, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1638, CAST(N'2021-03-19T00:02:25.030' AS DateTime), N'Book', 609, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1639, CAST(N'2021-03-19T00:02:25.030' AS DateTime), N'Book', 610, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1640, CAST(N'2021-03-19T00:02:25.030' AS DateTime), N'Book', 611, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1641, CAST(N'2021-03-19T00:02:25.043' AS DateTime), N'Author', 258, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1642, CAST(N'2021-03-19T00:02:25.063' AS DateTime), N'Newspaper', 612, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1643, CAST(N'2021-03-19T00:02:25.067' AS DateTime), N'Newspaper', 613, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1644, CAST(N'2021-03-19T00:02:25.070' AS DateTime), N'Newspaper', 614, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1645, CAST(N'2021-03-19T00:02:25.073' AS DateTime), N'Newspaper', 615, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1646, CAST(N'2021-03-19T00:02:25.080' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1647, CAST(N'2021-03-19T00:02:25.087' AS DateTime), N'Newspaper', 616, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1648, CAST(N'2021-03-19T00:02:25.087' AS DateTime), N'Newspaper', 616, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1649, CAST(N'2021-03-19T00:02:25.090' AS DateTime), N'Newspaper', 617, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1650, CAST(N'2021-03-19T00:02:25.090' AS DateTime), N'Newspaper', 618, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1651, CAST(N'2021-03-19T00:02:25.090' AS DateTime), N'Newspaper', 619, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1652, CAST(N'2021-03-19T00:02:25.097' AS DateTime), N'Newspaper', 612, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1653, CAST(N'2021-03-19T00:02:25.097' AS DateTime), N'Newspaper', 613, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1654, CAST(N'2021-03-19T00:02:25.100' AS DateTime), N'Newspaper', 614, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1655, CAST(N'2021-03-19T00:02:25.100' AS DateTime), N'Newspaper', 615, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1656, CAST(N'2021-03-19T00:02:25.100' AS DateTime), N'Newspaper', 617, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1657, CAST(N'2021-03-19T00:02:25.100' AS DateTime), N'Newspaper', 618, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1658, CAST(N'2021-03-19T00:02:25.100' AS DateTime), N'Newspaper', 619, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1659, CAST(N'2021-03-19T00:02:25.127' AS DateTime), N'Patent', 620, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1660, CAST(N'2021-03-19T00:02:25.133' AS DateTime), N'Patent', 621, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1661, CAST(N'2021-03-19T00:02:25.157' AS DateTime), N'Patent', 622, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1662, CAST(N'2021-03-19T00:02:25.187' AS DateTime), N'Patent', 623, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1663, CAST(N'2021-03-19T00:02:25.207' AS DateTime), N'Author', 259, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1664, CAST(N'2021-03-19T00:02:25.230' AS DateTime), N'Author', 260, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1665, CAST(N'2021-03-19T00:02:25.250' AS DateTime), N'Patent', 624, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1666, CAST(N'2021-03-19T00:02:25.287' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1667, CAST(N'2021-03-19T00:02:25.310' AS DateTime), N'Patent', 625, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1668, CAST(N'2021-03-19T00:02:25.320' AS DateTime), N'Patent', 625, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1669, CAST(N'2021-03-19T00:02:25.327' AS DateTime), N'Patent', 626, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1670, CAST(N'2021-03-19T00:02:25.330' AS DateTime), N'Patent', 627, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1671, CAST(N'2021-03-19T00:02:25.333' AS DateTime), N'Patent', 628, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1672, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 620, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1673, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 621, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1674, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 622, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1675, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 623, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1676, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 624, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1677, CAST(N'2021-03-19T00:02:25.343' AS DateTime), N'Patent', 626, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1678, CAST(N'2021-03-19T00:02:25.347' AS DateTime), N'Patent', 627, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1679, CAST(N'2021-03-19T00:02:25.347' AS DateTime), N'Patent', 628, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1680, CAST(N'2021-03-19T00:02:25.357' AS DateTime), N'Author', 259, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1681, CAST(N'2021-03-19T00:02:25.360' AS DateTime), N'Author', 260, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1682, CAST(N'2021-03-19T00:02:25.370' AS DateTime), N'Book', 629, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1683, CAST(N'2021-03-19T00:02:25.383' AS DateTime), N'Author', 261, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1684, CAST(N'2021-03-19T00:02:25.387' AS DateTime), N'Author', 262, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1685, CAST(N'2021-03-19T00:02:25.407' AS DateTime), N'Book', 630, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1686, CAST(N'2021-03-19T00:02:25.440' AS DateTime), N'Author', 263, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1687, CAST(N'2021-03-19T00:02:25.470' AS DateTime), N'Patent', 631, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1688, CAST(N'2021-03-19T00:02:25.507' AS DateTime), N'Author', 264, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1689, CAST(N'2021-03-19T00:02:25.527' AS DateTime), N'Book', 632, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1690, CAST(N'2021-03-19T00:02:25.570' AS DateTime), N'Patent', 633, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1691, CAST(N'2021-03-19T00:02:25.600' AS DateTime), N'Book', 634, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1692, CAST(N'2021-03-19T00:02:25.610' AS DateTime), N'Book', 635, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1693, CAST(N'2021-03-19T00:02:25.620' AS DateTime), N'Book', 636, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1694, CAST(N'2021-03-19T00:02:25.630' AS DateTime), N'Book', 629, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1695, CAST(N'2021-03-19T00:02:25.630' AS DateTime), N'Book', 630, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1696, CAST(N'2021-03-19T00:02:25.630' AS DateTime), N'Book', 632, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1697, CAST(N'2021-03-19T00:02:25.630' AS DateTime), N'Book', 634, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1698, CAST(N'2021-03-19T00:02:25.633' AS DateTime), N'Book', 635, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1699, CAST(N'2021-03-19T00:02:25.633' AS DateTime), N'Book', 636, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1700, CAST(N'2021-03-19T00:02:25.637' AS DateTime), N'Patent', 631, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1701, CAST(N'2021-03-19T00:02:25.637' AS DateTime), N'Patent', 633, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1702, CAST(N'2021-03-19T00:02:25.650' AS DateTime), N'Author', 261, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1703, CAST(N'2021-03-19T00:02:25.663' AS DateTime), N'Author', 262, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1704, CAST(N'2021-03-19T00:02:25.677' AS DateTime), N'Author', 263, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1705, CAST(N'2021-03-19T00:02:25.690' AS DateTime), N'Author', 264, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1706, CAST(N'2021-03-19T00:02:38.427' AS DateTime), N'Author', 265, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1707, CAST(N'2021-03-19T00:02:38.500' AS DateTime), N'Author', 266, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1708, CAST(N'2021-03-19T00:02:38.500' AS DateTime), N'Author', 267, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1709, CAST(N'2021-03-19T00:02:38.500' AS DateTime), N'Author', 268, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1710, CAST(N'2021-03-19T00:02:38.507' AS DateTime), N'Author', 269, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1711, CAST(N'2021-03-19T00:02:38.520' AS DateTime), N'Author', 270, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1712, CAST(N'2021-03-19T00:02:38.550' AS DateTime), N'Patent', 637, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1713, CAST(N'2021-03-19T00:02:38.677' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1714, CAST(N'2021-03-19T00:02:38.713' AS DateTime), N'Author', 271, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1715, CAST(N'2021-03-19T00:02:38.720' AS DateTime), N'Author', 271, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1716, CAST(N'2021-03-19T00:02:38.720' AS DateTime), N'Author', 272, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1717, CAST(N'2021-03-19T00:02:38.723' AS DateTime), N'Author', 273, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1718, CAST(N'2021-03-19T00:02:38.723' AS DateTime), N'Author', 274, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1719, CAST(N'2021-03-19T00:02:38.730' AS DateTime), N'Author', 275, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1720, CAST(N'2021-03-19T00:02:38.737' AS DateTime), N'Patent', 637, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1721, CAST(N'2021-03-19T00:02:38.740' AS DateTime), N'Author', 265, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1722, CAST(N'2021-03-19T00:02:38.740' AS DateTime), N'Author', 266, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1723, CAST(N'2021-03-19T00:02:38.740' AS DateTime), N'Author', 267, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1724, CAST(N'2021-03-19T00:02:38.740' AS DateTime), N'Author', 268, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1725, CAST(N'2021-03-19T00:02:38.740' AS DateTime), N'Author', 269, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1726, CAST(N'2021-03-19T00:02:38.743' AS DateTime), N'Author', 270, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1727, CAST(N'2021-03-19T00:02:38.743' AS DateTime), N'Author', 272, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1728, CAST(N'2021-03-19T00:02:38.743' AS DateTime), N'Author', 273, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1729, CAST(N'2021-03-19T00:02:38.743' AS DateTime), N'Author', 274, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1730, CAST(N'2021-03-19T00:02:38.743' AS DateTime), N'Author', 275, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1731, CAST(N'2021-03-19T00:02:38.800' AS DateTime), N'Book', 638, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1732, CAST(N'2021-03-19T00:02:38.840' AS DateTime), N'Book', 639, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1733, CAST(N'2021-03-19T00:02:38.867' AS DateTime), N'Book', 640, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1734, CAST(N'2021-03-19T00:02:38.890' AS DateTime), N'Book', 641, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1735, CAST(N'2021-03-19T00:02:38.920' AS DateTime), N'Book', 642, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1736, CAST(N'2021-03-19T00:02:38.927' AS DateTime), N'Book', 643, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1737, CAST(N'2021-03-19T00:02:38.933' AS DateTime), N'Book', 644, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1738, CAST(N'2021-03-19T00:02:38.933' AS DateTime), N'Book', 645, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1739, CAST(N'2021-03-19T00:02:38.950' AS DateTime), N'Author', 276, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1740, CAST(N'2021-03-19T00:02:38.967' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1741, CAST(N'2021-03-19T00:02:38.970' AS DateTime), N'Book', 646, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1742, CAST(N'2021-03-19T00:02:38.973' AS DateTime), N'Book', 646, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1743, CAST(N'2021-03-19T00:02:38.977' AS DateTime), N'Book', 647, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1744, CAST(N'2021-03-19T00:02:38.980' AS DateTime), N'Book', 648, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1745, CAST(N'2021-03-19T00:02:38.980' AS DateTime), N'Book', 649, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1746, CAST(N'2021-03-19T00:02:38.990' AS DateTime), N'Book', 650, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1747, CAST(N'2021-03-19T00:02:38.990' AS DateTime), N'Book', 638, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1748, CAST(N'2021-03-19T00:02:38.990' AS DateTime), N'Book', 639, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1749, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 640, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1750, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 641, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1751, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 642, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1752, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 643, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1753, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 644, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1754, CAST(N'2021-03-19T00:02:38.993' AS DateTime), N'Book', 645, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1755, CAST(N'2021-03-19T00:02:38.997' AS DateTime), N'Book', 647, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1756, CAST(N'2021-03-19T00:02:38.997' AS DateTime), N'Book', 648, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1757, CAST(N'2021-03-19T00:02:38.997' AS DateTime), N'Book', 649, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1758, CAST(N'2021-03-19T00:02:38.997' AS DateTime), N'Book', 650, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1759, CAST(N'2021-03-19T00:02:39.013' AS DateTime), N'Author', 276, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1760, CAST(N'2021-03-19T00:02:39.037' AS DateTime), N'Newspaper', 651, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1761, CAST(N'2021-03-19T00:02:39.050' AS DateTime), N'Newspaper', 652, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1762, CAST(N'2021-03-19T00:02:39.067' AS DateTime), N'Newspaper', 653, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1763, CAST(N'2021-03-19T00:02:39.077' AS DateTime), N'Newspaper', 654, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1764, CAST(N'2021-03-19T00:02:39.093' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1765, CAST(N'2021-03-19T00:02:39.103' AS DateTime), N'Newspaper', 655, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1766, CAST(N'2021-03-19T00:02:39.113' AS DateTime), N'Newspaper', 655, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1767, CAST(N'2021-03-19T00:02:39.120' AS DateTime), N'Newspaper', 656, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1768, CAST(N'2021-03-19T00:02:39.130' AS DateTime), N'Newspaper', 657, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1769, CAST(N'2021-03-19T00:02:39.143' AS DateTime), N'Newspaper', 658, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1770, CAST(N'2021-03-19T00:02:39.157' AS DateTime), N'Newspaper', 651, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1771, CAST(N'2021-03-19T00:02:39.157' AS DateTime), N'Newspaper', 652, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1772, CAST(N'2021-03-19T00:02:39.160' AS DateTime), N'Newspaper', 653, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1773, CAST(N'2021-03-19T00:02:39.160' AS DateTime), N'Newspaper', 654, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1774, CAST(N'2021-03-19T00:02:39.160' AS DateTime), N'Newspaper', 656, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1775, CAST(N'2021-03-19T00:02:39.160' AS DateTime), N'Newspaper', 657, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1776, CAST(N'2021-03-19T00:02:39.160' AS DateTime), N'Newspaper', 658, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1777, CAST(N'2021-03-19T00:02:39.187' AS DateTime), N'Patent', 659, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1778, CAST(N'2021-03-19T00:02:39.193' AS DateTime), N'Patent', 660, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1779, CAST(N'2021-03-19T00:02:39.200' AS DateTime), N'Patent', 661, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1780, CAST(N'2021-03-19T00:02:39.203' AS DateTime), N'Patent', 662, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1781, CAST(N'2021-03-19T00:02:39.213' AS DateTime), N'Author', 277, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1782, CAST(N'2021-03-19T00:02:39.230' AS DateTime), N'Author', 278, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1783, CAST(N'2021-03-19T00:02:39.237' AS DateTime), N'Patent', 663, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1784, CAST(N'2021-03-19T00:02:39.240' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1785, CAST(N'2021-03-19T00:02:39.263' AS DateTime), N'Patent', 664, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1786, CAST(N'2021-03-19T00:02:39.280' AS DateTime), N'Patent', 664, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1787, CAST(N'2021-03-19T00:02:39.310' AS DateTime), N'Patent', 665, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1788, CAST(N'2021-03-19T00:02:39.333' AS DateTime), N'Patent', 666, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1789, CAST(N'2021-03-19T00:02:39.357' AS DateTime), N'Patent', 667, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1790, CAST(N'2021-03-19T00:02:39.377' AS DateTime), N'Patent', 659, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1791, CAST(N'2021-03-19T00:02:39.377' AS DateTime), N'Patent', 660, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1792, CAST(N'2021-03-19T00:02:39.380' AS DateTime), N'Patent', 661, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1793, CAST(N'2021-03-19T00:02:39.380' AS DateTime), N'Patent', 662, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1794, CAST(N'2021-03-19T00:02:39.380' AS DateTime), N'Patent', 663, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1795, CAST(N'2021-03-19T00:02:39.383' AS DateTime), N'Patent', 665, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1796, CAST(N'2021-03-19T00:02:39.383' AS DateTime), N'Patent', 666, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1797, CAST(N'2021-03-19T00:02:39.383' AS DateTime), N'Patent', 667, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1798, CAST(N'2021-03-19T00:02:39.397' AS DateTime), N'Author', 277, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1799, CAST(N'2021-03-19T00:02:39.407' AS DateTime), N'Author', 278, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1800, CAST(N'2021-03-19T00:02:39.423' AS DateTime), N'Book', 668, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1801, CAST(N'2021-03-19T00:02:39.433' AS DateTime), N'Author', 279, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1802, CAST(N'2021-03-19T00:02:39.443' AS DateTime), N'Author', 280, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1803, CAST(N'2021-03-19T00:02:39.450' AS DateTime), N'Book', 669, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1804, CAST(N'2021-03-19T00:02:39.453' AS DateTime), N'Author', 281, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1805, CAST(N'2021-03-19T00:02:39.470' AS DateTime), N'Patent', 670, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1806, CAST(N'2021-03-19T00:02:39.473' AS DateTime), N'Author', 282, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1807, CAST(N'2021-03-19T00:02:39.477' AS DateTime), N'Book', 671, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1808, CAST(N'2021-03-19T00:02:39.480' AS DateTime), N'Patent', 672, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1809, CAST(N'2021-03-19T00:02:39.487' AS DateTime), N'Book', 673, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1810, CAST(N'2021-03-19T00:02:39.493' AS DateTime), N'Book', 674, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1811, CAST(N'2021-03-19T00:02:39.570' AS DateTime), N'Book', 675, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1812, CAST(N'2021-03-19T00:02:39.640' AS DateTime), N'Book', 668, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1813, CAST(N'2021-03-19T00:02:39.640' AS DateTime), N'Book', 669, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1814, CAST(N'2021-03-19T00:02:39.643' AS DateTime), N'Book', 671, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1815, CAST(N'2021-03-19T00:02:39.643' AS DateTime), N'Book', 673, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1816, CAST(N'2021-03-19T00:02:39.643' AS DateTime), N'Book', 674, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1817, CAST(N'2021-03-19T00:02:39.643' AS DateTime), N'Book', 675, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1818, CAST(N'2021-03-19T00:02:39.650' AS DateTime), N'Patent', 670, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1819, CAST(N'2021-03-19T00:02:39.650' AS DateTime), N'Patent', 672, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1820, CAST(N'2021-03-19T00:02:39.663' AS DateTime), N'Author', 279, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1821, CAST(N'2021-03-19T00:02:39.673' AS DateTime), N'Author', 280, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1822, CAST(N'2021-03-19T00:02:39.677' AS DateTime), N'Author', 281, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1823, CAST(N'2021-03-19T00:02:39.677' AS DateTime), N'Author', 282, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1824, CAST(N'2021-03-19T00:03:20.423' AS DateTime), N'Author', 283, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1825, CAST(N'2021-03-19T00:03:20.493' AS DateTime), N'Author', 284, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1826, CAST(N'2021-03-19T00:03:20.497' AS DateTime), N'Author', 285, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1827, CAST(N'2021-03-19T00:03:20.497' AS DateTime), N'Author', 286, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1828, CAST(N'2021-03-19T00:03:20.500' AS DateTime), N'Author', 287, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1829, CAST(N'2021-03-19T00:03:20.510' AS DateTime), N'Author', 288, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1830, CAST(N'2021-03-19T00:03:20.527' AS DateTime), N'Patent', 676, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1831, CAST(N'2021-03-19T00:03:20.623' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1832, CAST(N'2021-03-19T00:03:20.660' AS DateTime), N'Author', 289, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1833, CAST(N'2021-03-19T00:03:20.663' AS DateTime), N'Author', 289, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1834, CAST(N'2021-03-19T00:03:20.667' AS DateTime), N'Author', 290, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1835, CAST(N'2021-03-19T00:03:20.667' AS DateTime), N'Author', 291, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1836, CAST(N'2021-03-19T00:03:20.670' AS DateTime), N'Author', 292, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1837, CAST(N'2021-03-19T00:03:20.673' AS DateTime), N'Author', 293, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1838, CAST(N'2021-03-19T00:03:20.683' AS DateTime), N'Patent', 676, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1839, CAST(N'2021-03-19T00:03:20.687' AS DateTime), N'Author', 283, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1840, CAST(N'2021-03-19T00:03:20.687' AS DateTime), N'Author', 284, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1841, CAST(N'2021-03-19T00:03:20.687' AS DateTime), N'Author', 285, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1842, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 286, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1843, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 287, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1844, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 288, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1845, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 290, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1846, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 291, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1847, CAST(N'2021-03-19T00:03:20.690' AS DateTime), N'Author', 292, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1848, CAST(N'2021-03-19T00:03:20.693' AS DateTime), N'Author', 293, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1849, CAST(N'2021-03-19T00:03:20.720' AS DateTime), N'Book', 677, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1850, CAST(N'2021-03-19T00:03:20.723' AS DateTime), N'Book', 678, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1851, CAST(N'2021-03-19T00:03:20.730' AS DateTime), N'Book', 679, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1852, CAST(N'2021-03-19T00:03:20.730' AS DateTime), N'Book', 680, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1853, CAST(N'2021-03-19T00:03:20.740' AS DateTime), N'Book', 681, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1854, CAST(N'2021-03-19T00:03:20.743' AS DateTime), N'Book', 682, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1855, CAST(N'2021-03-19T00:03:20.743' AS DateTime), N'Book', 683, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1856, CAST(N'2021-03-19T00:03:20.747' AS DateTime), N'Book', 684, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1857, CAST(N'2021-03-19T00:03:20.757' AS DateTime), N'Author', 294, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1858, CAST(N'2021-03-19T00:03:20.780' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1859, CAST(N'2021-03-19T00:03:20.780' AS DateTime), N'Book', 685, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1860, CAST(N'2021-03-19T00:03:20.783' AS DateTime), N'Book', 685, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1861, CAST(N'2021-03-19T00:03:20.787' AS DateTime), N'Book', 686, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1862, CAST(N'2021-03-19T00:03:20.787' AS DateTime), N'Book', 687, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1863, CAST(N'2021-03-19T00:03:20.790' AS DateTime), N'Book', 688, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1864, CAST(N'2021-03-19T00:03:20.800' AS DateTime), N'Book', 689, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1865, CAST(N'2021-03-19T00:03:20.800' AS DateTime), N'Book', 677, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1866, CAST(N'2021-03-19T00:03:20.800' AS DateTime), N'Book', 678, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1867, CAST(N'2021-03-19T00:03:20.803' AS DateTime), N'Book', 679, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1868, CAST(N'2021-03-19T00:03:20.803' AS DateTime), N'Book', 680, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1869, CAST(N'2021-03-19T00:03:20.803' AS DateTime), N'Book', 681, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1870, CAST(N'2021-03-19T00:03:20.803' AS DateTime), N'Book', 682, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1871, CAST(N'2021-03-19T00:03:20.803' AS DateTime), N'Book', 683, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1872, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Book', 684, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1873, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Book', 686, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1874, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Book', 687, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1875, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Book', 688, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1876, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Book', 689, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1877, CAST(N'2021-03-19T00:03:20.807' AS DateTime), N'Author', 294, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1878, CAST(N'2021-03-19T00:03:20.820' AS DateTime), N'Newspaper', 690, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1879, CAST(N'2021-03-19T00:03:20.823' AS DateTime), N'Newspaper', 691, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1880, CAST(N'2021-03-19T00:03:20.827' AS DateTime), N'Newspaper', 692, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1881, CAST(N'2021-03-19T00:03:20.830' AS DateTime), N'Newspaper', 693, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1882, CAST(N'2021-03-19T00:03:20.837' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1883, CAST(N'2021-03-19T00:03:20.840' AS DateTime), N'Newspaper', 694, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1884, CAST(N'2021-03-19T00:03:20.843' AS DateTime), N'Newspaper', 694, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1885, CAST(N'2021-03-19T00:03:20.843' AS DateTime), N'Newspaper', 695, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1886, CAST(N'2021-03-19T00:03:20.847' AS DateTime), N'Newspaper', 696, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1887, CAST(N'2021-03-19T00:03:20.847' AS DateTime), N'Newspaper', 697, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1888, CAST(N'2021-03-19T00:03:20.853' AS DateTime), N'Newspaper', 690, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1889, CAST(N'2021-03-19T00:03:20.853' AS DateTime), N'Newspaper', 691, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1890, CAST(N'2021-03-19T00:03:20.853' AS DateTime), N'Newspaper', 692, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1891, CAST(N'2021-03-19T00:03:20.853' AS DateTime), N'Newspaper', 693, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1892, CAST(N'2021-03-19T00:03:20.857' AS DateTime), N'Newspaper', 695, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1893, CAST(N'2021-03-19T00:03:20.857' AS DateTime), N'Newspaper', 696, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1894, CAST(N'2021-03-19T00:03:20.857' AS DateTime), N'Newspaper', 697, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1895, CAST(N'2021-03-19T00:03:20.870' AS DateTime), N'Patent', 698, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1896, CAST(N'2021-03-19T00:03:20.877' AS DateTime), N'Patent', 699, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1897, CAST(N'2021-03-19T00:03:20.880' AS DateTime), N'Patent', 700, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1898, CAST(N'2021-03-19T00:03:20.883' AS DateTime), N'Patent', 701, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1899, CAST(N'2021-03-19T00:03:20.893' AS DateTime), N'Author', 295, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1900, CAST(N'2021-03-19T00:03:20.907' AS DateTime), N'Author', 296, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1901, CAST(N'2021-03-19T00:03:20.910' AS DateTime), N'Patent', 702, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1902, CAST(N'2021-03-19T00:03:20.913' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1903, CAST(N'2021-03-19T00:03:20.920' AS DateTime), N'Patent', 703, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1904, CAST(N'2021-03-19T00:03:20.920' AS DateTime), N'Patent', 703, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1905, CAST(N'2021-03-19T00:03:20.927' AS DateTime), N'Patent', 704, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1906, CAST(N'2021-03-19T00:03:20.930' AS DateTime), N'Patent', 705, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1907, CAST(N'2021-03-19T00:03:20.933' AS DateTime), N'Patent', 706, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1908, CAST(N'2021-03-19T00:03:20.943' AS DateTime), N'Patent', 698, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1909, CAST(N'2021-03-19T00:03:20.943' AS DateTime), N'Patent', 699, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1910, CAST(N'2021-03-19T00:03:20.943' AS DateTime), N'Patent', 700, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1911, CAST(N'2021-03-19T00:03:20.943' AS DateTime), N'Patent', 701, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1912, CAST(N'2021-03-19T00:03:20.947' AS DateTime), N'Patent', 702, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1913, CAST(N'2021-03-19T00:03:20.947' AS DateTime), N'Patent', 704, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1914, CAST(N'2021-03-19T00:03:20.947' AS DateTime), N'Patent', 705, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1915, CAST(N'2021-03-19T00:03:20.947' AS DateTime), N'Patent', 706, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1916, CAST(N'2021-03-19T00:03:20.947' AS DateTime), N'Author', 295, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1917, CAST(N'2021-03-19T00:03:20.950' AS DateTime), N'Author', 296, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1918, CAST(N'2021-03-19T00:03:20.950' AS DateTime), N'Book', 707, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1919, CAST(N'2021-03-19T00:03:20.953' AS DateTime), N'Author', 297, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1920, CAST(N'2021-03-19T00:03:20.957' AS DateTime), N'Author', 298, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1921, CAST(N'2021-03-19T00:03:20.960' AS DateTime), N'Book', 708, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1922, CAST(N'2021-03-19T00:03:20.963' AS DateTime), N'Author', 299, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1923, CAST(N'2021-03-19T00:03:20.967' AS DateTime), N'Patent', 709, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1924, CAST(N'2021-03-19T00:03:20.970' AS DateTime), N'Author', 300, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1925, CAST(N'2021-03-19T00:03:20.973' AS DateTime), N'Book', 710, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1926, CAST(N'2021-03-19T00:03:20.980' AS DateTime), N'Patent', 711, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1927, CAST(N'2021-03-19T00:03:20.983' AS DateTime), N'Book', 712, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1928, CAST(N'2021-03-19T00:03:20.993' AS DateTime), N'Book', 713, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1929, CAST(N'2021-03-19T00:03:21.000' AS DateTime), N'Book', 714, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1930, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 707, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1931, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 708, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1932, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 710, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1933, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 712, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1934, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 713, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1935, CAST(N'2021-03-19T00:03:21.010' AS DateTime), N'Book', 714, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1936, CAST(N'2021-03-19T00:03:21.013' AS DateTime), N'Patent', 709, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1937, CAST(N'2021-03-19T00:03:21.013' AS DateTime), N'Patent', 711, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1938, CAST(N'2021-03-19T00:03:21.013' AS DateTime), N'Author', 297, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1939, CAST(N'2021-03-19T00:03:21.013' AS DateTime), N'Author', 298, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1940, CAST(N'2021-03-19T00:03:21.017' AS DateTime), N'Author', 299, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1941, CAST(N'2021-03-19T00:03:21.017' AS DateTime), N'Author', 300, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1942, CAST(N'2021-03-19T00:07:06.880' AS DateTime), N'Author', 301, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1943, CAST(N'2021-03-19T00:07:06.970' AS DateTime), N'Author', 301, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1944, CAST(N'2021-03-19T00:07:13.800' AS DateTime), N'Book', 715, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1945, CAST(N'2021-03-19T00:07:13.833' AS DateTime), N'Book', 716, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1946, CAST(N'2021-03-19T00:07:13.847' AS DateTime), N'Book', 717, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1947, CAST(N'2021-03-19T00:07:13.847' AS DateTime), N'Book', 718, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1948, CAST(N'2021-03-19T00:07:13.860' AS DateTime), N'Book', 719, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1949, CAST(N'2021-03-19T00:07:13.863' AS DateTime), N'Book', 720, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1950, CAST(N'2021-03-19T00:07:13.870' AS DateTime), N'Book', 721, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1951, CAST(N'2021-03-19T00:07:13.870' AS DateTime), N'Book', 722, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1952, CAST(N'2021-03-19T00:07:13.890' AS DateTime), N'Author', 302, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1953, CAST(N'2021-03-19T00:07:13.937' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1954, CAST(N'2021-03-19T00:07:13.953' AS DateTime), N'Book', 723, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1955, CAST(N'2021-03-19T00:07:13.957' AS DateTime), N'Book', 723, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1956, CAST(N'2021-03-19T00:07:13.960' AS DateTime), N'Book', 724, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1957, CAST(N'2021-03-19T00:07:13.960' AS DateTime), N'Book', 725, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1958, CAST(N'2021-03-19T00:07:13.963' AS DateTime), N'Book', 726, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1959, CAST(N'2021-03-19T00:07:13.973' AS DateTime), N'Book', 727, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1960, CAST(N'2021-03-19T00:07:13.973' AS DateTime), N'Book', 715, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1961, CAST(N'2021-03-19T00:07:13.977' AS DateTime), N'Book', 716, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1962, CAST(N'2021-03-19T00:07:13.977' AS DateTime), N'Book', 717, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1963, CAST(N'2021-03-19T00:07:13.977' AS DateTime), N'Book', 718, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1964, CAST(N'2021-03-19T00:07:13.977' AS DateTime), N'Book', 719, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1965, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 720, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1966, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 721, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1967, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 722, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1968, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 724, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1969, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 725, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1970, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 726, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1971, CAST(N'2021-03-19T00:07:13.980' AS DateTime), N'Book', 727, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1972, CAST(N'2021-03-19T00:07:13.990' AS DateTime), N'Author', 302, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1973, CAST(N'2021-03-19T00:07:36.017' AS DateTime), N'Author', 303, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1974, CAST(N'2021-03-19T00:07:36.113' AS DateTime), N'Author', 303, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1975, CAST(N'2021-03-19T00:08:44.057' AS DateTime), N'Author', 304, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1976, CAST(N'2021-03-19T00:08:44.143' AS DateTime), N'Author', 304, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1977, CAST(N'2021-03-19T00:08:50.593' AS DateTime), N'Book', 728, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1978, CAST(N'2021-03-19T00:08:50.627' AS DateTime), N'Book', 729, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1979, CAST(N'2021-03-19T00:08:50.640' AS DateTime), N'Book', 730, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1980, CAST(N'2021-03-19T00:08:50.643' AS DateTime), N'Book', 731, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1981, CAST(N'2021-03-19T00:08:50.657' AS DateTime), N'Book', 732, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1982, CAST(N'2021-03-19T00:08:50.660' AS DateTime), N'Book', 733, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1983, CAST(N'2021-03-19T00:08:50.663' AS DateTime), N'Book', 734, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1984, CAST(N'2021-03-19T00:08:50.667' AS DateTime), N'Book', 735, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1985, CAST(N'2021-03-19T00:08:50.680' AS DateTime), N'Author', 305, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1986, CAST(N'2021-03-19T00:08:50.700' AS DateTime), N'Author', 306, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1987, CAST(N'2021-03-19T00:08:50.723' AS DateTime), N'Book', 736, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1988, CAST(N'2021-03-19T00:08:50.820' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1989, CAST(N'2021-03-19T00:08:50.860' AS DateTime), N'Book', 737, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1990, CAST(N'2021-03-19T00:08:50.863' AS DateTime), N'Book', 737, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1991, CAST(N'2021-03-19T00:08:50.867' AS DateTime), N'Book', 738, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1992, CAST(N'2021-03-19T00:08:50.867' AS DateTime), N'Book', 739, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1993, CAST(N'2021-03-19T00:08:50.870' AS DateTime), N'Book', 740, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1994, CAST(N'2021-03-19T00:08:50.880' AS DateTime), N'Book', 741, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1995, CAST(N'2021-03-19T00:08:50.883' AS DateTime), N'Book', 728, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1996, CAST(N'2021-03-19T00:08:50.887' AS DateTime), N'Book', 729, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1997, CAST(N'2021-03-19T00:08:50.887' AS DateTime), N'Book', 730, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1998, CAST(N'2021-03-19T00:08:50.887' AS DateTime), N'Book', 731, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (1999, CAST(N'2021-03-19T00:08:50.887' AS DateTime), N'Book', 732, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2000, CAST(N'2021-03-19T00:08:50.887' AS DateTime), N'Book', 733, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2001, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 734, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2002, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 735, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2003, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 736, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2004, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 738, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2005, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 739, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2006, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 740, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2007, CAST(N'2021-03-19T00:08:50.890' AS DateTime), N'Book', 741, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2008, CAST(N'2021-03-19T00:08:50.900' AS DateTime), N'Author', 305, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2009, CAST(N'2021-03-19T00:08:50.900' AS DateTime), N'Author', 306, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2010, CAST(N'2021-03-19T00:09:00.797' AS DateTime), N'Book', 742, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2011, CAST(N'2021-03-19T00:09:00.850' AS DateTime), N'Book', 743, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2012, CAST(N'2021-03-19T00:09:00.883' AS DateTime), N'Book', 744, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2013, CAST(N'2021-03-19T00:09:00.900' AS DateTime), N'Book', 745, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2014, CAST(N'2021-03-19T00:09:00.933' AS DateTime), N'Book', 746, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2015, CAST(N'2021-03-19T00:09:00.953' AS DateTime), N'Book', 747, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2016, CAST(N'2021-03-19T00:09:00.980' AS DateTime), N'Book', 748, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2017, CAST(N'2021-03-19T00:09:00.987' AS DateTime), N'Book', 749, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2018, CAST(N'2021-03-19T00:09:01.000' AS DateTime), N'Author', 307, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2019, CAST(N'2021-03-19T00:09:01.020' AS DateTime), N'Author', 308, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2020, CAST(N'2021-03-19T00:09:01.047' AS DateTime), N'Book', 750, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2021, CAST(N'2021-03-19T00:09:01.093' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2022, CAST(N'2021-03-19T00:09:01.133' AS DateTime), N'Book', 751, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2023, CAST(N'2021-03-19T00:09:01.147' AS DateTime), N'Book', 751, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2024, CAST(N'2021-03-19T00:09:01.167' AS DateTime), N'Book', 752, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2025, CAST(N'2021-03-19T00:09:01.190' AS DateTime), N'Book', 753, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2026, CAST(N'2021-03-19T00:09:01.213' AS DateTime), N'Book', 754, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2027, CAST(N'2021-03-19T00:09:01.233' AS DateTime), N'Book', 755, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2028, CAST(N'2021-03-19T00:09:01.247' AS DateTime), N'Book', 742, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2029, CAST(N'2021-03-19T00:09:01.247' AS DateTime), N'Book', 743, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2030, CAST(N'2021-03-19T00:09:01.247' AS DateTime), N'Book', 744, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2031, CAST(N'2021-03-19T00:09:01.247' AS DateTime), N'Book', 745, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2032, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 746, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2033, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 747, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2034, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 748, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2035, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 749, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2036, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 752, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2037, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 753, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2038, CAST(N'2021-03-19T00:09:01.250' AS DateTime), N'Book', 754, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2039, CAST(N'2021-03-19T00:09:01.253' AS DateTime), N'Book', 755, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2040, CAST(N'2021-03-19T00:09:01.263' AS DateTime), N'Author', 307, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2041, CAST(N'2021-03-19T00:11:17.570' AS DateTime), N'Book', 756, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2042, CAST(N'2021-03-19T00:11:17.610' AS DateTime), N'Book', 757, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2043, CAST(N'2021-03-19T00:11:17.623' AS DateTime), N'Book', 758, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2044, CAST(N'2021-03-19T00:11:17.627' AS DateTime), N'Book', 759, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2045, CAST(N'2021-03-19T00:11:17.640' AS DateTime), N'Book', 760, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2046, CAST(N'2021-03-19T00:11:17.640' AS DateTime), N'Book', 761, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2047, CAST(N'2021-03-19T00:11:17.647' AS DateTime), N'Book', 762, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2048, CAST(N'2021-03-19T00:11:17.647' AS DateTime), N'Book', 763, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2049, CAST(N'2021-03-19T00:11:17.663' AS DateTime), N'Author', 309, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2050, CAST(N'2021-03-19T00:11:17.680' AS DateTime), N'Author', 310, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2051, CAST(N'2021-03-19T00:11:17.703' AS DateTime), N'Book', 764, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2052, CAST(N'2021-03-19T00:11:17.800' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2053, CAST(N'2021-03-19T00:11:17.840' AS DateTime), N'Book', 765, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2054, CAST(N'2021-03-19T00:11:17.840' AS DateTime), N'Book', 765, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2055, CAST(N'2021-03-19T00:11:17.843' AS DateTime), N'Book', 766, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2056, CAST(N'2021-03-19T00:11:17.847' AS DateTime), N'Book', 767, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2057, CAST(N'2021-03-19T00:11:17.850' AS DateTime), N'Book', 768, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2058, CAST(N'2021-03-19T00:11:17.860' AS DateTime), N'Book', 769, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2059, CAST(N'2021-03-19T00:11:17.863' AS DateTime), N'Book', 756, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2060, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 757, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2061, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 758, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2062, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 759, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2063, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 760, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2064, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 761, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2065, CAST(N'2021-03-19T00:11:17.867' AS DateTime), N'Book', 762, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2066, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 763, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2067, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 764, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2068, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 766, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2069, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 767, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2070, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 768, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2071, CAST(N'2021-03-19T00:11:17.870' AS DateTime), N'Book', 769, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2072, CAST(N'2021-03-19T00:11:17.880' AS DateTime), N'Author', 309, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2073, CAST(N'2021-03-19T00:11:17.883' AS DateTime), N'Author', 310, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2074, CAST(N'2021-03-19T00:11:24.917' AS DateTime), N'Book', 770, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2075, CAST(N'2021-03-19T00:11:24.960' AS DateTime), N'Book', 771, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2076, CAST(N'2021-03-19T00:11:24.973' AS DateTime), N'Book', 772, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2077, CAST(N'2021-03-19T00:11:24.973' AS DateTime), N'Book', 773, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2078, CAST(N'2021-03-19T00:11:24.987' AS DateTime), N'Book', 774, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2079, CAST(N'2021-03-19T00:11:24.990' AS DateTime), N'Book', 775, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2080, CAST(N'2021-03-19T00:11:24.993' AS DateTime), N'Book', 776, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2081, CAST(N'2021-03-19T00:11:24.993' AS DateTime), N'Book', 777, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2082, CAST(N'2021-03-19T00:11:25.010' AS DateTime), N'Author', 311, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2083, CAST(N'2021-03-19T00:11:25.033' AS DateTime), N'Author', 312, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2084, CAST(N'2021-03-19T00:11:25.077' AS DateTime), N'Book', 778, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2085, CAST(N'2021-03-19T00:11:25.120' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2086, CAST(N'2021-03-19T00:11:25.157' AS DateTime), N'Book', 779, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2087, CAST(N'2021-03-19T00:11:25.170' AS DateTime), N'Book', 779, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2088, CAST(N'2021-03-19T00:11:25.190' AS DateTime), N'Book', 780, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2089, CAST(N'2021-03-19T00:11:25.197' AS DateTime), N'Book', 781, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2090, CAST(N'2021-03-19T00:11:25.200' AS DateTime), N'Book', 782, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2091, CAST(N'2021-03-19T00:11:25.210' AS DateTime), N'Book', 783, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2092, CAST(N'2021-03-19T00:11:25.220' AS DateTime), N'Book', 770, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2093, CAST(N'2021-03-19T00:11:25.220' AS DateTime), N'Book', 771, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2094, CAST(N'2021-03-19T00:11:25.220' AS DateTime), N'Book', 772, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2095, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 773, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2096, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 774, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2097, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 775, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2098, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 776, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2099, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 777, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2100, CAST(N'2021-03-19T00:11:25.223' AS DateTime), N'Book', 780, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2101, CAST(N'2021-03-19T00:11:25.227' AS DateTime), N'Book', 781, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2102, CAST(N'2021-03-19T00:11:25.227' AS DateTime), N'Book', 782, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2103, CAST(N'2021-03-19T00:11:25.227' AS DateTime), N'Book', 783, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2104, CAST(N'2021-03-19T00:11:25.240' AS DateTime), N'Author', 311, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2105, CAST(N'2021-03-19T00:11:49.053' AS DateTime), N'Author', 313, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2106, CAST(N'2021-03-19T00:11:49.157' AS DateTime), N'Book', 784, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2107, CAST(N'2021-03-19T00:11:49.307' AS DateTime), N'Book', 784, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2108, CAST(N'2021-03-19T00:11:49.320' AS DateTime), N'Author', 313, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2109, CAST(N'2021-03-19T00:11:54.257' AS DateTime), N'Author', 314, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2110, CAST(N'2021-03-19T00:11:54.343' AS DateTime), N'Book', 785, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2111, CAST(N'2021-03-19T00:17:43.557' AS DateTime), N'Author', 315, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2112, CAST(N'2021-03-19T00:17:43.657' AS DateTime), N'Book', 786, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2113, CAST(N'2021-03-19T00:17:43.823' AS DateTime), N'Book', 786, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2114, CAST(N'2021-03-19T00:17:43.840' AS DateTime), N'Author', 315, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2115, CAST(N'2021-03-19T00:17:52.247' AS DateTime), N'Author', 316, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2116, CAST(N'2021-03-19T00:17:54.303' AS DateTime), N'Book', 787, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2117, CAST(N'2021-03-19T00:30:36.183' AS DateTime), N'Author', 317, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2118, CAST(N'2021-03-19T00:30:36.323' AS DateTime), N'Book', 788, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2119, CAST(N'2021-03-19T00:30:54.307' AS DateTime), N'Book', 788, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2120, CAST(N'2021-03-19T00:30:54.317' AS DateTime), N'Author', 317, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2121, CAST(N'2021-03-19T00:31:42.780' AS DateTime), N'Author', 318, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2122, CAST(N'2021-03-19T00:31:42.910' AS DateTime), N'Book', 789, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2123, CAST(N'2021-03-19T00:32:37.517' AS DateTime), N'Book', 789, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2124, CAST(N'2021-03-19T00:32:37.527' AS DateTime), N'Author', 318, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2125, CAST(N'2021-03-19T00:33:39.753' AS DateTime), N'Author', 319, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2126, CAST(N'2021-03-19T00:33:39.877' AS DateTime), N'Book', 790, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2127, CAST(N'2021-03-19T01:17:04.913' AS DateTime), N'Author', 320, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2128, CAST(N'2021-03-19T01:17:05.020' AS DateTime), N'Book', 791, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2129, CAST(N'2021-03-19T01:17:05.163' AS DateTime), N'Book', 791, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2130, CAST(N'2021-03-19T01:17:05.173' AS DateTime), N'Author', 320, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2131, CAST(N'2021-03-19T01:17:10.083' AS DateTime), N'Author', 321, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2132, CAST(N'2021-03-19T01:17:10.200' AS DateTime), N'Book', 792, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2133, CAST(N'2021-03-19T01:17:10.360' AS DateTime), N'Book', 792, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2134, CAST(N'2021-03-19T01:17:10.373' AS DateTime), N'Author', 321, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2135, CAST(N'2021-03-19T01:17:14.783' AS DateTime), N'Author', 322, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2136, CAST(N'2021-03-19T01:17:14.880' AS DateTime), N'Book', 793, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2137, CAST(N'2021-03-19T01:17:15.033' AS DateTime), N'Book', 793, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2138, CAST(N'2021-03-19T01:17:15.047' AS DateTime), N'Author', 322, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2139, CAST(N'2021-03-19T01:22:48.807' AS DateTime), N'Book', 794, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2140, CAST(N'2021-03-19T01:22:48.833' AS DateTime), N'Book', 795, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2141, CAST(N'2021-03-19T01:22:48.843' AS DateTime), N'Book', 796, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2142, CAST(N'2021-03-19T01:22:48.847' AS DateTime), N'Book', 797, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2143, CAST(N'2021-03-19T01:22:48.857' AS DateTime), N'Book', 798, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2144, CAST(N'2021-03-19T01:22:48.860' AS DateTime), N'Book', 799, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2145, CAST(N'2021-03-19T01:22:48.863' AS DateTime), N'Book', 800, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2146, CAST(N'2021-03-19T01:22:48.863' AS DateTime), N'Book', 801, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2147, CAST(N'2021-03-19T01:22:48.880' AS DateTime), N'Author', 323, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2148, CAST(N'2021-03-19T01:22:48.900' AS DateTime), N'Author', 324, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2149, CAST(N'2021-03-19T01:22:48.923' AS DateTime), N'Book', 802, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2150, CAST(N'2021-03-19T01:22:49.010' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2151, CAST(N'2021-03-19T01:22:49.050' AS DateTime), N'Book', 803, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2152, CAST(N'2021-03-19T01:22:49.053' AS DateTime), N'Book', 803, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2153, CAST(N'2021-03-19T01:22:49.057' AS DateTime), N'Book', 804, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2154, CAST(N'2021-03-19T01:22:49.057' AS DateTime), N'Book', 805, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2155, CAST(N'2021-03-19T01:22:49.060' AS DateTime), N'Book', 806, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2156, CAST(N'2021-03-19T01:22:49.067' AS DateTime), N'Book', 807, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2157, CAST(N'2021-03-19T01:22:49.070' AS DateTime), N'Book', 794, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2158, CAST(N'2021-03-19T01:22:49.070' AS DateTime), N'Book', 795, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2159, CAST(N'2021-03-19T01:22:49.070' AS DateTime), N'Book', 796, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2160, CAST(N'2021-03-19T01:22:49.070' AS DateTime), N'Book', 797, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2161, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 798, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2162, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 799, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2163, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 800, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2164, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 801, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2165, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 802, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2166, CAST(N'2021-03-19T01:22:49.073' AS DateTime), N'Book', 804, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2167, CAST(N'2021-03-19T01:22:49.077' AS DateTime), N'Book', 805, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2168, CAST(N'2021-03-19T01:22:49.077' AS DateTime), N'Book', 806, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2169, CAST(N'2021-03-19T01:22:49.077' AS DateTime), N'Book', 807, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2170, CAST(N'2021-03-19T01:22:49.090' AS DateTime), N'Author', 323, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2171, CAST(N'2021-03-19T01:22:49.090' AS DateTime), N'Author', 324, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2172, CAST(N'2021-03-19T01:22:55.930' AS DateTime), N'Book', 808, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2173, CAST(N'2021-03-19T01:22:55.960' AS DateTime), N'Book', 809, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2174, CAST(N'2021-03-19T01:22:55.970' AS DateTime), N'Book', 810, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2175, CAST(N'2021-03-19T01:22:55.973' AS DateTime), N'Book', 811, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2176, CAST(N'2021-03-19T01:22:55.980' AS DateTime), N'Book', 812, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2177, CAST(N'2021-03-19T01:22:55.980' AS DateTime), N'Book', 813, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2178, CAST(N'2021-03-19T01:22:55.987' AS DateTime), N'Book', 814, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2179, CAST(N'2021-03-19T01:22:55.987' AS DateTime), N'Book', 815, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2180, CAST(N'2021-03-19T01:22:55.993' AS DateTime), N'Author', 325, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2181, CAST(N'2021-03-19T01:22:56.000' AS DateTime), N'Author', 326, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2182, CAST(N'2021-03-19T01:22:56.020' AS DateTime), N'Book', 816, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2183, CAST(N'2021-03-19T01:22:56.100' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2184, CAST(N'2021-03-19T01:22:56.137' AS DateTime), N'Book', 817, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2185, CAST(N'2021-03-19T01:22:56.140' AS DateTime), N'Book', 817, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2186, CAST(N'2021-03-19T01:22:56.140' AS DateTime), N'Book', 818, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2187, CAST(N'2021-03-19T01:22:56.143' AS DateTime), N'Book', 819, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2188, CAST(N'2021-03-19T01:22:56.147' AS DateTime), N'Book', 820, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2189, CAST(N'2021-03-19T01:22:56.150' AS DateTime), N'Book', 821, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2190, CAST(N'2021-03-19T01:22:56.150' AS DateTime), N'Book', 808, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2191, CAST(N'2021-03-19T01:22:56.150' AS DateTime), N'Book', 809, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2192, CAST(N'2021-03-19T01:22:56.153' AS DateTime), N'Book', 810, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2193, CAST(N'2021-03-19T01:22:56.153' AS DateTime), N'Book', 811, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2194, CAST(N'2021-03-19T01:22:56.153' AS DateTime), N'Book', 812, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2195, CAST(N'2021-03-19T01:22:56.153' AS DateTime), N'Book', 813, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2196, CAST(N'2021-03-19T01:22:56.153' AS DateTime), N'Book', 814, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2197, CAST(N'2021-03-19T01:22:56.157' AS DateTime), N'Book', 815, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2198, CAST(N'2021-03-19T01:22:56.157' AS DateTime), N'Book', 816, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2199, CAST(N'2021-03-19T01:22:56.157' AS DateTime), N'Book', 818, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2200, CAST(N'2021-03-19T01:22:56.157' AS DateTime), N'Book', 819, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2201, CAST(N'2021-03-19T01:22:56.157' AS DateTime), N'Book', 820, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2202, CAST(N'2021-03-19T01:22:56.160' AS DateTime), N'Book', 821, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2203, CAST(N'2021-03-19T01:22:56.160' AS DateTime), N'Author', 325, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2204, CAST(N'2021-03-19T01:22:56.160' AS DateTime), N'Author', 326, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2205, CAST(N'2021-03-19T01:23:09.240' AS DateTime), N'Author', 327, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2206, CAST(N'2021-03-19T01:23:09.307' AS DateTime), N'Author', 328, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2207, CAST(N'2021-03-19T01:23:09.310' AS DateTime), N'Author', 329, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2208, CAST(N'2021-03-19T01:23:09.310' AS DateTime), N'Author', 330, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2209, CAST(N'2021-03-19T01:23:09.317' AS DateTime), N'Author', 331, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2210, CAST(N'2021-03-19T01:23:09.327' AS DateTime), N'Author', 332, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2211, CAST(N'2021-03-19T01:23:09.343' AS DateTime), N'Patent', 822, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2212, CAST(N'2021-03-19T01:23:09.463' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2213, CAST(N'2021-03-19T01:23:09.500' AS DateTime), N'Author', 333, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2214, CAST(N'2021-03-19T01:23:09.507' AS DateTime), N'Author', 333, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2215, CAST(N'2021-03-19T01:23:09.507' AS DateTime), N'Author', 334, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2216, CAST(N'2021-03-19T01:23:09.510' AS DateTime), N'Author', 335, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2217, CAST(N'2021-03-19T01:23:09.510' AS DateTime), N'Author', 336, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2218, CAST(N'2021-03-19T01:23:09.513' AS DateTime), N'Author', 337, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2219, CAST(N'2021-03-19T01:23:09.523' AS DateTime), N'Patent', 822, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2220, CAST(N'2021-03-19T01:23:09.527' AS DateTime), N'Author', 327, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2221, CAST(N'2021-03-19T01:23:09.527' AS DateTime), N'Author', 328, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2222, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 329, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2223, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 330, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2224, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 331, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2225, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 332, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2226, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 334, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2227, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 335, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2228, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 336, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2229, CAST(N'2021-03-19T01:23:09.530' AS DateTime), N'Author', 337, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2230, CAST(N'2021-03-19T01:23:09.540' AS DateTime), N'Book', 823, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2231, CAST(N'2021-03-19T01:23:09.557' AS DateTime), N'Book', 824, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2232, CAST(N'2021-03-19T01:23:09.560' AS DateTime), N'Book', 825, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2233, CAST(N'2021-03-19T01:23:09.563' AS DateTime), N'Book', 826, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2234, CAST(N'2021-03-19T01:23:09.570' AS DateTime), N'Book', 827, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2235, CAST(N'2021-03-19T01:23:09.570' AS DateTime), N'Book', 828, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2236, CAST(N'2021-03-19T01:23:09.573' AS DateTime), N'Book', 829, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2237, CAST(N'2021-03-19T01:23:09.577' AS DateTime), N'Book', 830, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2238, CAST(N'2021-03-19T01:23:09.583' AS DateTime), N'Author', 338, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2239, CAST(N'2021-03-19T01:23:09.587' AS DateTime), N'Author', 339, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2240, CAST(N'2021-03-19T01:23:09.590' AS DateTime), N'Book', 831, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2241, CAST(N'2021-03-19T01:23:09.593' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2242, CAST(N'2021-03-19T01:23:09.597' AS DateTime), N'Book', 832, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2243, CAST(N'2021-03-19T01:23:09.597' AS DateTime), N'Book', 832, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2244, CAST(N'2021-03-19T01:23:09.600' AS DateTime), N'Book', 833, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2245, CAST(N'2021-03-19T01:23:09.603' AS DateTime), N'Book', 834, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2246, CAST(N'2021-03-19T01:23:09.603' AS DateTime), N'Book', 835, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2247, CAST(N'2021-03-19T01:23:09.610' AS DateTime), N'Book', 836, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2248, CAST(N'2021-03-19T01:23:09.613' AS DateTime), N'Book', 823, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2249, CAST(N'2021-03-19T01:23:09.617' AS DateTime), N'Book', 824, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2250, CAST(N'2021-03-19T01:23:09.617' AS DateTime), N'Book', 825, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2251, CAST(N'2021-03-19T01:23:09.617' AS DateTime), N'Book', 826, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2252, CAST(N'2021-03-19T01:23:09.617' AS DateTime), N'Book', 827, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2253, CAST(N'2021-03-19T01:23:09.617' AS DateTime), N'Book', 828, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2254, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 829, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2255, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 830, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2256, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 831, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2257, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 833, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2258, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 834, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2259, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 835, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2260, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Book', 836, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2261, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Author', 338, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2262, CAST(N'2021-03-19T01:23:09.620' AS DateTime), N'Author', 339, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2263, CAST(N'2021-03-19T01:23:09.633' AS DateTime), N'Newspaper', 837, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2264, CAST(N'2021-03-19T01:23:09.640' AS DateTime), N'Newspaper', 838, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2265, CAST(N'2021-03-19T01:23:09.647' AS DateTime), N'Newspaper', 839, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2266, CAST(N'2021-03-19T01:23:09.647' AS DateTime), N'Newspaper', 840, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2267, CAST(N'2021-03-19T01:23:09.657' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2268, CAST(N'2021-03-19T01:23:09.660' AS DateTime), N'Newspaper', 841, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2269, CAST(N'2021-03-19T01:23:09.663' AS DateTime), N'Newspaper', 841, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2270, CAST(N'2021-03-19T01:23:09.663' AS DateTime), N'Newspaper', 842, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2271, CAST(N'2021-03-19T01:23:09.667' AS DateTime), N'Newspaper', 843, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2272, CAST(N'2021-03-19T01:23:09.667' AS DateTime), N'Newspaper', 844, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2273, CAST(N'2021-03-19T01:23:09.673' AS DateTime), N'Newspaper', 837, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2274, CAST(N'2021-03-19T01:23:09.673' AS DateTime), N'Newspaper', 838, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2275, CAST(N'2021-03-19T01:23:09.673' AS DateTime), N'Newspaper', 839, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2276, CAST(N'2021-03-19T01:23:09.677' AS DateTime), N'Newspaper', 840, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2277, CAST(N'2021-03-19T01:23:09.677' AS DateTime), N'Newspaper', 842, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2278, CAST(N'2021-03-19T01:23:09.677' AS DateTime), N'Newspaper', 843, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2279, CAST(N'2021-03-19T01:23:09.677' AS DateTime), N'Newspaper', 844, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2280, CAST(N'2021-03-19T01:23:09.700' AS DateTime), N'Patent', 845, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2281, CAST(N'2021-03-19T01:23:09.703' AS DateTime), N'Patent', 846, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2282, CAST(N'2021-03-19T01:23:09.710' AS DateTime), N'Patent', 847, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2283, CAST(N'2021-03-19T01:23:09.710' AS DateTime), N'Patent', 848, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2284, CAST(N'2021-03-19T01:23:09.720' AS DateTime), N'Author', 340, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2285, CAST(N'2021-03-19T01:23:09.737' AS DateTime), N'Author', 341, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2286, CAST(N'2021-03-19T01:23:09.740' AS DateTime), N'Patent', 849, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2287, CAST(N'2021-03-19T01:23:09.740' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2288, CAST(N'2021-03-19T01:23:09.747' AS DateTime), N'Patent', 850, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2289, CAST(N'2021-03-19T01:23:09.750' AS DateTime), N'Patent', 850, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2290, CAST(N'2021-03-19T01:23:09.753' AS DateTime), N'Patent', 851, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2291, CAST(N'2021-03-19T01:23:09.757' AS DateTime), N'Patent', 852, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2292, CAST(N'2021-03-19T01:23:09.760' AS DateTime), N'Patent', 853, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2293, CAST(N'2021-03-19T01:23:09.770' AS DateTime), N'Patent', 845, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2294, CAST(N'2021-03-19T01:23:09.770' AS DateTime), N'Patent', 846, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2295, CAST(N'2021-03-19T01:23:09.770' AS DateTime), N'Patent', 847, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2296, CAST(N'2021-03-19T01:23:09.773' AS DateTime), N'Patent', 848, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2297, CAST(N'2021-03-19T01:23:09.773' AS DateTime), N'Patent', 849, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2298, CAST(N'2021-03-19T01:23:09.773' AS DateTime), N'Patent', 851, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2299, CAST(N'2021-03-19T01:23:09.773' AS DateTime), N'Patent', 852, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2300, CAST(N'2021-03-19T01:23:09.773' AS DateTime), N'Patent', 853, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2301, CAST(N'2021-03-19T01:23:09.777' AS DateTime), N'Author', 340, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2302, CAST(N'2021-03-19T01:23:09.777' AS DateTime), N'Author', 341, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2303, CAST(N'2021-03-19T01:23:09.780' AS DateTime), N'Book', 854, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2304, CAST(N'2021-03-19T01:23:09.787' AS DateTime), N'Author', 342, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2305, CAST(N'2021-03-19T01:23:09.787' AS DateTime), N'Author', 343, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2306, CAST(N'2021-03-19T01:23:09.790' AS DateTime), N'Book', 855, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2307, CAST(N'2021-03-19T01:23:09.793' AS DateTime), N'Author', 344, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2308, CAST(N'2021-03-19T01:23:09.800' AS DateTime), N'Patent', 856, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2309, CAST(N'2021-03-19T01:23:09.803' AS DateTime), N'Author', 345, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2310, CAST(N'2021-03-19T01:23:09.803' AS DateTime), N'Book', 857, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2311, CAST(N'2021-03-19T01:23:09.810' AS DateTime), N'Patent', 858, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2312, CAST(N'2021-03-19T01:23:09.813' AS DateTime), N'Book', 859, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2313, CAST(N'2021-03-19T01:23:09.820' AS DateTime), N'Book', 860, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2314, CAST(N'2021-03-19T01:23:09.830' AS DateTime), N'Book', 861, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2315, CAST(N'2021-03-19T01:23:09.837' AS DateTime), N'Book', 854, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2316, CAST(N'2021-03-19T01:23:09.837' AS DateTime), N'Book', 855, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2317, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Book', 857, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2318, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Book', 859, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2319, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Book', 860, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2320, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Book', 861, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2321, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Patent', 856, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2322, CAST(N'2021-03-19T01:23:09.840' AS DateTime), N'Patent', 858, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2323, CAST(N'2021-03-19T01:23:09.843' AS DateTime), N'Author', 342, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2324, CAST(N'2021-03-19T01:23:09.843' AS DateTime), N'Author', 343, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2325, CAST(N'2021-03-19T01:23:09.843' AS DateTime), N'Author', 344, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2326, CAST(N'2021-03-19T01:23:09.843' AS DateTime), N'Author', 345, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2327, CAST(N'2021-03-19T01:26:55.040' AS DateTime), N'Author', 346, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2328, CAST(N'2021-03-19T01:26:55.113' AS DateTime), N'Author', 347, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2329, CAST(N'2021-03-19T01:26:55.120' AS DateTime), N'Author', 348, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2330, CAST(N'2021-03-19T01:26:55.123' AS DateTime), N'Author', 349, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2331, CAST(N'2021-03-19T01:26:55.127' AS DateTime), N'Author', 350, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2332, CAST(N'2021-03-19T01:26:55.137' AS DateTime), N'Author', 351, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2333, CAST(N'2021-03-19T01:26:55.157' AS DateTime), N'Patent', 862, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2334, CAST(N'2021-03-19T01:26:55.267' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2335, CAST(N'2021-03-19T01:26:55.303' AS DateTime), N'Author', 352, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2336, CAST(N'2021-03-19T01:26:55.307' AS DateTime), N'Author', 352, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2337, CAST(N'2021-03-19T01:26:55.310' AS DateTime), N'Author', 353, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2338, CAST(N'2021-03-19T01:26:55.310' AS DateTime), N'Author', 354, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2339, CAST(N'2021-03-19T01:26:55.313' AS DateTime), N'Author', 355, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2340, CAST(N'2021-03-19T01:26:55.317' AS DateTime), N'Author', 356, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2341, CAST(N'2021-03-19T01:26:55.327' AS DateTime), N'Patent', 862, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2342, CAST(N'2021-03-19T01:26:55.327' AS DateTime), N'Author', 346, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2343, CAST(N'2021-03-19T01:26:55.327' AS DateTime), N'Author', 347, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2344, CAST(N'2021-03-19T01:26:55.330' AS DateTime), N'Author', 348, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2345, CAST(N'2021-03-19T01:26:55.330' AS DateTime), N'Author', 349, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2346, CAST(N'2021-03-19T01:26:55.330' AS DateTime), N'Author', 350, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2347, CAST(N'2021-03-19T01:26:55.330' AS DateTime), N'Author', 351, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2348, CAST(N'2021-03-19T01:26:55.330' AS DateTime), N'Author', 353, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2349, CAST(N'2021-03-19T01:26:55.333' AS DateTime), N'Author', 354, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2350, CAST(N'2021-03-19T01:26:55.333' AS DateTime), N'Author', 355, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2351, CAST(N'2021-03-19T01:26:55.333' AS DateTime), N'Author', 356, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2352, CAST(N'2021-03-19T01:26:55.360' AS DateTime), N'Book', 863, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2353, CAST(N'2021-03-19T01:26:55.367' AS DateTime), N'Book', 864, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2354, CAST(N'2021-03-19T01:26:55.370' AS DateTime), N'Book', 865, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2355, CAST(N'2021-03-19T01:26:55.373' AS DateTime), N'Book', 866, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2356, CAST(N'2021-03-19T01:26:55.383' AS DateTime), N'Book', 867, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2357, CAST(N'2021-03-19T01:26:55.387' AS DateTime), N'Book', 868, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2358, CAST(N'2021-03-19T01:26:55.390' AS DateTime), N'Book', 869, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2359, CAST(N'2021-03-19T01:26:55.390' AS DateTime), N'Book', 870, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2360, CAST(N'2021-03-19T01:26:55.400' AS DateTime), N'Author', 357, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2361, CAST(N'2021-03-19T01:26:55.413' AS DateTime), N'Author', 358, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2362, CAST(N'2021-03-19T01:26:55.417' AS DateTime), N'Book', 871, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2363, CAST(N'2021-03-19T01:26:55.423' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2364, CAST(N'2021-03-19T01:26:55.427' AS DateTime), N'Book', 872, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2365, CAST(N'2021-03-19T01:26:55.427' AS DateTime), N'Book', 872, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2366, CAST(N'2021-03-19T01:26:55.430' AS DateTime), N'Book', 873, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2367, CAST(N'2021-03-19T01:26:55.433' AS DateTime), N'Book', 874, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2368, CAST(N'2021-03-19T01:26:55.437' AS DateTime), N'Book', 875, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2369, CAST(N'2021-03-19T01:26:55.443' AS DateTime), N'Book', 876, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2370, CAST(N'2021-03-19T01:26:55.447' AS DateTime), N'Book', 863, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2371, CAST(N'2021-03-19T01:26:55.447' AS DateTime), N'Book', 864, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2372, CAST(N'2021-03-19T01:26:55.447' AS DateTime), N'Book', 865, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2373, CAST(N'2021-03-19T01:26:55.447' AS DateTime), N'Book', 866, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2374, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 867, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2375, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 868, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2376, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 869, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2377, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 870, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2378, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 871, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2379, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 873, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2380, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 874, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2381, CAST(N'2021-03-19T01:26:55.450' AS DateTime), N'Book', 875, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2382, CAST(N'2021-03-19T01:26:55.453' AS DateTime), N'Book', 876, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2383, CAST(N'2021-03-19T01:26:55.453' AS DateTime), N'Author', 357, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2384, CAST(N'2021-03-19T01:26:55.453' AS DateTime), N'Author', 358, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2385, CAST(N'2021-03-19T01:26:55.467' AS DateTime), N'Newspaper', 877, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2386, CAST(N'2021-03-19T01:26:55.470' AS DateTime), N'Newspaper', 878, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2387, CAST(N'2021-03-19T01:26:55.473' AS DateTime), N'Newspaper', 879, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2388, CAST(N'2021-03-19T01:26:55.473' AS DateTime), N'Newspaper', 880, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2389, CAST(N'2021-03-19T01:26:55.487' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2390, CAST(N'2021-03-19T01:26:55.490' AS DateTime), N'Newspaper', 881, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2391, CAST(N'2021-03-19T01:26:55.490' AS DateTime), N'Newspaper', 881, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2392, CAST(N'2021-03-19T01:26:55.493' AS DateTime), N'Newspaper', 882, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2393, CAST(N'2021-03-19T01:26:55.493' AS DateTime), N'Newspaper', 883, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2394, CAST(N'2021-03-19T01:26:55.497' AS DateTime), N'Newspaper', 884, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2395, CAST(N'2021-03-19T01:26:55.500' AS DateTime), N'Newspaper', 877, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2396, CAST(N'2021-03-19T01:26:55.503' AS DateTime), N'Newspaper', 878, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2397, CAST(N'2021-03-19T01:26:55.503' AS DateTime), N'Newspaper', 879, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2398, CAST(N'2021-03-19T01:26:55.503' AS DateTime), N'Newspaper', 880, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2399, CAST(N'2021-03-19T01:26:55.503' AS DateTime), N'Newspaper', 882, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2400, CAST(N'2021-03-19T01:26:55.503' AS DateTime), N'Newspaper', 883, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2401, CAST(N'2021-03-19T01:26:55.507' AS DateTime), N'Newspaper', 884, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2402, CAST(N'2021-03-19T01:26:55.520' AS DateTime), N'Patent', 885, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2403, CAST(N'2021-03-19T01:26:55.523' AS DateTime), N'Patent', 886, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2404, CAST(N'2021-03-19T01:26:55.530' AS DateTime), N'Patent', 887, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2405, CAST(N'2021-03-19T01:26:55.533' AS DateTime), N'Patent', 888, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2406, CAST(N'2021-03-19T01:26:55.540' AS DateTime), N'Author', 359, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2407, CAST(N'2021-03-19T01:26:55.553' AS DateTime), N'Author', 360, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2408, CAST(N'2021-03-19T01:26:55.557' AS DateTime), N'Patent', 889, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2409, CAST(N'2021-03-19T01:26:55.560' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2410, CAST(N'2021-03-19T01:26:55.563' AS DateTime), N'Patent', 890, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2411, CAST(N'2021-03-19T01:26:55.567' AS DateTime), N'Patent', 890, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2412, CAST(N'2021-03-19T01:26:55.570' AS DateTime), N'Patent', 891, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2413, CAST(N'2021-03-19T01:26:55.573' AS DateTime), N'Patent', 892, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2414, CAST(N'2021-03-19T01:26:55.577' AS DateTime), N'Patent', 893, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2415, CAST(N'2021-03-19T01:26:55.583' AS DateTime), N'Patent', 885, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2416, CAST(N'2021-03-19T01:26:55.587' AS DateTime), N'Patent', 886, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2417, CAST(N'2021-03-19T01:26:55.587' AS DateTime), N'Patent', 887, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2418, CAST(N'2021-03-19T01:26:55.587' AS DateTime), N'Patent', 888, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2419, CAST(N'2021-03-19T01:26:55.587' AS DateTime), N'Patent', 889, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2420, CAST(N'2021-03-19T01:26:55.587' AS DateTime), N'Patent', 891, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2421, CAST(N'2021-03-19T01:26:55.590' AS DateTime), N'Patent', 892, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2422, CAST(N'2021-03-19T01:26:55.590' AS DateTime), N'Patent', 893, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2423, CAST(N'2021-03-19T01:26:55.590' AS DateTime), N'Author', 359, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2424, CAST(N'2021-03-19T01:26:55.590' AS DateTime), N'Author', 360, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2425, CAST(N'2021-03-19T01:26:55.593' AS DateTime), N'Book', 894, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2426, CAST(N'2021-03-19T01:26:55.597' AS DateTime), N'Author', 361, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2427, CAST(N'2021-03-19T01:26:55.600' AS DateTime), N'Author', 362, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2428, CAST(N'2021-03-19T01:26:55.600' AS DateTime), N'Book', 895, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2429, CAST(N'2021-03-19T01:26:55.603' AS DateTime), N'Author', 363, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2430, CAST(N'2021-03-19T01:26:55.607' AS DateTime), N'Patent', 896, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2431, CAST(N'2021-03-19T01:26:55.610' AS DateTime), N'Author', 364, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2432, CAST(N'2021-03-19T01:26:55.613' AS DateTime), N'Book', 897, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2433, CAST(N'2021-03-19T01:26:55.620' AS DateTime), N'Patent', 898, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2434, CAST(N'2021-03-19T01:26:55.623' AS DateTime), N'Book', 899, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2435, CAST(N'2021-03-19T01:26:55.630' AS DateTime), N'Book', 900, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2436, CAST(N'2021-03-19T01:26:55.640' AS DateTime), N'Book', 901, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2437, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 894, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2438, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 895, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2439, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 897, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2440, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 899, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2441, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 900, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2442, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Book', 901, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2443, CAST(N'2021-03-19T01:26:55.650' AS DateTime), N'Patent', 896, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2444, CAST(N'2021-03-19T01:26:55.653' AS DateTime), N'Patent', 898, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2445, CAST(N'2021-03-19T01:26:55.653' AS DateTime), N'Author', 361, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2446, CAST(N'2021-03-19T01:26:55.653' AS DateTime), N'Author', 362, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2447, CAST(N'2021-03-19T01:26:55.653' AS DateTime), N'Author', 363, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2448, CAST(N'2021-03-19T01:26:55.653' AS DateTime), N'Author', 364, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2449, CAST(N'2021-03-19T13:48:25.010' AS DateTime), N'Author', 365, N'Add', N'Test_Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2450, CAST(N'2021-03-19T13:49:43.177' AS DateTime), N'Author', 365, N'Mark 1', N'Test_Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2451, CAST(N'2021-03-19T15:14:16.490' AS DateTime), N'Author', 366, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2452, CAST(N'2021-03-19T15:14:16.567' AS DateTime), N'Author', 367, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2453, CAST(N'2021-03-19T15:14:16.570' AS DateTime), N'Author', 368, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2454, CAST(N'2021-03-19T15:14:16.570' AS DateTime), N'Author', 369, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2455, CAST(N'2021-03-19T15:14:16.573' AS DateTime), N'Author', 370, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2456, CAST(N'2021-03-19T15:14:16.583' AS DateTime), N'Author', 371, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2457, CAST(N'2021-03-19T15:14:16.610' AS DateTime), N'Patent', 902, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2458, CAST(N'2021-03-19T15:14:16.723' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2459, CAST(N'2021-03-19T15:14:16.760' AS DateTime), N'Author', 372, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2460, CAST(N'2021-03-19T15:14:16.760' AS DateTime), N'Author', 372, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2461, CAST(N'2021-03-19T15:14:16.760' AS DateTime), N'Author', 373, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2462, CAST(N'2021-03-19T15:14:16.763' AS DateTime), N'Author', 374, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2463, CAST(N'2021-03-19T15:14:16.767' AS DateTime), N'Author', 375, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2464, CAST(N'2021-03-19T15:14:16.770' AS DateTime), N'Author', 376, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2465, CAST(N'2021-03-19T15:14:16.780' AS DateTime), N'Patent', 902, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2466, CAST(N'2021-03-19T15:14:16.780' AS DateTime), N'Author', 366, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2467, CAST(N'2021-03-19T15:14:16.783' AS DateTime), N'Author', 367, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2468, CAST(N'2021-03-19T15:14:16.783' AS DateTime), N'Author', 368, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2469, CAST(N'2021-03-19T15:14:16.783' AS DateTime), N'Author', 369, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2470, CAST(N'2021-03-19T15:14:16.787' AS DateTime), N'Author', 370, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2471, CAST(N'2021-03-19T15:14:16.787' AS DateTime), N'Author', 371, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2472, CAST(N'2021-03-19T15:14:16.787' AS DateTime), N'Author', 373, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2473, CAST(N'2021-03-19T15:14:16.787' AS DateTime), N'Author', 374, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2474, CAST(N'2021-03-19T15:14:16.787' AS DateTime), N'Author', 375, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2475, CAST(N'2021-03-19T15:14:16.790' AS DateTime), N'Author', 376, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2476, CAST(N'2021-03-19T15:14:16.820' AS DateTime), N'Book', 903, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2477, CAST(N'2021-03-19T15:14:16.823' AS DateTime), N'Book', 904, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2478, CAST(N'2021-03-19T15:14:16.830' AS DateTime), N'Book', 905, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2479, CAST(N'2021-03-19T15:14:16.830' AS DateTime), N'Book', 906, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2480, CAST(N'2021-03-19T15:14:16.840' AS DateTime), N'Book', 907, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2481, CAST(N'2021-03-19T15:14:16.843' AS DateTime), N'Book', 908, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2482, CAST(N'2021-03-19T15:14:16.847' AS DateTime), N'Book', 909, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2483, CAST(N'2021-03-19T15:14:16.850' AS DateTime), N'Book', 910, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2484, CAST(N'2021-03-19T15:14:16.860' AS DateTime), N'Author', 377, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2485, CAST(N'2021-03-19T15:14:16.873' AS DateTime), N'Author', 378, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2486, CAST(N'2021-03-19T15:14:16.877' AS DateTime), N'Book', 911, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2487, CAST(N'2021-03-19T15:14:16.883' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2488, CAST(N'2021-03-19T15:14:16.887' AS DateTime), N'Book', 912, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2489, CAST(N'2021-03-19T15:14:16.890' AS DateTime), N'Book', 912, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2490, CAST(N'2021-03-19T15:14:16.893' AS DateTime), N'Book', 913, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2491, CAST(N'2021-03-19T15:14:16.897' AS DateTime), N'Book', 914, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2492, CAST(N'2021-03-19T15:14:16.900' AS DateTime), N'Book', 915, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2493, CAST(N'2021-03-19T15:14:16.907' AS DateTime), N'Book', 916, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2494, CAST(N'2021-03-19T15:14:16.910' AS DateTime), N'Book', 903, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2495, CAST(N'2021-03-19T15:14:16.910' AS DateTime), N'Book', 904, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2496, CAST(N'2021-03-19T15:14:16.913' AS DateTime), N'Book', 905, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2497, CAST(N'2021-03-19T15:14:16.913' AS DateTime), N'Book', 906, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2498, CAST(N'2021-03-19T15:14:16.913' AS DateTime), N'Book', 907, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2499, CAST(N'2021-03-19T15:14:16.913' AS DateTime), N'Book', 908, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2500, CAST(N'2021-03-19T15:14:16.913' AS DateTime), N'Book', 909, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2501, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 910, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2502, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 911, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2503, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 913, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2504, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 914, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2505, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 915, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2506, CAST(N'2021-03-19T15:14:16.917' AS DateTime), N'Book', 916, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2507, CAST(N'2021-03-19T15:14:16.920' AS DateTime), N'Author', 377, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2508, CAST(N'2021-03-19T15:14:16.920' AS DateTime), N'Author', 378, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2509, CAST(N'2021-03-19T15:14:16.933' AS DateTime), N'Newspaper', 917, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2510, CAST(N'2021-03-19T15:14:16.937' AS DateTime), N'Newspaper', 918, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2511, CAST(N'2021-03-19T15:14:16.943' AS DateTime), N'Newspaper', 919, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2512, CAST(N'2021-03-19T15:14:16.943' AS DateTime), N'Newspaper', 920, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2513, CAST(N'2021-03-19T15:14:16.957' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2514, CAST(N'2021-03-19T15:14:16.960' AS DateTime), N'Newspaper', 921, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2515, CAST(N'2021-03-19T15:14:16.960' AS DateTime), N'Newspaper', 921, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2516, CAST(N'2021-03-19T15:14:16.960' AS DateTime), N'Newspaper', 922, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2517, CAST(N'2021-03-19T15:14:16.963' AS DateTime), N'Newspaper', 923, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2518, CAST(N'2021-03-19T15:14:16.967' AS DateTime), N'Newspaper', 924, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2519, CAST(N'2021-03-19T15:14:16.970' AS DateTime), N'Newspaper', 917, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2520, CAST(N'2021-03-19T15:14:16.973' AS DateTime), N'Newspaper', 918, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2521, CAST(N'2021-03-19T15:14:16.973' AS DateTime), N'Newspaper', 919, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2522, CAST(N'2021-03-19T15:14:16.973' AS DateTime), N'Newspaper', 920, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2523, CAST(N'2021-03-19T15:14:16.973' AS DateTime), N'Newspaper', 922, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2524, CAST(N'2021-03-19T15:14:16.973' AS DateTime), N'Newspaper', 923, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2525, CAST(N'2021-03-19T15:14:16.977' AS DateTime), N'Newspaper', 924, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2526, CAST(N'2021-03-19T15:14:16.990' AS DateTime), N'Patent', 925, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2527, CAST(N'2021-03-19T15:14:16.997' AS DateTime), N'Patent', 926, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2528, CAST(N'2021-03-19T15:14:17.000' AS DateTime), N'Patent', 927, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2529, CAST(N'2021-03-19T15:14:17.003' AS DateTime), N'Patent', 928, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2530, CAST(N'2021-03-19T15:14:17.013' AS DateTime), N'Author', 379, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2531, CAST(N'2021-03-19T15:14:17.027' AS DateTime), N'Author', 380, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2532, CAST(N'2021-03-19T15:14:17.030' AS DateTime), N'Patent', 929, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2533, CAST(N'2021-03-19T15:14:17.033' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2534, CAST(N'2021-03-19T15:14:17.040' AS DateTime), N'Patent', 930, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2535, CAST(N'2021-03-19T15:14:17.040' AS DateTime), N'Patent', 930, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2536, CAST(N'2021-03-19T15:14:17.043' AS DateTime), N'Patent', 931, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2537, CAST(N'2021-03-19T15:14:17.050' AS DateTime), N'Patent', 932, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2538, CAST(N'2021-03-19T15:14:17.053' AS DateTime), N'Patent', 933, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2539, CAST(N'2021-03-19T15:14:17.060' AS DateTime), N'Patent', 925, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2540, CAST(N'2021-03-19T15:14:17.060' AS DateTime), N'Patent', 926, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2541, CAST(N'2021-03-19T15:14:17.060' AS DateTime), N'Patent', 927, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2542, CAST(N'2021-03-19T15:14:17.060' AS DateTime), N'Patent', 928, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2543, CAST(N'2021-03-19T15:14:17.063' AS DateTime), N'Patent', 929, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2544, CAST(N'2021-03-19T15:14:17.063' AS DateTime), N'Patent', 931, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2545, CAST(N'2021-03-19T15:14:17.063' AS DateTime), N'Patent', 932, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2546, CAST(N'2021-03-19T15:14:17.063' AS DateTime), N'Patent', 933, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2547, CAST(N'2021-03-19T15:14:17.063' AS DateTime), N'Author', 379, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2548, CAST(N'2021-03-19T15:14:17.067' AS DateTime), N'Author', 380, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2549, CAST(N'2021-03-19T15:14:17.067' AS DateTime), N'Book', 934, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2550, CAST(N'2021-03-19T15:14:17.070' AS DateTime), N'Author', 381, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2551, CAST(N'2021-03-19T15:14:17.073' AS DateTime), N'Author', 382, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2552, CAST(N'2021-03-19T15:14:17.077' AS DateTime), N'Book', 935, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2553, CAST(N'2021-03-19T15:14:17.080' AS DateTime), N'Author', 383, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2554, CAST(N'2021-03-19T15:14:17.083' AS DateTime), N'Patent', 936, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2555, CAST(N'2021-03-19T15:14:17.090' AS DateTime), N'Author', 384, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2556, CAST(N'2021-03-19T15:14:17.093' AS DateTime), N'Book', 937, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2557, CAST(N'2021-03-19T15:14:17.100' AS DateTime), N'Patent', 938, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2558, CAST(N'2021-03-19T15:14:17.107' AS DateTime), N'Book', 939, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2559, CAST(N'2021-03-19T15:14:17.117' AS DateTime), N'Book', 940, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2560, CAST(N'2021-03-19T15:14:17.127' AS DateTime), N'Book', 941, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2561, CAST(N'2021-03-19T15:14:17.137' AS DateTime), N'Book', 934, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2562, CAST(N'2021-03-19T15:14:17.137' AS DateTime), N'Book', 935, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2563, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Book', 937, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2564, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Book', 939, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2565, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Book', 940, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2566, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Book', 941, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2567, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Patent', 936, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2568, CAST(N'2021-03-19T15:14:17.140' AS DateTime), N'Patent', 938, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2569, CAST(N'2021-03-19T15:14:17.143' AS DateTime), N'Author', 381, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2570, CAST(N'2021-03-19T15:14:17.143' AS DateTime), N'Author', 382, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2571, CAST(N'2021-03-19T15:14:17.143' AS DateTime), N'Author', 383, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2572, CAST(N'2021-03-19T15:14:17.147' AS DateTime), N'Author', 384, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2573, CAST(N'2021-03-19T15:28:08.280' AS DateTime), N'Author', 385, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2574, CAST(N'2021-03-19T15:28:08.320' AS DateTime), N'Author', 385, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2575, CAST(N'2021-03-19T15:28:08.363' AS DateTime), N'Author', 385, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2576, CAST(N'2021-03-19T15:51:37.830' AS DateTime), N'Book', 942, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2577, CAST(N'2021-03-19T15:51:37.883' AS DateTime), N'Book', 942, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2578, CAST(N'2021-03-19T15:51:37.923' AS DateTime), N'Book', 942, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2579, CAST(N'2021-03-19T15:52:22.800' AS DateTime), N'Author', 386, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2580, CAST(N'2021-03-19T15:52:22.837' AS DateTime), N'Author', 386, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2581, CAST(N'2021-03-19T15:52:22.883' AS DateTime), N'Author', 386, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2582, CAST(N'2021-03-19T15:52:47.187' AS DateTime), N'Book', 943, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2583, CAST(N'2021-03-19T15:52:47.213' AS DateTime), N'Book', 944, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2584, CAST(N'2021-03-19T15:52:47.227' AS DateTime), N'Book', 945, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2585, CAST(N'2021-03-19T15:52:47.227' AS DateTime), N'Book', 946, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2586, CAST(N'2021-03-19T15:52:47.237' AS DateTime), N'Book', 947, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2587, CAST(N'2021-03-19T15:52:47.240' AS DateTime), N'Book', 948, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2588, CAST(N'2021-03-19T15:52:47.243' AS DateTime), N'Book', 949, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2589, CAST(N'2021-03-19T15:52:47.247' AS DateTime), N'Book', 950, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2590, CAST(N'2021-03-19T15:52:47.267' AS DateTime), N'Author', 387, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2591, CAST(N'2021-03-19T15:52:47.283' AS DateTime), N'Author', 388, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2592, CAST(N'2021-03-19T15:52:47.307' AS DateTime), N'Book', 951, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2593, CAST(N'2021-03-19T15:52:47.390' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2594, CAST(N'2021-03-19T15:52:47.430' AS DateTime), N'Book', 952, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2595, CAST(N'2021-03-19T15:52:47.433' AS DateTime), N'Book', 952, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2596, CAST(N'2021-03-19T15:52:47.433' AS DateTime), N'Book', 953, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2597, CAST(N'2021-03-19T15:52:47.437' AS DateTime), N'Book', 954, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2598, CAST(N'2021-03-19T15:52:47.440' AS DateTime), N'Book', 955, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2599, CAST(N'2021-03-19T15:52:47.450' AS DateTime), N'Book', 956, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2600, CAST(N'2021-03-19T15:52:47.470' AS DateTime), N'Book', 943, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2601, CAST(N'2021-03-19T15:52:47.470' AS DateTime), N'Book', 943, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2602, CAST(N'2021-03-19T15:52:47.473' AS DateTime), N'Book', 944, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2603, CAST(N'2021-03-19T15:52:47.473' AS DateTime), N'Book', 945, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2604, CAST(N'2021-03-19T15:52:47.473' AS DateTime), N'Book', 946, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2605, CAST(N'2021-03-19T15:52:47.473' AS DateTime), N'Book', 947, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2606, CAST(N'2021-03-19T15:52:47.473' AS DateTime), N'Book', 948, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2607, CAST(N'2021-03-19T15:52:47.477' AS DateTime), N'Book', 949, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2608, CAST(N'2021-03-19T15:52:47.477' AS DateTime), N'Book', 950, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2609, CAST(N'2021-03-19T15:52:47.477' AS DateTime), N'Book', 951, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2610, CAST(N'2021-03-19T15:52:47.477' AS DateTime), N'Book', 953, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2611, CAST(N'2021-03-19T15:52:47.477' AS DateTime), N'Book', 954, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2612, CAST(N'2021-03-19T15:52:47.480' AS DateTime), N'Book', 955, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2613, CAST(N'2021-03-19T15:52:47.480' AS DateTime), N'Book', 956, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2614, CAST(N'2021-03-19T15:52:47.480' AS DateTime), N'Book', 943, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2615, CAST(N'2021-03-19T15:52:47.490' AS DateTime), N'Author', 387, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2616, CAST(N'2021-03-19T15:52:47.493' AS DateTime), N'Author', 388, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2617, CAST(N'2021-03-19T16:01:02.710' AS DateTime), N'Newspaper', 957, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2618, CAST(N'2021-03-19T16:01:02.750' AS DateTime), N'Newspaper', 957, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2619, CAST(N'2021-03-19T16:01:02.790' AS DateTime), N'Newspaper', 957, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2620, CAST(N'2021-03-19T16:01:16.550' AS DateTime), N'Newspaper', 958, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2621, CAST(N'2021-03-19T16:01:16.570' AS DateTime), N'Newspaper', 959, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2622, CAST(N'2021-03-19T16:01:16.580' AS DateTime), N'Newspaper', 960, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2623, CAST(N'2021-03-19T16:01:16.580' AS DateTime), N'Newspaper', 961, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2624, CAST(N'2021-03-19T16:01:16.593' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2625, CAST(N'2021-03-19T16:01:16.637' AS DateTime), N'Newspaper', 962, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2626, CAST(N'2021-03-19T16:01:16.640' AS DateTime), N'Newspaper', 962, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2627, CAST(N'2021-03-19T16:01:16.640' AS DateTime), N'Newspaper', 963, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2628, CAST(N'2021-03-19T16:01:16.643' AS DateTime), N'Newspaper', 964, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2629, CAST(N'2021-03-19T16:01:16.650' AS DateTime), N'Newspaper', 965, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2630, CAST(N'2021-03-19T16:01:16.660' AS DateTime), N'Newspaper', 966, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2631, CAST(N'2021-03-19T16:01:16.663' AS DateTime), N'Newspaper', 966, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2632, CAST(N'2021-03-19T16:01:16.667' AS DateTime), N'Newspaper', 958, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2633, CAST(N'2021-03-19T16:01:16.667' AS DateTime), N'Newspaper', 959, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2634, CAST(N'2021-03-19T16:01:16.667' AS DateTime), N'Newspaper', 960, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2635, CAST(N'2021-03-19T16:01:16.667' AS DateTime), N'Newspaper', 961, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2636, CAST(N'2021-03-19T16:01:16.667' AS DateTime), N'Newspaper', 963, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2637, CAST(N'2021-03-19T16:01:16.670' AS DateTime), N'Newspaper', 964, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2638, CAST(N'2021-03-19T16:01:16.670' AS DateTime), N'Newspaper', 965, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2639, CAST(N'2021-03-19T16:01:16.670' AS DateTime), N'Newspaper', 966, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2640, CAST(N'2021-03-19T16:11:26.267' AS DateTime), N'Patent', 967, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2641, CAST(N'2021-03-19T16:11:26.323' AS DateTime), N'Patent', 967, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2642, CAST(N'2021-03-19T16:11:26.390' AS DateTime), N'Patent', 967, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2643, CAST(N'2021-03-19T16:13:09.507' AS DateTime), N'Patent', 968, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2644, CAST(N'2021-03-19T16:13:09.577' AS DateTime), N'Patent', 968, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2645, CAST(N'2021-03-19T16:13:09.647' AS DateTime), N'Patent', 968, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2646, CAST(N'2021-03-19T16:13:48.593' AS DateTime), N'Patent', 969, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2647, CAST(N'2021-03-19T16:13:48.657' AS DateTime), N'Patent', 969, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2648, CAST(N'2021-03-19T16:13:48.700' AS DateTime), N'Patent', 969, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2649, CAST(N'2021-03-19T16:13:57.703' AS DateTime), N'Patent', 970, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2650, CAST(N'2021-03-19T16:13:57.730' AS DateTime), N'Patent', 971, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2651, CAST(N'2021-03-19T16:13:57.743' AS DateTime), N'Patent', 972, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2652, CAST(N'2021-03-19T16:13:57.750' AS DateTime), N'Patent', 973, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2653, CAST(N'2021-03-19T16:13:57.847' AS DateTime), N'Author', 389, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2654, CAST(N'2021-03-19T16:13:57.863' AS DateTime), N'Author', 390, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2655, CAST(N'2021-03-19T16:13:57.887' AS DateTime), N'Patent', 974, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2656, CAST(N'2021-03-19T16:13:57.893' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2657, CAST(N'2021-03-19T16:13:57.930' AS DateTime), N'Patent', 975, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2658, CAST(N'2021-03-19T16:13:57.933' AS DateTime), N'Patent', 975, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2659, CAST(N'2021-03-19T16:13:57.937' AS DateTime), N'Patent', 976, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2660, CAST(N'2021-03-19T16:13:57.940' AS DateTime), N'Patent', 977, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2661, CAST(N'2021-03-19T16:13:57.947' AS DateTime), N'Patent', 978, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2662, CAST(N'2021-03-19T16:13:57.970' AS DateTime), N'Patent', 970, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2663, CAST(N'2021-03-19T16:13:57.970' AS DateTime), N'Patent', 970, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2664, CAST(N'2021-03-19T16:13:57.970' AS DateTime), N'Patent', 971, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2665, CAST(N'2021-03-19T16:13:57.973' AS DateTime), N'Patent', 972, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2666, CAST(N'2021-03-19T16:13:57.973' AS DateTime), N'Patent', 973, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2667, CAST(N'2021-03-19T16:13:57.973' AS DateTime), N'Patent', 974, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2668, CAST(N'2021-03-19T16:13:57.973' AS DateTime), N'Patent', 976, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2669, CAST(N'2021-03-19T16:13:57.973' AS DateTime), N'Patent', 977, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2670, CAST(N'2021-03-19T16:13:57.977' AS DateTime), N'Patent', 978, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2671, CAST(N'2021-03-19T16:13:57.977' AS DateTime), N'Patent', 970, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2672, CAST(N'2021-03-19T16:13:57.987' AS DateTime), N'Author', 389, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2673, CAST(N'2021-03-19T16:13:57.990' AS DateTime), N'Author', 390, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2674, CAST(N'2021-03-19T16:14:08.283' AS DateTime), N'Author', 391, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2675, CAST(N'2021-03-19T16:14:08.353' AS DateTime), N'Author', 392, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2676, CAST(N'2021-03-19T16:14:08.357' AS DateTime), N'Author', 393, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2677, CAST(N'2021-03-19T16:14:08.357' AS DateTime), N'Author', 394, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2678, CAST(N'2021-03-19T16:14:08.360' AS DateTime), N'Author', 395, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2679, CAST(N'2021-03-19T16:14:08.373' AS DateTime), N'Author', 396, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2680, CAST(N'2021-03-19T16:14:08.393' AS DateTime), N'Patent', 979, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2681, CAST(N'2021-03-19T16:14:08.500' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2682, CAST(N'2021-03-19T16:14:08.537' AS DateTime), N'Author', 397, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2683, CAST(N'2021-03-19T16:14:08.540' AS DateTime), N'Author', 397, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2684, CAST(N'2021-03-19T16:14:08.540' AS DateTime), N'Author', 398, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2685, CAST(N'2021-03-19T16:14:08.543' AS DateTime), N'Author', 399, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2686, CAST(N'2021-03-19T16:14:08.543' AS DateTime), N'Author', 400, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2687, CAST(N'2021-03-19T16:14:08.547' AS DateTime), N'Author', 401, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2688, CAST(N'2021-03-19T16:14:08.560' AS DateTime), N'Author', 402, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2689, CAST(N'2021-03-19T16:14:08.560' AS DateTime), N'Author', 402, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2690, CAST(N'2021-03-19T16:14:08.567' AS DateTime), N'Patent', 979, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2691, CAST(N'2021-03-19T16:14:08.570' AS DateTime), N'Author', 391, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2692, CAST(N'2021-03-19T16:14:08.570' AS DateTime), N'Author', 392, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2693, CAST(N'2021-03-19T16:14:08.570' AS DateTime), N'Author', 393, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2694, CAST(N'2021-03-19T16:14:08.573' AS DateTime), N'Author', 394, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2695, CAST(N'2021-03-19T16:14:08.573' AS DateTime), N'Author', 395, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2696, CAST(N'2021-03-19T16:14:08.573' AS DateTime), N'Author', 396, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2697, CAST(N'2021-03-19T16:14:08.577' AS DateTime), N'Author', 398, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2698, CAST(N'2021-03-19T16:14:08.577' AS DateTime), N'Author', 399, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2699, CAST(N'2021-03-19T16:14:08.577' AS DateTime), N'Author', 400, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2700, CAST(N'2021-03-19T16:14:08.577' AS DateTime), N'Author', 401, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2701, CAST(N'2021-03-19T16:14:08.580' AS DateTime), N'Author', 402, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2702, CAST(N'2021-03-19T16:14:08.603' AS DateTime), N'Book', 980, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2703, CAST(N'2021-03-19T16:14:08.607' AS DateTime), N'Book', 981, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2704, CAST(N'2021-03-19T16:14:08.617' AS DateTime), N'Book', 982, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2705, CAST(N'2021-03-19T16:14:08.617' AS DateTime), N'Book', 983, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2706, CAST(N'2021-03-19T16:14:08.637' AS DateTime), N'Book', 984, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2707, CAST(N'2021-03-19T16:14:08.637' AS DateTime), N'Book', 985, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2708, CAST(N'2021-03-19T16:14:08.640' AS DateTime), N'Book', 986, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2709, CAST(N'2021-03-19T16:14:08.643' AS DateTime), N'Book', 987, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2710, CAST(N'2021-03-19T16:14:08.653' AS DateTime), N'Author', 403, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2711, CAST(N'2021-03-19T16:14:08.667' AS DateTime), N'Author', 404, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2712, CAST(N'2021-03-19T16:14:08.670' AS DateTime), N'Book', 988, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2713, CAST(N'2021-03-19T16:14:08.677' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2714, CAST(N'2021-03-19T16:14:08.680' AS DateTime), N'Book', 989, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2715, CAST(N'2021-03-19T16:14:08.680' AS DateTime), N'Book', 989, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2716, CAST(N'2021-03-19T16:14:08.683' AS DateTime), N'Book', 990, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2717, CAST(N'2021-03-19T16:14:08.687' AS DateTime), N'Book', 991, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2718, CAST(N'2021-03-19T16:14:08.690' AS DateTime), N'Book', 992, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2719, CAST(N'2021-03-19T16:14:08.700' AS DateTime), N'Book', 993, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2720, CAST(N'2021-03-19T16:14:08.713' AS DateTime), N'Book', 980, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2721, CAST(N'2021-03-19T16:14:08.717' AS DateTime), N'Book', 980, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2722, CAST(N'2021-03-19T16:14:08.717' AS DateTime), N'Book', 981, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2723, CAST(N'2021-03-19T16:14:08.717' AS DateTime), N'Book', 982, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2724, CAST(N'2021-03-19T16:14:08.717' AS DateTime), N'Book', 983, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2725, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 984, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2726, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 985, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2727, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 986, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2728, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 987, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2729, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 988, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2730, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 990, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2731, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 991, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2732, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 992, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2733, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 993, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2734, CAST(N'2021-03-19T16:14:08.720' AS DateTime), N'Book', 980, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2735, CAST(N'2021-03-19T16:14:08.723' AS DateTime), N'Author', 403, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2736, CAST(N'2021-03-19T16:14:08.723' AS DateTime), N'Author', 404, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2737, CAST(N'2021-03-19T16:14:08.737' AS DateTime), N'Newspaper', 994, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2738, CAST(N'2021-03-19T16:14:08.740' AS DateTime), N'Newspaper', 995, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2739, CAST(N'2021-03-19T16:14:08.743' AS DateTime), N'Newspaper', 996, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2740, CAST(N'2021-03-19T16:14:08.743' AS DateTime), N'Newspaper', 997, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2741, CAST(N'2021-03-19T16:14:08.757' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2742, CAST(N'2021-03-19T16:14:08.760' AS DateTime), N'Newspaper', 998, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2743, CAST(N'2021-03-19T16:14:08.760' AS DateTime), N'Newspaper', 998, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2744, CAST(N'2021-03-19T16:14:08.763' AS DateTime), N'Newspaper', 999, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2745, CAST(N'2021-03-19T16:14:08.763' AS DateTime), N'Newspaper', 1000, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2746, CAST(N'2021-03-19T16:14:08.767' AS DateTime), N'Newspaper', 1001, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2747, CAST(N'2021-03-19T16:14:08.777' AS DateTime), N'Newspaper', 1002, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2748, CAST(N'2021-03-19T16:14:08.780' AS DateTime), N'Newspaper', 1002, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2749, CAST(N'2021-03-19T16:14:08.783' AS DateTime), N'Newspaper', 994, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2750, CAST(N'2021-03-19T16:14:08.783' AS DateTime), N'Newspaper', 995, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2751, CAST(N'2021-03-19T16:14:08.783' AS DateTime), N'Newspaper', 996, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2752, CAST(N'2021-03-19T16:14:08.783' AS DateTime), N'Newspaper', 997, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2753, CAST(N'2021-03-19T16:14:08.787' AS DateTime), N'Newspaper', 999, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2754, CAST(N'2021-03-19T16:14:08.787' AS DateTime), N'Newspaper', 1000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2755, CAST(N'2021-03-19T16:14:08.787' AS DateTime), N'Newspaper', 1001, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2756, CAST(N'2021-03-19T16:14:08.787' AS DateTime), N'Newspaper', 1002, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2757, CAST(N'2021-03-19T16:14:08.800' AS DateTime), N'Patent', 1003, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2758, CAST(N'2021-03-19T16:14:08.807' AS DateTime), N'Patent', 1004, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2759, CAST(N'2021-03-19T16:14:08.810' AS DateTime), N'Patent', 1005, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2760, CAST(N'2021-03-19T16:14:08.813' AS DateTime), N'Patent', 1006, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2761, CAST(N'2021-03-19T16:14:08.823' AS DateTime), N'Author', 405, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2762, CAST(N'2021-03-19T16:14:08.837' AS DateTime), N'Author', 406, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2763, CAST(N'2021-03-19T16:14:08.843' AS DateTime), N'Patent', 1007, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2764, CAST(N'2021-03-19T16:14:08.847' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2765, CAST(N'2021-03-19T16:14:08.850' AS DateTime), N'Patent', 1008, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2766, CAST(N'2021-03-19T16:14:08.853' AS DateTime), N'Patent', 1008, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2767, CAST(N'2021-03-19T16:14:08.857' AS DateTime), N'Patent', 1009, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2768, CAST(N'2021-03-19T16:14:08.860' AS DateTime), N'Patent', 1010, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2769, CAST(N'2021-03-19T16:14:08.863' AS DateTime), N'Patent', 1011, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2770, CAST(N'2021-03-19T16:14:08.887' AS DateTime), N'Patent', 1003, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2771, CAST(N'2021-03-19T16:14:08.890' AS DateTime), N'Patent', 1003, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2772, CAST(N'2021-03-19T16:14:08.890' AS DateTime), N'Patent', 1004, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2773, CAST(N'2021-03-19T16:14:08.890' AS DateTime), N'Patent', 1005, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2774, CAST(N'2021-03-19T16:14:08.893' AS DateTime), N'Patent', 1006, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2775, CAST(N'2021-03-19T16:14:08.893' AS DateTime), N'Patent', 1007, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2776, CAST(N'2021-03-19T16:14:08.893' AS DateTime), N'Patent', 1009, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2777, CAST(N'2021-03-19T16:14:08.893' AS DateTime), N'Patent', 1010, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2778, CAST(N'2021-03-19T16:14:08.897' AS DateTime), N'Patent', 1011, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2779, CAST(N'2021-03-19T16:14:08.897' AS DateTime), N'Patent', 1003, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2780, CAST(N'2021-03-19T16:14:08.897' AS DateTime), N'Author', 405, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2781, CAST(N'2021-03-19T16:14:08.897' AS DateTime), N'Author', 406, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2782, CAST(N'2021-03-19T16:14:08.900' AS DateTime), N'Book', 1012, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2783, CAST(N'2021-03-19T16:14:08.903' AS DateTime), N'Author', 407, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2784, CAST(N'2021-03-19T16:14:08.903' AS DateTime), N'Author', 408, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2785, CAST(N'2021-03-19T16:14:08.907' AS DateTime), N'Book', 1013, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2786, CAST(N'2021-03-19T16:14:08.910' AS DateTime), N'Author', 409, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2787, CAST(N'2021-03-19T16:14:08.917' AS DateTime), N'Patent', 1014, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2788, CAST(N'2021-03-19T16:14:08.920' AS DateTime), N'Author', 410, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2789, CAST(N'2021-03-19T16:14:08.920' AS DateTime), N'Book', 1015, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2790, CAST(N'2021-03-19T16:14:08.927' AS DateTime), N'Patent', 1016, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2791, CAST(N'2021-03-19T16:14:08.933' AS DateTime), N'Book', 1017, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2792, CAST(N'2021-03-19T16:14:08.940' AS DateTime), N'Book', 1018, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2793, CAST(N'2021-03-19T16:14:08.950' AS DateTime), N'Book', 1019, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2794, CAST(N'2021-03-19T16:14:08.960' AS DateTime), N'Book', 1012, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2795, CAST(N'2021-03-19T16:14:08.960' AS DateTime), N'Book', 1013, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2796, CAST(N'2021-03-19T16:14:08.960' AS DateTime), N'Book', 1015, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2797, CAST(N'2021-03-19T16:14:08.963' AS DateTime), N'Book', 1017, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2798, CAST(N'2021-03-19T16:14:08.963' AS DateTime), N'Book', 1018, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2799, CAST(N'2021-03-19T16:14:08.963' AS DateTime), N'Book', 1019, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2800, CAST(N'2021-03-19T16:14:08.963' AS DateTime), N'Patent', 1014, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2801, CAST(N'2021-03-19T16:14:08.967' AS DateTime), N'Patent', 1016, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2802, CAST(N'2021-03-19T16:14:08.967' AS DateTime), N'Author', 407, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2803, CAST(N'2021-03-19T16:14:08.967' AS DateTime), N'Author', 408, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2804, CAST(N'2021-03-19T16:14:08.967' AS DateTime), N'Author', 409, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (2805, CAST(N'2021-03-19T16:14:08.967' AS DateTime), N'Author', 410, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3449, CAST(N'2021-03-26T16:19:29.730' AS DateTime), N'Book', 1902, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3450, CAST(N'2021-03-29T22:18:11.193' AS DateTime), N'Author', 1365, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3451, CAST(N'2021-03-29T23:14:33.320' AS DateTime), N'Patent', 1903, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3452, CAST(N'2021-03-30T11:47:35.413' AS DateTime), N'Book', 1904, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3453, CAST(N'2021-03-30T14:11:15.660' AS DateTime), N'Book', 1905, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3454, CAST(N'2021-03-30T16:13:29.617' AS DateTime), N'Book', 1906, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3455, CAST(N'2021-03-30T16:16:49.577' AS DateTime), N'Book', 1907, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3456, CAST(N'2021-03-31T00:27:43.130' AS DateTime), N'Author', 1366, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3457, CAST(N'2021-03-31T00:27:43.200' AS DateTime), N'Author', 1366, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3458, CAST(N'2021-03-31T00:27:51.813' AS DateTime), N'Author', 1367, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3459, CAST(N'2021-03-31T00:27:51.890' AS DateTime), N'Author', 1368, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3460, CAST(N'2021-03-31T00:27:51.890' AS DateTime), N'Author', 1369, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3461, CAST(N'2021-03-31T00:27:51.893' AS DateTime), N'Author', 1370, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3462, CAST(N'2021-03-31T00:27:51.897' AS DateTime), N'Author', 1371, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3463, CAST(N'2021-03-31T00:27:51.907' AS DateTime), N'Author', 1372, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3464, CAST(N'2021-03-31T00:27:51.940' AS DateTime), N'Patent', 1908, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3465, CAST(N'2021-03-31T00:27:52.043' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3466, CAST(N'2021-03-31T00:27:52.087' AS DateTime), N'Author', 1373, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3467, CAST(N'2021-03-31T00:27:52.090' AS DateTime), N'Author', 1373, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3468, CAST(N'2021-03-31T00:27:52.090' AS DateTime), N'Author', 1374, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3469, CAST(N'2021-03-31T00:27:52.090' AS DateTime), N'Author', 1375, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3470, CAST(N'2021-03-31T00:27:52.093' AS DateTime), N'Author', 1376, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3471, CAST(N'2021-03-31T00:27:52.097' AS DateTime), N'Author', 1377, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3472, CAST(N'2021-03-31T00:27:52.110' AS DateTime), N'Author', 1378, N'Add', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3473, CAST(N'2021-03-31T00:27:52.110' AS DateTime), N'Author', 1378, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3474, CAST(N'2021-03-31T00:27:52.120' AS DateTime), N'Patent', 1908, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3475, CAST(N'2021-03-31T00:27:52.120' AS DateTime), N'Author', 1367, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3476, CAST(N'2021-03-31T00:27:52.120' AS DateTime), N'Author', 1368, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3477, CAST(N'2021-03-31T00:27:52.123' AS DateTime), N'Author', 1369, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3478, CAST(N'2021-03-31T00:27:52.123' AS DateTime), N'Author', 1370, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3479, CAST(N'2021-03-31T00:27:52.123' AS DateTime), N'Author', 1371, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3480, CAST(N'2021-03-31T00:27:52.123' AS DateTime), N'Author', 1372, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3481, CAST(N'2021-03-31T00:27:52.127' AS DateTime), N'Author', 1374, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3482, CAST(N'2021-03-31T00:27:52.127' AS DateTime), N'Author', 1375, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3483, CAST(N'2021-03-31T00:27:52.127' AS DateTime), N'Author', 1376, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3484, CAST(N'2021-03-31T00:27:52.127' AS DateTime), N'Author', 1377, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3485, CAST(N'2021-03-31T00:27:52.130' AS DateTime), N'Author', 1378, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3486, CAST(N'2021-03-31T00:28:37.670' AS DateTime), N'Author', 1379, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3487, CAST(N'2021-03-31T00:28:37.727' AS DateTime), N'Author', 1379, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3488, CAST(N'2021-03-31T00:28:47.990' AS DateTime), N'Author', 1380, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3489, CAST(N'2021-03-31T00:28:48.053' AS DateTime), N'Author', 1381, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3490, CAST(N'2021-03-31T00:28:48.053' AS DateTime), N'Author', 1382, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3491, CAST(N'2021-03-31T00:28:48.057' AS DateTime), N'Author', 1383, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3492, CAST(N'2021-03-31T00:28:48.060' AS DateTime), N'Author', 1384, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3493, CAST(N'2021-03-31T00:28:48.070' AS DateTime), N'Author', 1385, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3494, CAST(N'2021-03-31T00:28:48.090' AS DateTime), N'Patent', 1909, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3495, CAST(N'2021-03-31T00:28:48.190' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3496, CAST(N'2021-03-31T00:28:48.230' AS DateTime), N'Author', 1386, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3497, CAST(N'2021-03-31T00:28:48.230' AS DateTime), N'Author', 1386, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3498, CAST(N'2021-03-31T00:28:48.233' AS DateTime), N'Author', 1387, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3499, CAST(N'2021-03-31T00:28:48.233' AS DateTime), N'Author', 1388, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3500, CAST(N'2021-03-31T00:28:48.237' AS DateTime), N'Author', 1389, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3501, CAST(N'2021-03-31T00:28:48.240' AS DateTime), N'Author', 1390, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3502, CAST(N'2021-03-31T00:28:48.250' AS DateTime), N'Author', 1391, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3503, CAST(N'2021-03-31T00:28:48.253' AS DateTime), N'Author', 1391, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3504, CAST(N'2021-03-31T00:28:48.260' AS DateTime), N'Patent', 1909, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3505, CAST(N'2021-03-31T00:28:48.260' AS DateTime), N'Author', 1380, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3506, CAST(N'2021-03-31T00:28:48.260' AS DateTime), N'Author', 1381, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3507, CAST(N'2021-03-31T00:28:48.263' AS DateTime), N'Author', 1382, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3508, CAST(N'2021-03-31T00:28:48.263' AS DateTime), N'Author', 1383, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3509, CAST(N'2021-03-31T00:28:48.263' AS DateTime), N'Author', 1384, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3510, CAST(N'2021-03-31T00:28:48.267' AS DateTime), N'Author', 1385, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3511, CAST(N'2021-03-31T00:28:48.267' AS DateTime), N'Author', 1387, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3512, CAST(N'2021-03-31T00:28:48.267' AS DateTime), N'Author', 1388, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3513, CAST(N'2021-03-31T00:28:48.267' AS DateTime), N'Author', 1389, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3514, CAST(N'2021-03-31T00:28:48.270' AS DateTime), N'Author', 1390, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3515, CAST(N'2021-03-31T00:28:48.270' AS DateTime), N'Author', 1391, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3516, CAST(N'2021-03-31T00:31:10.760' AS DateTime), N'Author', 1392, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3517, CAST(N'2021-03-31T00:31:10.817' AS DateTime), N'Author', 1392, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3518, CAST(N'2021-03-31T00:32:30.183' AS DateTime), N'Author', 1393, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3519, CAST(N'2021-03-31T00:32:30.247' AS DateTime), N'Author', 1394, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3520, CAST(N'2021-03-31T00:32:30.250' AS DateTime), N'Author', 1395, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3521, CAST(N'2021-03-31T00:32:30.250' AS DateTime), N'Author', 1396, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3522, CAST(N'2021-03-31T00:32:30.257' AS DateTime), N'Author', 1397, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3523, CAST(N'2021-03-31T00:32:30.263' AS DateTime), N'Author', 1398, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3524, CAST(N'2021-03-31T00:32:30.283' AS DateTime), N'Patent', 1910, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3525, CAST(N'2021-03-31T00:32:30.397' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3526, CAST(N'2021-03-31T00:32:30.437' AS DateTime), N'Author', 1399, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3527, CAST(N'2021-03-31T00:32:30.440' AS DateTime), N'Author', 1399, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3528, CAST(N'2021-03-31T00:32:30.440' AS DateTime), N'Author', 1400, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3529, CAST(N'2021-03-31T00:32:30.443' AS DateTime), N'Author', 1401, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3530, CAST(N'2021-03-31T00:32:30.443' AS DateTime), N'Author', 1402, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3531, CAST(N'2021-03-31T00:32:30.450' AS DateTime), N'Author', 1403, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3532, CAST(N'2021-03-31T00:32:30.460' AS DateTime), N'Author', 1404, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3533, CAST(N'2021-03-31T00:32:30.463' AS DateTime), N'Author', 1404, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3534, CAST(N'2021-03-31T00:32:30.470' AS DateTime), N'Patent', 1910, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3535, CAST(N'2021-03-31T00:32:30.473' AS DateTime), N'Author', 1393, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3536, CAST(N'2021-03-31T00:32:30.473' AS DateTime), N'Author', 1394, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3537, CAST(N'2021-03-31T00:32:30.473' AS DateTime), N'Author', 1395, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3538, CAST(N'2021-03-31T00:32:30.477' AS DateTime), N'Author', 1396, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3539, CAST(N'2021-03-31T00:32:30.477' AS DateTime), N'Author', 1397, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3540, CAST(N'2021-03-31T00:32:30.477' AS DateTime), N'Author', 1398, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3541, CAST(N'2021-03-31T00:32:30.477' AS DateTime), N'Author', 1400, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3542, CAST(N'2021-03-31T00:32:30.477' AS DateTime), N'Author', 1401, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3543, CAST(N'2021-03-31T00:32:30.480' AS DateTime), N'Author', 1402, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3544, CAST(N'2021-03-31T00:32:30.480' AS DateTime), N'Author', 1403, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3545, CAST(N'2021-03-31T00:32:30.480' AS DateTime), N'Author', 1404, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3546, CAST(N'2021-03-31T00:32:39.507' AS DateTime), N'Author', 1405, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3547, CAST(N'2021-03-31T00:32:39.573' AS DateTime), N'Author', 1406, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3548, CAST(N'2021-03-31T00:32:39.577' AS DateTime), N'Author', 1407, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3549, CAST(N'2021-03-31T00:32:39.577' AS DateTime), N'Author', 1408, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3550, CAST(N'2021-03-31T00:32:39.580' AS DateTime), N'Author', 1409, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3551, CAST(N'2021-03-31T00:32:39.590' AS DateTime), N'Author', 1410, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3552, CAST(N'2021-03-31T00:32:39.610' AS DateTime), N'Patent', 1911, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3553, CAST(N'2021-03-31T00:32:39.720' AS DateTime), N'Author', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3554, CAST(N'2021-03-31T00:32:39.757' AS DateTime), N'Author', 1411, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3555, CAST(N'2021-03-31T00:32:39.760' AS DateTime), N'Author', 1411, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3556, CAST(N'2021-03-31T00:32:39.760' AS DateTime), N'Author', 1412, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3557, CAST(N'2021-03-31T00:32:39.760' AS DateTime), N'Author', 1413, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3558, CAST(N'2021-03-31T00:32:39.763' AS DateTime), N'Author', 1414, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3559, CAST(N'2021-03-31T00:32:39.767' AS DateTime), N'Author', 1415, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3560, CAST(N'2021-03-31T00:32:39.780' AS DateTime), N'Author', 1416, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3561, CAST(N'2021-03-31T00:32:39.780' AS DateTime), N'Author', 1416, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3562, CAST(N'2021-03-31T00:32:39.787' AS DateTime), N'Patent', 1911, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3563, CAST(N'2021-03-31T00:32:39.790' AS DateTime), N'Author', 1405, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3564, CAST(N'2021-03-31T00:32:39.790' AS DateTime), N'Author', 1406, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3565, CAST(N'2021-03-31T00:32:39.790' AS DateTime), N'Author', 1407, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3566, CAST(N'2021-03-31T00:32:39.790' AS DateTime), N'Author', 1408, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3567, CAST(N'2021-03-31T00:32:39.790' AS DateTime), N'Author', 1409, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3568, CAST(N'2021-03-31T00:32:39.793' AS DateTime), N'Author', 1410, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3569, CAST(N'2021-03-31T00:32:39.793' AS DateTime), N'Author', 1412, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3570, CAST(N'2021-03-31T00:32:39.793' AS DateTime), N'Author', 1413, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3571, CAST(N'2021-03-31T00:32:39.797' AS DateTime), N'Author', 1414, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3572, CAST(N'2021-03-31T00:32:39.797' AS DateTime), N'Author', 1415, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3573, CAST(N'2021-03-31T00:32:39.797' AS DateTime), N'Author', 1416, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3574, CAST(N'2021-03-31T00:32:39.833' AS DateTime), N'Book', 1912, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3575, CAST(N'2021-03-31T00:32:39.837' AS DateTime), N'Book', 1913, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3576, CAST(N'2021-03-31T00:32:39.840' AS DateTime), N'Book', 1914, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3577, CAST(N'2021-03-31T00:32:39.840' AS DateTime), N'Book', 1915, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3578, CAST(N'2021-03-31T00:32:39.853' AS DateTime), N'Book', 1916, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3579, CAST(N'2021-03-31T00:32:39.853' AS DateTime), N'Book', 1917, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3580, CAST(N'2021-03-31T00:32:39.857' AS DateTime), N'Book', 1918, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3581, CAST(N'2021-03-31T00:32:39.860' AS DateTime), N'Book', 1919, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3582, CAST(N'2021-03-31T00:32:39.873' AS DateTime), N'Author', 1417, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3583, CAST(N'2021-03-31T00:32:39.883' AS DateTime), N'Author', 1418, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3584, CAST(N'2021-03-31T00:32:39.887' AS DateTime), N'Book', 1920, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3585, CAST(N'2021-03-31T00:32:39.893' AS DateTime), N'Book', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3586, CAST(N'2021-03-31T00:32:39.897' AS DateTime), N'Book', 1921, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3587, CAST(N'2021-03-31T00:32:39.900' AS DateTime), N'Book', 1921, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3588, CAST(N'2021-03-31T00:32:39.900' AS DateTime), N'Book', 1922, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3589, CAST(N'2021-03-31T00:32:39.903' AS DateTime), N'Book', 1923, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3590, CAST(N'2021-03-31T00:32:39.907' AS DateTime), N'Book', 1924, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3591, CAST(N'2021-03-31T00:32:39.917' AS DateTime), N'Book', 1925, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3592, CAST(N'2021-03-31T00:32:39.930' AS DateTime), N'Book', 1912, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3593, CAST(N'2021-03-31T00:32:39.933' AS DateTime), N'Book', 1912, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3594, CAST(N'2021-03-31T00:32:39.933' AS DateTime), N'Book', 1913, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3595, CAST(N'2021-03-31T00:32:39.933' AS DateTime), N'Book', 1914, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3596, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1915, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3597, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1916, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3598, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1917, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3599, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1918, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3600, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1919, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3601, CAST(N'2021-03-31T00:32:39.937' AS DateTime), N'Book', 1920, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3602, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Book', 1922, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3603, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Book', 1923, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3604, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Book', 1924, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3605, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Book', 1925, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3606, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Book', 1912, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3607, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Author', 1417, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3608, CAST(N'2021-03-31T00:32:39.940' AS DateTime), N'Author', 1418, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3609, CAST(N'2021-03-31T00:32:39.943' AS DateTime), N'Book', 1926, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3610, CAST(N'2021-03-31T00:32:39.950' AS DateTime), N'Author', 1419, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3611, CAST(N'2021-03-31T00:32:39.950' AS DateTime), N'Author', 1420, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3612, CAST(N'2021-03-31T00:32:39.953' AS DateTime), N'Book', 1927, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3613, CAST(N'2021-03-31T00:32:39.960' AS DateTime), N'Author', 1421, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3614, CAST(N'2021-03-31T00:32:39.963' AS DateTime), N'Patent', 1928, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3615, CAST(N'2021-03-31T00:32:39.970' AS DateTime), N'Author', 1422, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3616, CAST(N'2021-03-31T00:32:39.973' AS DateTime), N'Book', 1929, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3617, CAST(N'2021-03-31T00:32:39.980' AS DateTime), N'Patent', 1930, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3618, CAST(N'2021-03-31T00:32:39.990' AS DateTime), N'Book', 1931, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3619, CAST(N'2021-03-31T00:32:40.000' AS DateTime), N'Book', 1932, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3620, CAST(N'2021-03-31T00:32:40.013' AS DateTime), N'Book', 1933, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3621, CAST(N'2021-03-31T00:32:40.023' AS DateTime), N'Book', 1926, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3622, CAST(N'2021-03-31T00:32:40.023' AS DateTime), N'Book', 1927, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3623, CAST(N'2021-03-31T00:32:40.023' AS DateTime), N'Book', 1929, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3624, CAST(N'2021-03-31T00:32:40.023' AS DateTime), N'Book', 1931, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3625, CAST(N'2021-03-31T00:32:40.027' AS DateTime), N'Book', 1932, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3626, CAST(N'2021-03-31T00:32:40.027' AS DateTime), N'Book', 1933, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3627, CAST(N'2021-03-31T00:32:40.027' AS DateTime), N'Patent', 1928, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3628, CAST(N'2021-03-31T00:32:40.027' AS DateTime), N'Patent', 1930, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3629, CAST(N'2021-03-31T00:32:40.027' AS DateTime), N'Author', 1419, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3630, CAST(N'2021-03-31T00:32:40.030' AS DateTime), N'Author', 1420, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3631, CAST(N'2021-03-31T00:32:40.030' AS DateTime), N'Author', 1421, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3632, CAST(N'2021-03-31T00:32:40.030' AS DateTime), N'Author', 1422, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3633, CAST(N'2021-03-31T00:32:40.043' AS DateTime), N'Newspaper', 1934, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3634, CAST(N'2021-03-31T00:32:40.047' AS DateTime), N'Newspaper', 1935, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3635, CAST(N'2021-03-31T00:32:40.053' AS DateTime), N'Newspaper', 1936, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3636, CAST(N'2021-03-31T00:32:40.053' AS DateTime), N'Newspaper', 1937, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3637, CAST(N'2021-03-31T00:32:40.063' AS DateTime), N'Newspaper', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3638, CAST(N'2021-03-31T00:32:40.067' AS DateTime), N'Newspaper', 1938, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3639, CAST(N'2021-03-31T00:32:40.070' AS DateTime), N'Newspaper', 1938, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3640, CAST(N'2021-03-31T00:32:40.070' AS DateTime), N'Newspaper', 1939, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3641, CAST(N'2021-03-31T00:32:40.070' AS DateTime), N'Newspaper', 1940, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3642, CAST(N'2021-03-31T00:32:40.073' AS DateTime), N'Newspaper', 1941, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3643, CAST(N'2021-03-31T00:32:40.087' AS DateTime), N'Newspaper', 1942, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3644, CAST(N'2021-03-31T00:32:40.090' AS DateTime), N'Newspaper', 1942, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3645, CAST(N'2021-03-31T00:32:40.090' AS DateTime), N'Newspaper', 1934, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3646, CAST(N'2021-03-31T00:32:40.093' AS DateTime), N'Newspaper', 1935, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3647, CAST(N'2021-03-31T00:32:40.093' AS DateTime), N'Newspaper', 1936, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3648, CAST(N'2021-03-31T00:32:40.093' AS DateTime), N'Newspaper', 1937, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3649, CAST(N'2021-03-31T00:32:40.093' AS DateTime), N'Newspaper', 1939, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3650, CAST(N'2021-03-31T00:32:40.093' AS DateTime), N'Newspaper', 1940, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3651, CAST(N'2021-03-31T00:32:40.097' AS DateTime), N'Newspaper', 1941, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3652, CAST(N'2021-03-31T00:32:40.097' AS DateTime), N'Newspaper', 1942, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3653, CAST(N'2021-03-31T00:32:40.110' AS DateTime), N'Patent', 1943, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3654, CAST(N'2021-03-31T00:32:40.113' AS DateTime), N'Patent', 1944, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3655, CAST(N'2021-03-31T00:32:40.120' AS DateTime), N'Patent', 1945, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3656, CAST(N'2021-03-31T00:32:40.123' AS DateTime), N'Patent', 1946, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3657, CAST(N'2021-03-31T00:32:40.133' AS DateTime), N'Author', 1423, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3658, CAST(N'2021-03-31T00:32:40.143' AS DateTime), N'Author', 1424, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3659, CAST(N'2021-03-31T00:32:40.147' AS DateTime), N'Patent', 1947, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3660, CAST(N'2021-03-31T00:32:40.150' AS DateTime), N'Patent', -30000, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3661, CAST(N'2021-03-31T00:32:40.157' AS DateTime), N'Patent', 1948, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3662, CAST(N'2021-03-31T00:32:40.157' AS DateTime), N'Patent', 1948, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3663, CAST(N'2021-03-31T00:32:40.160' AS DateTime), N'Patent', 1949, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3664, CAST(N'2021-03-31T00:32:40.167' AS DateTime), N'Patent', 1950, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3665, CAST(N'2021-03-31T00:32:40.170' AS DateTime), N'Patent', 1951, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3666, CAST(N'2021-03-31T00:32:40.193' AS DateTime), N'Patent', 1943, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3667, CAST(N'2021-03-31T00:32:40.197' AS DateTime), N'Patent', 1943, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3668, CAST(N'2021-03-31T00:32:40.197' AS DateTime), N'Patent', 1944, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3669, CAST(N'2021-03-31T00:32:40.197' AS DateTime), N'Patent', 1945, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3670, CAST(N'2021-03-31T00:32:40.197' AS DateTime), N'Patent', 1946, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3671, CAST(N'2021-03-31T00:32:40.197' AS DateTime), N'Patent', 1947, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3672, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Patent', 1949, N'Mark 1', N'dbo')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3673, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Patent', 1950, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3674, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Patent', 1951, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3675, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Patent', 1943, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3676, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Author', 1423, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3677, CAST(N'2021-03-31T00:32:40.200' AS DateTime), N'Author', 1424, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3678, CAST(N'2021-04-01T11:49:20.650' AS DateTime), N'Author', 1425, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3679, CAST(N'2021-04-01T11:49:29.947' AS DateTime), N'Author', 1426, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3680, CAST(N'2021-04-01T19:03:36.127' AS DateTime), N'Author', 1427, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3681, CAST(N'2021-04-01T19:42:20.923' AS DateTime), N'Author', 1428, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3682, CAST(N'2021-04-01T19:47:18.887' AS DateTime), N'Author', 1429, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3683, CAST(N'2021-04-01T19:57:22.683' AS DateTime), N'Author', 1430, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3684, CAST(N'2021-04-01T19:59:26.470' AS DateTime), N'Author', 1431, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3685, CAST(N'2021-04-01T19:59:59.727' AS DateTime), N'Author', 1432, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3686, CAST(N'2021-04-01T20:01:22.983' AS DateTime), N'Author', 1433, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3687, CAST(N'2021-04-01T20:02:44.170' AS DateTime), N'Author', 1434, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3688, CAST(N'2021-04-01T20:03:31.510' AS DateTime), N'Author', 1435, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3689, CAST(N'2021-04-01T20:05:24.177' AS DateTime), N'Author', 1436, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3690, CAST(N'2021-04-01T20:06:49.267' AS DateTime), N'Author', 1437, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3691, CAST(N'2021-04-01T21:29:08.787' AS DateTime), N'Author', 1438, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3692, CAST(N'2021-04-01T21:32:43.210' AS DateTime), N'Author', 1439, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3693, CAST(N'2021-04-01T21:35:02.013' AS DateTime), N'Author', 1440, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3694, CAST(N'2021-04-01T21:37:07.280' AS DateTime), N'Author', 1441, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3695, CAST(N'2021-04-01T21:39:04.077' AS DateTime), N'Author', 1442, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3696, CAST(N'2021-04-01T21:39:36.453' AS DateTime), N'Author', 1443, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3697, CAST(N'2021-04-01T21:42:27.800' AS DateTime), N'Author', 1444, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3698, CAST(N'2021-04-01T21:43:56.117' AS DateTime), N'Book', 1952, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3699, CAST(N'2021-04-01T21:48:43.287' AS DateTime), N'Book', 1953, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3700, CAST(N'2021-04-02T13:54:50.740' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3701, CAST(N'2021-04-02T13:58:18.040' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3702, CAST(N'2021-04-02T13:59:33.427' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3703, CAST(N'2021-04-02T13:59:54.157' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3704, CAST(N'2021-04-02T14:00:10.330' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3705, CAST(N'2021-04-02T14:00:32.370' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3706, CAST(N'2021-04-02T14:01:09.587' AS DateTime), N'Book', 1905, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3707, CAST(N'2021-04-02T14:01:52.583' AS DateTime), N'Book', 1952, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3708, CAST(N'2021-04-02T15:03:37.637' AS DateTime), N'Book', 1906, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3709, CAST(N'2021-04-02T20:03:40.547' AS DateTime), N'Author', 1445, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3710, CAST(N'2021-04-02T20:04:42.040' AS DateTime), N'Book', 1954, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3711, CAST(N'2021-04-02T20:06:13.797' AS DateTime), N'Book', 1954, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3712, CAST(N'2021-04-02T20:06:39.650' AS DateTime), N'Book', 1954, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3713, CAST(N'2021-04-05T22:45:40.510' AS DateTime), N'Book', 1952, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3714, CAST(N'2021-04-05T22:46:17.513' AS DateTime), N'Book', 1955, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3715, CAST(N'2021-04-05T22:46:35.983' AS DateTime), N'Book', 1955, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3716, CAST(N'2021-04-07T15:02:55.960' AS DateTime), N'Role', 2, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3717, CAST(N'2021-04-07T15:03:50.230' AS DateTime), N'Role', 3, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3718, CAST(N'2021-04-07T23:40:52.780' AS DateTime), N'User', 1, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3719, CAST(N'2021-04-09T13:21:01.960' AS DateTime), N'Patent', 1956, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3720, CAST(N'2021-04-09T13:31:02.747' AS DateTime), N'Author', 1446, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3721, CAST(N'2021-04-09T13:31:28.363' AS DateTime), N'Patent', 1956, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3722, CAST(N'2021-04-09T13:38:01.260' AS DateTime), N'Patent', 1957, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3723, CAST(N'2021-04-09T13:39:40.670' AS DateTime), N'Patent', 1957, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3724, CAST(N'2021-04-09T16:49:36.103' AS DateTime), N'User', 1, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3725, CAST(N'2021-04-09T16:49:39.430' AS DateTime), N'User', 1, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3726, CAST(N'2021-04-09T16:49:46.567' AS DateTime), N'User', 1, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3727, CAST(N'2021-04-09T17:43:51.803' AS DateTime), N'User', 1, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3728, CAST(N'2021-04-09T17:43:56.930' AS DateTime), N'User', 1, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3729, CAST(N'2021-04-09T20:02:53.983' AS DateTime), N'Book', 916, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3730, CAST(N'2021-04-12T18:26:58.103' AS DateTime), N'Book', 1958, N'Add', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3731, CAST(N'2021-04-12T19:21:08.353' AS DateTime), N'Book', 1958, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3732, CAST(N'2021-04-12T19:21:26.907' AS DateTime), N'Book', 1959, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3733, CAST(N'2021-04-12T19:21:32.940' AS DateTime), N'Book', 1959, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3734, CAST(N'2021-04-12T19:23:58.540' AS DateTime), N'Patent', 1960, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3735, CAST(N'2021-04-12T19:24:08.400' AS DateTime), N'Patent', 1960, N'Mark 1', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3736, CAST(N'2021-04-12T21:11:20.113' AS DateTime), N'Book', 1961, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3737, CAST(N'2021-04-12T21:11:32.380' AS DateTime), N'Book', 1961, N'Mark 1', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3738, CAST(N'2021-04-13T13:38:17.780' AS DateTime), N'Newspaper', 1, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3739, CAST(N'2021-04-13T13:38:42.197' AS DateTime), N'Newspaper', 2, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3740, CAST(N'2021-04-13T13:41:10.033' AS DateTime), N'Newspaper', 2, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3741, CAST(N'2021-04-13T13:48:26.633' AS DateTime), N'Newspaper', 3, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3742, CAST(N'2021-04-13T13:51:46.280' AS DateTime), N'Newspaper', 4, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3743, CAST(N'2021-04-13T13:53:23.690' AS DateTime), N'Newspaper', 5, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3744, CAST(N'2021-04-13T13:55:53.963' AS DateTime), N'Newspaper', 6, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3745, CAST(N'2021-04-13T13:58:55.263' AS DateTime), N'Newspaper', 2, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3746, CAST(N'2021-04-13T13:58:59.780' AS DateTime), N'Newspaper', 3, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3747, CAST(N'2021-04-13T13:59:02.803' AS DateTime), N'Newspaper', 4, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3748, CAST(N'2021-04-13T13:59:05.350' AS DateTime), N'Newspaper', 5, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3749, CAST(N'2021-04-13T14:25:47.250' AS DateTime), N'NewspaperIssue', 1962, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3750, CAST(N'2021-04-13T14:26:32.353' AS DateTime), N'NewspaperIssue', 1963, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3751, CAST(N'2021-04-13T14:28:12.713' AS DateTime), N'NewspaperIssue', 1966, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3752, CAST(N'2021-04-13T14:33:00.073' AS DateTime), N'NewspaperIssue', 1967, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3753, CAST(N'2021-04-13T14:35:38.480' AS DateTime), N'NewspaperIssue', 1968, N'Add', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3754, CAST(N'2021-04-13T14:43:14.000' AS DateTime), N'NewspaperIssues', 1963, N'Update', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3755, CAST(N'2021-04-13T14:48:21.247' AS DateTime), N'NewspaperIssue', 1967, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (3756, CAST(N'2021-04-13T14:48:26.160' AS DateTime), N'NewspaperIssue', 1968, N'Mark 1', N'dbo')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (4738, CAST(N'2021-04-16T15:43:02.403' AS DateTime), N'NewspaperIssue', 2962, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5738, CAST(N'2021-04-16T17:26:37.970' AS DateTime), N'Newspaper', 1002, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5739, CAST(N'2021-04-16T17:28:21.010' AS DateTime), N'Newspaper', 1003, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5740, CAST(N'2021-04-16T18:22:02.443' AS DateTime), N'Newspaper', 1004, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5741, CAST(N'2021-04-16T18:23:01.660' AS DateTime), N'NewspaperIssue', 3962, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5742, CAST(N'2021-04-16T22:41:20.813' AS DateTime), N'NewspaperIssue', 3963, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5743, CAST(N'2021-04-16T23:48:38.383' AS DateTime), N'NewspaperIssues', 3962, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5744, CAST(N'2021-04-19T14:11:12.740' AS DateTime), N'Patent', 3964, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5745, CAST(N'2021-04-19T14:15:01.697' AS DateTime), N'Patent', 3964, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5746, CAST(N'2021-04-19T14:53:59.117' AS DateTime), N'NewspaperIssues', 3962, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5747, CAST(N'2021-04-21T22:26:09.250' AS DateTime), N'Author', 1447, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5748, CAST(N'2021-04-21T22:28:56.930' AS DateTime), N'Author', 1448, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5749, CAST(N'2021-04-21T22:28:57.003' AS DateTime), N'Author', 1449, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5750, CAST(N'2021-04-21T22:28:57.003' AS DateTime), N'Author', 1450, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5751, CAST(N'2021-04-21T22:28:57.003' AS DateTime), N'Author', 1451, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5752, CAST(N'2021-04-21T22:28:57.017' AS DateTime), N'Author', 1452, N'Add', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5753, CAST(N'2021-04-21T22:28:57.037' AS DateTime), N'Patent', 3965, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5754, CAST(N'2021-04-21T22:28:57.150' AS DateTime), N'Author', 1453, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5755, CAST(N'2021-04-21T22:28:57.183' AS DateTime), N'Author', 1454, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5756, CAST(N'2021-04-21T22:28:57.187' AS DateTime), N'Author', 1455, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5757, CAST(N'2021-04-21T22:28:57.190' AS DateTime), N'Author', 1456, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5758, CAST(N'2021-04-21T22:28:57.193' AS DateTime), N'Author', 1457, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5759, CAST(N'2021-04-21T22:28:57.203' AS DateTime), N'Author', 1458, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5760, CAST(N'2021-04-21T22:28:57.207' AS DateTime), N'Author', 1458, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5761, CAST(N'2021-04-21T22:29:38.923' AS DateTime), N'Author', 1459, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5762, CAST(N'2021-04-21T22:29:38.960' AS DateTime), N'Book', 3966, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5763, CAST(N'2021-04-21T22:29:38.963' AS DateTime), N'Book', 3967, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5764, CAST(N'2021-04-21T22:29:38.967' AS DateTime), N'Book', 3968, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5765, CAST(N'2021-04-21T22:29:38.967' AS DateTime), N'Book', 3969, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5766, CAST(N'2021-04-21T22:29:38.977' AS DateTime), N'Book', 3970, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5767, CAST(N'2021-04-21T22:29:38.977' AS DateTime), N'Book', 3971, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5768, CAST(N'2021-04-21T22:29:38.980' AS DateTime), N'Book', 3972, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5769, CAST(N'2021-04-21T22:29:38.983' AS DateTime), N'Book', 3973, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5770, CAST(N'2021-04-21T22:29:38.997' AS DateTime), N'Author', 1460, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5771, CAST(N'2021-04-21T22:29:39.007' AS DateTime), N'Author', 1461, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5772, CAST(N'2021-04-21T22:29:39.010' AS DateTime), N'Book', 3974, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5773, CAST(N'2021-04-21T22:29:39.013' AS DateTime), N'Book', 3975, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5774, CAST(N'2021-04-21T22:29:39.020' AS DateTime), N'Book', 3976, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5775, CAST(N'2021-04-21T22:29:39.023' AS DateTime), N'Book', 3977, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5776, CAST(N'2021-04-21T22:29:39.023' AS DateTime), N'Book', 3978, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5777, CAST(N'2021-04-21T22:29:39.033' AS DateTime), N'Book', 3979, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5778, CAST(N'2021-04-21T22:29:39.047' AS DateTime), N'Book', 3966, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5779, CAST(N'2021-04-21T22:29:39.067' AS DateTime), N'Author', 1462, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5780, CAST(N'2021-04-21T22:29:39.067' AS DateTime), N'Book', 3980, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5781, CAST(N'2021-04-21T22:29:39.080' AS DateTime), N'Author', 1463, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5782, CAST(N'2021-04-21T22:29:39.083' AS DateTime), N'Patent', 3981, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5783, CAST(N'2021-04-21T22:29:39.093' AS DateTime), N'Author', 1464, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5784, CAST(N'2021-04-21T22:29:39.097' AS DateTime), N'Book', 3982, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5785, CAST(N'2021-04-21T22:29:39.157' AS DateTime), N'Patent', 3983, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5786, CAST(N'2021-04-21T22:29:39.160' AS DateTime), N'Patent', 3984, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5787, CAST(N'2021-04-21T22:29:39.167' AS DateTime), N'Patent', 3985, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5788, CAST(N'2021-04-21T22:29:39.170' AS DateTime), N'Patent', 3986, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5789, CAST(N'2021-04-21T22:29:39.190' AS DateTime), N'Patent', 3987, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5790, CAST(N'2021-04-21T22:29:39.200' AS DateTime), N'Patent', 3988, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5791, CAST(N'2021-04-21T22:29:39.203' AS DateTime), N'Patent', 3989, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5792, CAST(N'2021-04-21T22:29:39.207' AS DateTime), N'Patent', 3990, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5793, CAST(N'2021-04-21T22:29:39.213' AS DateTime), N'Patent', 3991, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5794, CAST(N'2021-04-21T22:29:39.233' AS DateTime), N'Patent', 3983, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5795, CAST(N'2021-04-21T23:16:26.177' AS DateTime), N'Book', 3992, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5796, CAST(N'2021-04-21T23:16:35.513' AS DateTime), N'Book', 3993, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5797, CAST(N'2021-04-21T23:16:35.590' AS DateTime), N'Book', 3994, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5798, CAST(N'2021-04-21T23:16:35.597' AS DateTime), N'Book', 3995, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5799, CAST(N'2021-04-21T23:16:57.320' AS DateTime), N'Author', 1465, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5800, CAST(N'2021-04-21T23:16:57.413' AS DateTime), N'Author', 1466, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5801, CAST(N'2021-04-21T23:16:57.490' AS DateTime), N'Book', 3996, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5802, CAST(N'2021-04-21T23:16:57.627' AS DateTime), N'Author', 1467, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5803, CAST(N'2021-04-21T23:16:57.657' AS DateTime), N'Patent', 3997, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5804, CAST(N'2021-04-21T23:16:57.700' AS DateTime), N'Author', 1468, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5805, CAST(N'2021-04-21T23:16:57.717' AS DateTime), N'Book', 3998, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5806, CAST(N'2021-04-21T23:16:57.733' AS DateTime), N'Patent', 3999, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5807, CAST(N'2021-04-21T23:17:30.767' AS DateTime), N'Author', 1469, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5808, CAST(N'2021-04-21T23:17:30.837' AS DateTime), N'Author', 1470, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5809, CAST(N'2021-04-21T23:17:30.837' AS DateTime), N'Author', 1471, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5810, CAST(N'2021-04-21T23:17:30.840' AS DateTime), N'Author', 1472, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5811, CAST(N'2021-04-21T23:17:30.843' AS DateTime), N'Author', 1473, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5812, CAST(N'2021-04-21T23:17:30.850' AS DateTime), N'Author', 1474, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5813, CAST(N'2021-04-21T23:17:30.870' AS DateTime), N'Patent', 4000, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5814, CAST(N'2021-04-21T23:17:30.990' AS DateTime), N'Author', 1475, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5815, CAST(N'2021-04-21T23:17:31.023' AS DateTime), N'Author', 1476, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5816, CAST(N'2021-04-21T23:17:31.027' AS DateTime), N'Author', 1477, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5817, CAST(N'2021-04-21T23:17:31.030' AS DateTime), N'Author', 1478, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5818, CAST(N'2021-04-21T23:17:31.033' AS DateTime), N'Author', 1479, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5819, CAST(N'2021-04-21T23:17:31.043' AS DateTime), N'Author', 1480, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (5820, CAST(N'2021-04-21T23:17:31.047' AS DateTime), N'Author', 1480, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6795, CAST(N'2021-04-22T15:38:03.683' AS DateTime), N'Newspaper', 1005, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6796, CAST(N'2021-04-22T15:38:03.707' AS DateTime), N'Newspaper', 1006, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6797, CAST(N'2021-04-22T15:38:03.733' AS DateTime), N'Newspaper', 1007, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6798, CAST(N'2021-04-22T15:38:03.803' AS DateTime), N'Newspaper', 1008, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6799, CAST(N'2021-04-22T15:38:03.810' AS DateTime), N'Newspaper', 1009, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6800, CAST(N'2021-04-22T15:38:03.817' AS DateTime), N'Newspaper', 1010, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6801, CAST(N'2021-04-22T15:46:29.440' AS DateTime), N'Newspaper', 1005, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6802, CAST(N'2021-04-22T15:46:46.637' AS DateTime), N'Newspaper', 1011, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6803, CAST(N'2021-04-22T15:50:52.867' AS DateTime), N'Newspaper', 1007, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6804, CAST(N'2021-04-22T15:51:01.793' AS DateTime), N'Newspaper', 1012, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6805, CAST(N'2021-04-22T15:51:01.797' AS DateTime), N'Newspaper', 1012, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6806, CAST(N'2021-04-22T15:53:23.060' AS DateTime), N'Newspaper', 1013, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6807, CAST(N'2021-04-22T15:53:23.080' AS DateTime), N'Newspaper', 1014, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6808, CAST(N'2021-04-22T15:53:23.090' AS DateTime), N'Newspaper', 1015, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6809, CAST(N'2021-04-22T15:53:23.093' AS DateTime), N'Newspaper', 1015, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6810, CAST(N'2021-04-22T15:53:23.097' AS DateTime), N'Newspaper', 1016, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6811, CAST(N'2021-04-22T15:53:23.097' AS DateTime), N'Newspaper', 1017, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6812, CAST(N'2021-04-22T15:53:23.100' AS DateTime), N'Newspaper', 1018, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6813, CAST(N'2021-04-22T15:53:23.110' AS DateTime), N'Newspaper', 1013, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6814, CAST(N'2021-04-22T15:53:30.173' AS DateTime), N'Newspaper', 1019, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6815, CAST(N'2021-04-22T15:53:30.197' AS DateTime), N'Newspaper', 1020, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6816, CAST(N'2021-04-22T15:53:30.200' AS DateTime), N'Newspaper', 1020, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6817, CAST(N'2021-04-22T15:53:37.970' AS DateTime), N'Newspaper', 1021, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6818, CAST(N'2021-04-22T15:53:37.977' AS DateTime), N'Newspaper', 1021, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6819, CAST(N'2021-04-22T15:54:21.027' AS DateTime), N'Newspaper', 1022, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6820, CAST(N'2021-04-22T15:54:21.043' AS DateTime), N'Newspaper', 1023, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6821, CAST(N'2021-04-22T15:54:21.053' AS DateTime), N'Newspaper', 1024, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6822, CAST(N'2021-04-22T15:54:21.057' AS DateTime), N'Newspaper', 1024, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6823, CAST(N'2021-04-22T15:54:21.060' AS DateTime), N'Newspaper', 1025, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6824, CAST(N'2021-04-22T15:54:21.060' AS DateTime), N'Newspaper', 1026, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6825, CAST(N'2021-04-22T15:54:21.060' AS DateTime), N'Newspaper', 1027, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6826, CAST(N'2021-04-22T15:54:21.073' AS DateTime), N'Newspaper', 1022, N'Update', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6827, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1022, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6828, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1023, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6829, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1025, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6830, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1026, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6831, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1027, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6832, CAST(N'2021-04-22T15:54:21.077' AS DateTime), N'Newspaper', 1022, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6833, CAST(N'2021-04-22T15:54:27.700' AS DateTime), N'Newspaper', 1028, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6834, CAST(N'2021-04-22T15:54:27.717' AS DateTime), N'Newspaper', 1029, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6835, CAST(N'2021-04-22T15:54:27.727' AS DateTime), N'Newspaper', 1030, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6836, CAST(N'2021-04-22T15:54:27.730' AS DateTime), N'Newspaper', 1030, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6837, CAST(N'2021-04-22T15:54:27.733' AS DateTime), N'Newspaper', 1031, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6838, CAST(N'2021-04-22T15:54:27.733' AS DateTime), N'Newspaper', 1032, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6839, CAST(N'2021-04-22T15:54:27.737' AS DateTime), N'Newspaper', 1033, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6840, CAST(N'2021-04-22T15:54:27.747' AS DateTime), N'Newspaper', 1028, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6841, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1028, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6842, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1029, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6843, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1031, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6844, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1032, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6845, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1033, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6846, CAST(N'2021-04-22T15:54:27.750' AS DateTime), N'Newspaper', 1028, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6847, CAST(N'2021-04-22T15:54:33.450' AS DateTime), N'Newspaper', 1034, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6848, CAST(N'2021-04-22T15:54:33.467' AS DateTime), N'Newspaper', 1035, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6849, CAST(N'2021-04-22T15:54:33.480' AS DateTime), N'Newspaper', 1036, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6850, CAST(N'2021-04-22T15:54:33.483' AS DateTime), N'Newspaper', 1036, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6851, CAST(N'2021-04-22T15:54:33.487' AS DateTime), N'Newspaper', 1037, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6852, CAST(N'2021-04-22T15:54:33.487' AS DateTime), N'Newspaper', 1038, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6853, CAST(N'2021-04-22T15:54:33.490' AS DateTime), N'Newspaper', 1039, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6854, CAST(N'2021-04-22T15:54:33.503' AS DateTime), N'Newspaper', 1034, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6855, CAST(N'2021-04-22T15:54:33.507' AS DateTime), N'Newspaper', 1034, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6856, CAST(N'2021-04-22T15:54:33.507' AS DateTime), N'Newspaper', 1035, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6857, CAST(N'2021-04-22T15:54:33.507' AS DateTime), N'Newspaper', 1037, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6858, CAST(N'2021-04-22T15:54:33.507' AS DateTime), N'Newspaper', 1038, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6859, CAST(N'2021-04-22T15:54:33.510' AS DateTime), N'Newspaper', 1039, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6860, CAST(N'2021-04-22T15:54:33.510' AS DateTime), N'Newspaper', 1034, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6861, CAST(N'2021-04-22T15:56:57.800' AS DateTime), N'Author', 2465, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6862, CAST(N'2021-04-22T15:56:57.897' AS DateTime), N'Author', 2466, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6863, CAST(N'2021-04-22T15:56:57.897' AS DateTime), N'Author', 2467, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6864, CAST(N'2021-04-22T15:56:57.897' AS DateTime), N'Author', 2468, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6865, CAST(N'2021-04-22T15:56:57.900' AS DateTime), N'Author', 2469, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6866, CAST(N'2021-04-22T15:56:57.910' AS DateTime), N'Author', 2470, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6867, CAST(N'2021-04-22T15:56:57.927' AS DateTime), N'Patent', 4992, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6868, CAST(N'2021-04-22T15:56:58.050' AS DateTime), N'Author', 2471, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6869, CAST(N'2021-04-22T15:56:58.083' AS DateTime), N'Author', 2472, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6870, CAST(N'2021-04-22T15:56:58.083' AS DateTime), N'Author', 2473, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6871, CAST(N'2021-04-22T15:56:58.087' AS DateTime), N'Author', 2474, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6872, CAST(N'2021-04-22T15:56:58.090' AS DateTime), N'Author', 2475, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6873, CAST(N'2021-04-22T15:56:58.097' AS DateTime), N'Author', 2476, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6874, CAST(N'2021-04-22T15:56:58.100' AS DateTime), N'Author', 2476, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6875, CAST(N'2021-04-22T15:56:58.107' AS DateTime), N'Patent', 4992, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6876, CAST(N'2021-04-22T15:57:50.267' AS DateTime), N'Author', 2477, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6877, CAST(N'2021-04-22T15:57:50.330' AS DateTime), N'Author', 2478, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6878, CAST(N'2021-04-22T15:57:50.333' AS DateTime), N'Author', 2479, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6879, CAST(N'2021-04-22T15:57:50.333' AS DateTime), N'Author', 2480, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6880, CAST(N'2021-04-22T15:57:50.337' AS DateTime), N'Author', 2481, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6881, CAST(N'2021-04-22T15:57:50.343' AS DateTime), N'Author', 2482, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6882, CAST(N'2021-04-22T15:57:50.353' AS DateTime), N'Patent', 4993, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6883, CAST(N'2021-04-22T15:57:50.440' AS DateTime), N'Author', 2483, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6884, CAST(N'2021-04-22T15:57:50.473' AS DateTime), N'Author', 2484, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6885, CAST(N'2021-04-22T15:57:50.477' AS DateTime), N'Author', 2485, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6886, CAST(N'2021-04-22T15:57:50.480' AS DateTime), N'Author', 2486, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6887, CAST(N'2021-04-22T15:57:50.480' AS DateTime), N'Author', 2487, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6888, CAST(N'2021-04-22T15:57:50.487' AS DateTime), N'Author', 2488, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6889, CAST(N'2021-04-22T15:57:50.487' AS DateTime), N'Author', 2488, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6890, CAST(N'2021-04-22T15:57:50.490' AS DateTime), N'Patent', 4993, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6891, CAST(N'2021-04-22T16:00:27.330' AS DateTime), N'Author', 2489, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6892, CAST(N'2021-04-22T16:08:59.410' AS DateTime), N'Author', 2490, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6893, CAST(N'2021-04-22T16:12:06.760' AS DateTime), N'Author', 2491, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6894, CAST(N'2021-04-22T16:21:03.190' AS DateTime), N'Author', 2491, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6895, CAST(N'2021-04-22T16:21:58.450' AS DateTime), N'Author', 2492, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6896, CAST(N'2021-04-22T16:22:32.913' AS DateTime), N'Author', 2493, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6897, CAST(N'2021-04-22T16:22:32.977' AS DateTime), N'Author', 2494, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6898, CAST(N'2021-04-22T16:22:32.977' AS DateTime), N'Author', 2495, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6899, CAST(N'2021-04-22T16:22:32.980' AS DateTime), N'Author', 2496, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6900, CAST(N'2021-04-22T16:22:32.983' AS DateTime), N'Author', 2497, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6901, CAST(N'2021-04-22T16:22:32.990' AS DateTime), N'Author', 2498, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6902, CAST(N'2021-04-22T16:22:33.007' AS DateTime), N'Patent', 4994, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6903, CAST(N'2021-04-22T16:22:33.120' AS DateTime), N'Author', 2492, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6904, CAST(N'2021-04-22T16:22:33.123' AS DateTime), N'Author', 2499, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6905, CAST(N'2021-04-22T16:22:33.127' AS DateTime), N'Author', 2500, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6906, CAST(N'2021-04-22T16:22:33.127' AS DateTime), N'Author', 2501, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6907, CAST(N'2021-04-22T16:22:33.130' AS DateTime), N'Author', 2502, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6908, CAST(N'2021-04-22T16:22:33.140' AS DateTime), N'Author', 2503, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6909, CAST(N'2021-04-22T16:22:33.140' AS DateTime), N'Author', 2503, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6910, CAST(N'2021-04-22T16:22:33.147' AS DateTime), N'Patent', 4994, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6911, CAST(N'2021-04-22T16:22:33.147' AS DateTime), N'Author', 2493, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6912, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2494, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6913, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2495, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6914, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2496, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6915, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2497, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6916, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2498, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6917, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2499, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6918, CAST(N'2021-04-22T16:22:33.150' AS DateTime), N'Author', 2500, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6919, CAST(N'2021-04-22T16:22:33.153' AS DateTime), N'Author', 2501, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6920, CAST(N'2021-04-22T16:22:33.153' AS DateTime), N'Author', 2502, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6921, CAST(N'2021-04-22T16:22:33.153' AS DateTime), N'Author', 2503, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6922, CAST(N'2021-04-22T16:27:10.943' AS DateTime), N'Book', 4995, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6923, CAST(N'2021-04-22T16:27:10.977' AS DateTime), N'Book', 4996, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6924, CAST(N'2021-04-22T16:27:10.987' AS DateTime), N'Book', 4997, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6925, CAST(N'2021-04-22T16:27:10.987' AS DateTime), N'Book', 4998, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6926, CAST(N'2021-04-22T16:27:10.997' AS DateTime), N'Book', 4999, N'Add', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6927, CAST(N'2021-04-22T16:27:10.997' AS DateTime), N'Book', 5000, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6928, CAST(N'2021-04-22T16:27:11.000' AS DateTime), N'Book', 5001, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6929, CAST(N'2021-04-22T16:27:11.003' AS DateTime), N'Book', 5002, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6930, CAST(N'2021-04-22T16:27:11.020' AS DateTime), N'Author', 2504, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6931, CAST(N'2021-04-22T16:27:11.033' AS DateTime), N'Author', 2505, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6932, CAST(N'2021-04-22T16:27:11.057' AS DateTime), N'Book', 5003, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6933, CAST(N'2021-04-22T16:27:11.153' AS DateTime), N'Book', 5004, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6934, CAST(N'2021-04-22T16:27:11.160' AS DateTime), N'Book', 5004, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6935, CAST(N'2021-04-22T16:27:11.160' AS DateTime), N'Book', 5005, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6936, CAST(N'2021-04-22T16:27:11.163' AS DateTime), N'Book', 5006, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6937, CAST(N'2021-04-22T16:27:11.167' AS DateTime), N'Book', 5007, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6938, CAST(N'2021-04-22T16:27:11.173' AS DateTime), N'Book', 5008, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6939, CAST(N'2021-04-22T16:27:11.190' AS DateTime), N'Book', 4995, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6940, CAST(N'2021-04-22T16:27:11.193' AS DateTime), N'Book', 4995, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6941, CAST(N'2021-04-22T16:27:11.193' AS DateTime), N'Book', 4996, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6942, CAST(N'2021-04-22T16:27:11.193' AS DateTime), N'Book', 4997, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6943, CAST(N'2021-04-22T16:27:11.193' AS DateTime), N'Book', 4998, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6944, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 4999, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6945, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5000, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6946, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5001, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6947, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5002, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6948, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5003, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6949, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5005, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6950, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5006, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6951, CAST(N'2021-04-22T16:27:11.197' AS DateTime), N'Book', 5007, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6952, CAST(N'2021-04-22T16:27:11.200' AS DateTime), N'Book', 5008, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6953, CAST(N'2021-04-22T16:27:11.200' AS DateTime), N'Book', 4995, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6954, CAST(N'2021-04-22T16:27:11.207' AS DateTime), N'Author', 2504, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6955, CAST(N'2021-04-22T16:27:11.207' AS DateTime), N'Author', 2505, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6956, CAST(N'2021-04-22T16:28:51.360' AS DateTime), N'Book', 5009, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6957, CAST(N'2021-04-22T16:28:51.453' AS DateTime), N'Author', 2506, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6958, CAST(N'2021-04-22T16:28:51.470' AS DateTime), N'Author', 2507, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6959, CAST(N'2021-04-22T16:28:51.497' AS DateTime), N'Book', 5010, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6960, CAST(N'2021-04-22T16:28:51.580' AS DateTime), N'Author', 2508, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6961, CAST(N'2021-04-22T16:28:51.597' AS DateTime), N'Patent', 5011, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6962, CAST(N'2021-04-22T16:28:51.610' AS DateTime), N'Author', 2509, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6963, CAST(N'2021-04-22T16:28:51.617' AS DateTime), N'Book', 5012, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6964, CAST(N'2021-04-22T16:28:51.630' AS DateTime), N'Patent', 5013, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6965, CAST(N'2021-04-22T16:28:51.637' AS DateTime), N'Book', 5014, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6966, CAST(N'2021-04-22T16:28:51.647' AS DateTime), N'Book', 5015, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6967, CAST(N'2021-04-22T16:28:51.660' AS DateTime), N'Book', 5016, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6968, CAST(N'2021-04-22T16:28:51.670' AS DateTime), N'Book', 5009, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6969, CAST(N'2021-04-22T16:28:51.670' AS DateTime), N'Book', 5010, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6970, CAST(N'2021-04-22T16:28:51.670' AS DateTime), N'Book', 5012, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6971, CAST(N'2021-04-22T16:28:51.673' AS DateTime), N'Book', 5014, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6972, CAST(N'2021-04-22T16:28:51.673' AS DateTime), N'Book', 5015, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6973, CAST(N'2021-04-22T16:28:51.673' AS DateTime), N'Book', 5016, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6974, CAST(N'2021-04-22T16:28:51.677' AS DateTime), N'Patent', 5011, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6975, CAST(N'2021-04-22T16:28:51.677' AS DateTime), N'Patent', 5013, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6976, CAST(N'2021-04-22T16:28:51.680' AS DateTime), N'Author', 2506, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6977, CAST(N'2021-04-22T16:28:51.680' AS DateTime), N'Author', 2507, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6978, CAST(N'2021-04-22T16:28:51.680' AS DateTime), N'Author', 2508, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6979, CAST(N'2021-04-22T16:28:51.680' AS DateTime), N'Author', 2509, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6980, CAST(N'2021-04-22T16:30:54.833' AS DateTime), N'Patent', 5017, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6981, CAST(N'2021-04-22T16:30:54.870' AS DateTime), N'Patent', 5018, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6982, CAST(N'2021-04-22T16:30:54.883' AS DateTime), N'Patent', 5019, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6983, CAST(N'2021-04-22T16:30:54.890' AS DateTime), N'Patent', 5020, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6984, CAST(N'2021-04-22T16:30:54.907' AS DateTime), N'Author', 2510, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6985, CAST(N'2021-04-22T16:30:54.927' AS DateTime), N'Author', 2511, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6986, CAST(N'2021-04-22T16:30:54.950' AS DateTime), N'Patent', 5021, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6987, CAST(N'2021-04-22T16:30:55.060' AS DateTime), N'Patent', 5022, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6988, CAST(N'2021-04-22T16:30:55.067' AS DateTime), N'Patent', 5022, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6989, CAST(N'2021-04-22T16:30:55.080' AS DateTime), N'Patent', 5023, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6990, CAST(N'2021-04-22T16:30:55.087' AS DateTime), N'Patent', 5024, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6991, CAST(N'2021-04-22T16:30:55.090' AS DateTime), N'Patent', 5025, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6992, CAST(N'2021-04-22T16:30:55.110' AS DateTime), N'Patent', 5017, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6993, CAST(N'2021-04-22T16:30:55.113' AS DateTime), N'Patent', 5017, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6994, CAST(N'2021-04-22T16:30:55.113' AS DateTime), N'Patent', 5018, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6995, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5019, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6996, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5020, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6997, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5021, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6998, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5023, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (6999, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5024, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7000, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5025, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7001, CAST(N'2021-04-22T16:30:55.117' AS DateTime), N'Patent', 5017, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7002, CAST(N'2021-04-22T16:30:55.127' AS DateTime), N'Author', 2510, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7003, CAST(N'2021-04-22T16:30:55.127' AS DateTime), N'Author', 2511, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7004, CAST(N'2021-04-22T16:32:01.270' AS DateTime), N'Author', 2512, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7005, CAST(N'2021-04-22T16:32:01.340' AS DateTime), N'Author', 2513, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7006, CAST(N'2021-04-22T16:32:01.343' AS DateTime), N'Author', 2514, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7007, CAST(N'2021-04-22T16:32:01.343' AS DateTime), N'Author', 2515, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7008, CAST(N'2021-04-22T16:32:01.347' AS DateTime), N'Author', 2516, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7009, CAST(N'2021-04-22T16:32:01.357' AS DateTime), N'Author', 2517, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7010, CAST(N'2021-04-22T16:32:01.373' AS DateTime), N'Patent', 5026, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7011, CAST(N'2021-04-22T16:32:01.477' AS DateTime), N'Author', 2518, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7012, CAST(N'2021-04-22T16:32:01.483' AS DateTime), N'Author', 2518, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7013, CAST(N'2021-04-22T16:32:01.483' AS DateTime), N'Author', 2519, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7014, CAST(N'2021-04-22T16:32:01.487' AS DateTime), N'Author', 2520, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7015, CAST(N'2021-04-22T16:32:01.490' AS DateTime), N'Author', 2521, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7016, CAST(N'2021-04-22T16:32:01.490' AS DateTime), N'Author', 2522, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7017, CAST(N'2021-04-22T16:32:01.503' AS DateTime), N'Author', 2523, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7018, CAST(N'2021-04-22T16:32:01.507' AS DateTime), N'Author', 2523, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7019, CAST(N'2021-04-22T16:32:01.510' AS DateTime), N'Patent', 5026, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7020, CAST(N'2021-04-22T16:32:01.513' AS DateTime), N'Author', 2512, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7021, CAST(N'2021-04-22T16:32:01.513' AS DateTime), N'Author', 2513, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7022, CAST(N'2021-04-22T16:32:01.513' AS DateTime), N'Author', 2514, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7023, CAST(N'2021-04-22T16:32:01.513' AS DateTime), N'Author', 2515, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7024, CAST(N'2021-04-22T16:32:01.517' AS DateTime), N'Author', 2516, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7025, CAST(N'2021-04-22T16:32:01.517' AS DateTime), N'Author', 2517, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7026, CAST(N'2021-04-22T16:32:01.517' AS DateTime), N'Author', 2519, N'Remove', N'Admin')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7027, CAST(N'2021-04-22T16:32:01.517' AS DateTime), N'Author', 2520, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7028, CAST(N'2021-04-22T16:32:01.520' AS DateTime), N'Author', 2521, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7029, CAST(N'2021-04-22T16:32:01.527' AS DateTime), N'Author', 2522, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7030, CAST(N'2021-04-22T16:32:01.527' AS DateTime), N'Author', 2523, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7031, CAST(N'2021-04-22T16:32:01.543' AS DateTime), N'Book', 5027, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7032, CAST(N'2021-04-22T16:32:01.557' AS DateTime), N'Book', 5028, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7033, CAST(N'2021-04-22T16:32:01.560' AS DateTime), N'Book', 5029, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7034, CAST(N'2021-04-22T16:32:01.563' AS DateTime), N'Book', 5030, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7035, CAST(N'2021-04-22T16:32:01.570' AS DateTime), N'Book', 5031, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7036, CAST(N'2021-04-22T16:32:01.573' AS DateTime), N'Book', 5032, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7037, CAST(N'2021-04-22T16:32:01.573' AS DateTime), N'Book', 5033, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7038, CAST(N'2021-04-22T16:32:01.577' AS DateTime), N'Book', 5034, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7039, CAST(N'2021-04-22T16:32:01.587' AS DateTime), N'Author', 2524, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7040, CAST(N'2021-04-22T16:32:01.600' AS DateTime), N'Author', 2525, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7041, CAST(N'2021-04-22T16:32:01.603' AS DateTime), N'Book', 5035, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7042, CAST(N'2021-04-22T16:32:01.623' AS DateTime), N'Book', 5036, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7043, CAST(N'2021-04-22T16:32:01.627' AS DateTime), N'Book', 5036, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7044, CAST(N'2021-04-22T16:32:01.630' AS DateTime), N'Book', 5037, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7045, CAST(N'2021-04-22T16:32:01.630' AS DateTime), N'Book', 5038, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7046, CAST(N'2021-04-22T16:32:01.633' AS DateTime), N'Book', 5039, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7047, CAST(N'2021-04-22T16:32:01.640' AS DateTime), N'Book', 5040, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7048, CAST(N'2021-04-22T16:32:01.657' AS DateTime), N'Book', 5027, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7049, CAST(N'2021-04-22T16:32:01.660' AS DateTime), N'Book', 5027, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7050, CAST(N'2021-04-22T16:32:01.660' AS DateTime), N'Book', 5028, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7051, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5029, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7052, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5030, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7053, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5031, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7054, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5032, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7055, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5033, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7056, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5034, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7057, CAST(N'2021-04-22T16:32:01.663' AS DateTime), N'Book', 5035, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7058, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Book', 5037, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7059, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Book', 5038, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7060, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Book', 5039, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7061, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Book', 5040, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7062, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Book', 5027, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7063, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Author', 2524, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7064, CAST(N'2021-04-22T16:32:01.667' AS DateTime), N'Author', 2525, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7065, CAST(N'2021-04-22T16:32:01.670' AS DateTime), N'Book', 5041, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7066, CAST(N'2021-04-22T16:32:01.673' AS DateTime), N'Author', 2526, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7067, CAST(N'2021-04-22T16:32:01.680' AS DateTime), N'Author', 2527, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7068, CAST(N'2021-04-22T16:32:01.683' AS DateTime), N'Book', 5042, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7069, CAST(N'2021-04-22T16:32:01.693' AS DateTime), N'Author', 2528, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7070, CAST(N'2021-04-22T16:32:01.703' AS DateTime), N'Patent', 5043, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7071, CAST(N'2021-04-22T16:32:01.717' AS DateTime), N'Author', 2529, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7072, CAST(N'2021-04-22T16:32:01.717' AS DateTime), N'Book', 5044, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7073, CAST(N'2021-04-22T16:32:01.727' AS DateTime), N'Patent', 5045, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7074, CAST(N'2021-04-22T16:32:01.733' AS DateTime), N'Book', 5046, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7075, CAST(N'2021-04-22T16:32:01.740' AS DateTime), N'Book', 5047, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7076, CAST(N'2021-04-22T16:32:01.747' AS DateTime), N'Book', 5048, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7077, CAST(N'2021-04-22T16:32:01.753' AS DateTime), N'Book', 5041, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7078, CAST(N'2021-04-22T16:32:01.753' AS DateTime), N'Book', 5042, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7079, CAST(N'2021-04-22T16:32:01.753' AS DateTime), N'Book', 5044, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7080, CAST(N'2021-04-22T16:32:01.753' AS DateTime), N'Book', 5046, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7081, CAST(N'2021-04-22T16:32:01.753' AS DateTime), N'Book', 5047, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7082, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Book', 5048, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7083, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Patent', 5043, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7084, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Patent', 5045, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7085, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Author', 2526, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7086, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Author', 2527, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7087, CAST(N'2021-04-22T16:32:01.757' AS DateTime), N'Author', 2528, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7088, CAST(N'2021-04-22T16:32:01.760' AS DateTime), N'Author', 2529, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7089, CAST(N'2021-04-22T16:32:01.767' AS DateTime), N'Newspaper', 1040, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7090, CAST(N'2021-04-22T16:32:01.773' AS DateTime), N'Newspaper', 1041, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7091, CAST(N'2021-04-22T16:32:01.777' AS DateTime), N'Newspaper', 1042, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7092, CAST(N'2021-04-22T16:32:01.780' AS DateTime), N'Newspaper', 1042, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7093, CAST(N'2021-04-22T16:32:01.780' AS DateTime), N'Newspaper', 1043, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7094, CAST(N'2021-04-22T16:32:01.780' AS DateTime), N'Newspaper', 1044, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7095, CAST(N'2021-04-22T16:32:01.783' AS DateTime), N'Newspaper', 1045, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7096, CAST(N'2021-04-22T16:32:01.793' AS DateTime), N'Newspaper', 1040, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7097, CAST(N'2021-04-22T16:32:01.793' AS DateTime), N'Newspaper', 1040, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7098, CAST(N'2021-04-22T16:32:01.793' AS DateTime), N'Newspaper', 1041, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7099, CAST(N'2021-04-22T16:32:01.797' AS DateTime), N'Newspaper', 1043, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7100, CAST(N'2021-04-22T16:32:01.797' AS DateTime), N'Newspaper', 1044, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7101, CAST(N'2021-04-22T16:32:01.797' AS DateTime), N'Newspaper', 1045, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7102, CAST(N'2021-04-22T16:32:01.797' AS DateTime), N'Newspaper', 1040, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7103, CAST(N'2021-04-22T16:32:01.810' AS DateTime), N'Patent', 5049, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7104, CAST(N'2021-04-22T16:32:01.813' AS DateTime), N'Patent', 5050, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7105, CAST(N'2021-04-22T16:32:01.820' AS DateTime), N'Patent', 5051, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7106, CAST(N'2021-04-22T16:32:01.823' AS DateTime), N'Patent', 5052, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7107, CAST(N'2021-04-22T16:32:01.830' AS DateTime), N'Author', 2530, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7108, CAST(N'2021-04-22T16:32:01.843' AS DateTime), N'Author', 2531, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7109, CAST(N'2021-04-22T16:32:01.847' AS DateTime), N'Patent', 5053, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7110, CAST(N'2021-04-22T16:32:01.860' AS DateTime), N'Patent', 5054, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7111, CAST(N'2021-04-22T16:32:01.863' AS DateTime), N'Patent', 5054, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7112, CAST(N'2021-04-22T16:32:01.867' AS DateTime), N'Patent', 5055, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7113, CAST(N'2021-04-22T16:32:01.870' AS DateTime), N'Patent', 5056, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7114, CAST(N'2021-04-22T16:32:01.873' AS DateTime), N'Patent', 5057, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7115, CAST(N'2021-04-22T16:32:01.893' AS DateTime), N'Patent', 5049, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7116, CAST(N'2021-04-22T16:32:01.897' AS DateTime), N'Patent', 5049, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7117, CAST(N'2021-04-22T16:32:01.897' AS DateTime), N'Patent', 5050, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7118, CAST(N'2021-04-22T16:32:01.897' AS DateTime), N'Patent', 5051, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7119, CAST(N'2021-04-22T16:32:01.897' AS DateTime), N'Patent', 5052, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7120, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Patent', 5053, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7121, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Patent', 5055, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7122, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Patent', 5056, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7123, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Patent', 5057, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7124, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Patent', 5049, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7125, CAST(N'2021-04-22T16:32:01.900' AS DateTime), N'Author', 2530, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7126, CAST(N'2021-04-22T16:32:01.903' AS DateTime), N'Author', 2531, N'Remove', N'Admin')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7127, CAST(N'2021-04-22T17:29:33.990' AS DateTime), N'Newspaper', 1046, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7128, CAST(N'2021-04-22T17:29:34.173' AS DateTime), N'NewspaperIssue', 5058, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7129, CAST(N'2021-04-22T17:29:34.187' AS DateTime), N'NewspaperIssue', 5059, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7130, CAST(N'2021-04-22T17:29:34.210' AS DateTime), N'NewspaperIssue', 5060, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7131, CAST(N'2021-04-22T17:29:34.220' AS DateTime), N'NewspaperIssue', 5061, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7132, CAST(N'2021-04-22T17:29:34.253' AS DateTime), N'NewspaperIssue', 5062, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7133, CAST(N'2021-04-22T17:29:34.263' AS DateTime), N'NewspaperIssue', 5062, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7134, CAST(N'2021-04-22T17:29:34.307' AS DateTime), N'NewspaperIssues', 5058, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7135, CAST(N'2021-04-22T17:29:34.310' AS DateTime), N'NewspaperIssue', 5058, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7136, CAST(N'2021-04-22T17:29:34.310' AS DateTime), N'NewspaperIssue', 5059, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7137, CAST(N'2021-04-22T17:29:34.310' AS DateTime), N'NewspaperIssue', 5060, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7138, CAST(N'2021-04-22T17:29:34.313' AS DateTime), N'NewspaperIssue', 5061, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7139, CAST(N'2021-04-22T17:29:34.313' AS DateTime), N'NewspaperIssue', 5058, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7140, CAST(N'2021-04-22T17:29:34.317' AS DateTime), N'Newspaper', 1046, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7141, CAST(N'2021-04-22T17:30:38.010' AS DateTime), N'Newspaper', 1047, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7142, CAST(N'2021-04-22T17:30:38.153' AS DateTime), N'Newspaper', 1047, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7143, CAST(N'2021-04-22T17:30:52.953' AS DateTime), N'Newspaper', 1048, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7144, CAST(N'2021-04-22T17:30:53.160' AS DateTime), N'Newspaper', 1048, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7145, CAST(N'2021-04-22T17:32:00.300' AS DateTime), N'Newspaper', 1049, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7146, CAST(N'2021-04-22T17:35:46.580' AS DateTime), N'NewspaperIssue', 5063, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7147, CAST(N'2021-04-22T17:35:46.630' AS DateTime), N'NewspaperIssue', 5063, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7148, CAST(N'2021-04-22T17:35:46.630' AS DateTime), N'Newspaper', 1049, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7149, CAST(N'2021-04-22T17:35:53.790' AS DateTime), N'Newspaper', 1050, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7150, CAST(N'2021-04-22T17:35:53.900' AS DateTime), N'NewspaperIssue', 5064, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7151, CAST(N'2021-04-22T17:35:53.977' AS DateTime), N'NewspaperIssue', 5064, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7152, CAST(N'2021-04-22T17:35:53.980' AS DateTime), N'Newspaper', 1050, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7153, CAST(N'2021-04-22T17:36:55.287' AS DateTime), N'Newspaper', 1051, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7154, CAST(N'2021-04-22T17:36:55.453' AS DateTime), N'Newspaper', 1051, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7155, CAST(N'2021-04-22T17:37:03.323' AS DateTime), N'Newspaper', 1052, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7156, CAST(N'2021-04-22T17:37:03.510' AS DateTime), N'Newspaper', 1052, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7157, CAST(N'2021-04-22T17:40:21.057' AS DateTime), N'Newspaper', 1053, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7158, CAST(N'2021-04-22T17:40:21.173' AS DateTime), N'Newspaper', 1053, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7159, CAST(N'2021-04-22T17:40:26.187' AS DateTime), N'Newspaper', 1054, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7160, CAST(N'2021-04-22T17:40:26.280' AS DateTime), N'NewspaperIssue', 5065, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7161, CAST(N'2021-04-22T17:40:26.337' AS DateTime), N'NewspaperIssue', 5066, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7162, CAST(N'2021-04-22T17:40:26.347' AS DateTime), N'NewspaperIssue', 5065, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7163, CAST(N'2021-04-22T17:40:26.347' AS DateTime), N'NewspaperIssue', 5066, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7164, CAST(N'2021-04-22T17:40:26.350' AS DateTime), N'Newspaper', 1054, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7165, CAST(N'2021-04-22T17:40:30.463' AS DateTime), N'Newspaper', 1055, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7166, CAST(N'2021-04-22T17:40:30.570' AS DateTime), N'NewspaperIssue', 5067, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7167, CAST(N'2021-04-22T17:40:30.633' AS DateTime), N'NewspaperIssue', 5068, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7168, CAST(N'2021-04-22T17:40:30.647' AS DateTime), N'NewspaperIssue', 5069, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7169, CAST(N'2021-04-22T17:40:30.690' AS DateTime), N'NewspaperIssue', 5067, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7170, CAST(N'2021-04-22T17:40:30.690' AS DateTime), N'NewspaperIssue', 5068, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7171, CAST(N'2021-04-22T17:40:30.690' AS DateTime), N'NewspaperIssue', 5069, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7172, CAST(N'2021-04-22T17:40:30.690' AS DateTime), N'Newspaper', 1055, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7173, CAST(N'2021-04-22T17:42:44.427' AS DateTime), N'Newspaper', 1056, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7174, CAST(N'2021-04-22T17:42:44.523' AS DateTime), N'NewspaperIssue', 5070, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7175, CAST(N'2021-04-22T17:42:44.597' AS DateTime), N'NewspaperIssue', 5071, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7176, CAST(N'2021-04-22T17:42:44.610' AS DateTime), N'NewspaperIssue', 5072, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7177, CAST(N'2021-04-22T17:42:44.627' AS DateTime), N'NewspaperIssue', 5070, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7178, CAST(N'2021-04-22T17:42:44.630' AS DateTime), N'NewspaperIssue', 5071, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7179, CAST(N'2021-04-22T17:42:44.630' AS DateTime), N'NewspaperIssue', 5072, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7180, CAST(N'2021-04-22T17:42:44.630' AS DateTime), N'Newspaper', 1056, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7181, CAST(N'2021-04-22T17:42:50.520' AS DateTime), N'Newspaper', 1057, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7182, CAST(N'2021-04-22T17:42:50.623' AS DateTime), N'NewspaperIssue', 5073, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7183, CAST(N'2021-04-22T17:42:50.663' AS DateTime), N'NewspaperIssue', 5074, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7184, CAST(N'2021-04-22T17:42:50.667' AS DateTime), N'NewspaperIssue', 5075, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7185, CAST(N'2021-04-22T17:42:50.677' AS DateTime), N'NewspaperIssue', 5073, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7186, CAST(N'2021-04-22T17:42:50.680' AS DateTime), N'NewspaperIssue', 5074, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7187, CAST(N'2021-04-22T17:42:50.680' AS DateTime), N'NewspaperIssue', 5075, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7188, CAST(N'2021-04-22T17:42:50.680' AS DateTime), N'Newspaper', 1057, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7189, CAST(N'2021-04-22T17:42:55.860' AS DateTime), N'Newspaper', 1058, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7190, CAST(N'2021-04-22T17:42:56.010' AS DateTime), N'NewspaperIssue', 5076, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7191, CAST(N'2021-04-22T17:42:56.013' AS DateTime), N'NewspaperIssue', 5077, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7192, CAST(N'2021-04-22T17:42:56.027' AS DateTime), N'NewspaperIssue', 5078, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7193, CAST(N'2021-04-22T17:42:56.027' AS DateTime), N'NewspaperIssue', 5079, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7194, CAST(N'2021-04-22T17:42:56.040' AS DateTime), N'NewspaperIssue', 5080, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7195, CAST(N'2021-04-22T17:42:56.043' AS DateTime), N'NewspaperIssue', 5080, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7196, CAST(N'2021-04-22T17:42:56.043' AS DateTime), N'NewspaperIssue', 5081, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7197, CAST(N'2021-04-22T17:42:56.047' AS DateTime), N'NewspaperIssue', 5082, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7198, CAST(N'2021-04-22T17:42:56.050' AS DateTime), N'NewspaperIssue', 5083, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7199, CAST(N'2021-04-22T17:42:56.063' AS DateTime), N'NewspaperIssues', 5076, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7200, CAST(N'2021-04-22T17:42:56.067' AS DateTime), N'NewspaperIssue', 5076, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7201, CAST(N'2021-04-22T17:42:56.067' AS DateTime), N'NewspaperIssue', 5077, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7202, CAST(N'2021-04-22T17:42:56.067' AS DateTime), N'NewspaperIssue', 5078, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7203, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'NewspaperIssue', 5079, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7204, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'NewspaperIssue', 5081, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7205, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'NewspaperIssue', 5082, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7206, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'NewspaperIssue', 5083, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7207, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'NewspaperIssue', 5076, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7208, CAST(N'2021-04-22T17:42:56.070' AS DateTime), N'Newspaper', 1058, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7209, CAST(N'2021-04-22T17:44:23.617' AS DateTime), N'Newspaper', 1059, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7210, CAST(N'2021-04-22T17:46:17.843' AS DateTime), N'Newspaper', 1059, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7211, CAST(N'2021-04-22T17:46:25.470' AS DateTime), N'Newspaper', 1060, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7212, CAST(N'2021-04-22T17:46:25.603' AS DateTime), N'NewspaperIssue', 5084, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7213, CAST(N'2021-04-22T17:46:25.610' AS DateTime), N'NewspaperIssue', 5085, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7214, CAST(N'2021-04-22T17:46:25.620' AS DateTime), N'NewspaperIssue', 5086, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7215, CAST(N'2021-04-22T17:46:25.623' AS DateTime), N'NewspaperIssue', 5087, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7216, CAST(N'2021-04-22T17:46:25.633' AS DateTime), N'NewspaperIssue', 5088, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7217, CAST(N'2021-04-22T17:46:25.640' AS DateTime), N'NewspaperIssue', 5088, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7218, CAST(N'2021-04-22T17:46:25.643' AS DateTime), N'NewspaperIssue', 5089, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7219, CAST(N'2021-04-22T17:46:25.647' AS DateTime), N'NewspaperIssue', 5090, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7220, CAST(N'2021-04-22T17:46:25.653' AS DateTime), N'NewspaperIssue', 5091, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7221, CAST(N'2021-04-22T17:46:25.670' AS DateTime), N'NewspaperIssues', 5084, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7222, CAST(N'2021-04-22T17:46:25.673' AS DateTime), N'NewspaperIssue', 5084, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7223, CAST(N'2021-04-22T17:46:25.673' AS DateTime), N'NewspaperIssue', 5085, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7224, CAST(N'2021-04-22T17:46:25.673' AS DateTime), N'NewspaperIssue', 5086, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7225, CAST(N'2021-04-22T17:46:25.673' AS DateTime), N'NewspaperIssue', 5087, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7226, CAST(N'2021-04-22T17:46:25.673' AS DateTime), N'NewspaperIssue', 5089, N'Remove', N'Admin')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7227, CAST(N'2021-04-22T17:46:25.677' AS DateTime), N'NewspaperIssue', 5090, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7228, CAST(N'2021-04-22T17:46:25.677' AS DateTime), N'NewspaperIssue', 5091, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7229, CAST(N'2021-04-22T17:46:25.677' AS DateTime), N'NewspaperIssue', 5084, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7230, CAST(N'2021-04-22T17:46:25.677' AS DateTime), N'Newspaper', 1060, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7231, CAST(N'2021-04-22T17:46:33.057' AS DateTime), N'Newspaper', 1061, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7232, CAST(N'2021-04-22T17:46:33.197' AS DateTime), N'NewspaperIssue', 5092, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7233, CAST(N'2021-04-22T17:46:33.200' AS DateTime), N'NewspaperIssue', 5093, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7234, CAST(N'2021-04-22T17:46:33.210' AS DateTime), N'NewspaperIssue', 5094, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7235, CAST(N'2021-04-22T17:46:33.210' AS DateTime), N'NewspaperIssue', 5095, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7236, CAST(N'2021-04-22T17:46:33.220' AS DateTime), N'NewspaperIssue', 5096, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7237, CAST(N'2021-04-22T17:46:33.223' AS DateTime), N'NewspaperIssue', 5096, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7238, CAST(N'2021-04-22T17:46:33.223' AS DateTime), N'NewspaperIssue', 5097, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7239, CAST(N'2021-04-22T17:46:33.227' AS DateTime), N'NewspaperIssue', 5098, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7240, CAST(N'2021-04-22T17:46:33.233' AS DateTime), N'NewspaperIssue', 5099, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7241, CAST(N'2021-04-22T17:46:33.240' AS DateTime), N'NewspaperIssues', 5092, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7242, CAST(N'2021-04-22T17:46:33.243' AS DateTime), N'NewspaperIssue', 5092, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7243, CAST(N'2021-04-22T17:46:33.243' AS DateTime), N'NewspaperIssue', 5093, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7244, CAST(N'2021-04-22T17:46:33.243' AS DateTime), N'NewspaperIssue', 5094, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7245, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'NewspaperIssue', 5095, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7246, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'NewspaperIssue', 5097, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7247, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'NewspaperIssue', 5098, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7248, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'NewspaperIssue', 5099, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7249, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'NewspaperIssue', 5092, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7250, CAST(N'2021-04-22T17:46:33.247' AS DateTime), N'Newspaper', 1061, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7251, CAST(N'2021-04-22T18:18:53.653' AS DateTime), N'Newspaper', 1062, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7252, CAST(N'2021-04-22T18:18:53.743' AS DateTime), N'NewspaperIssue', 5100, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7253, CAST(N'2021-04-22T18:18:53.780' AS DateTime), N'NewspaperIssue', 5100, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7254, CAST(N'2021-04-22T18:18:53.783' AS DateTime), N'Newspaper', 1062, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7255, CAST(N'2021-04-22T18:24:51.323' AS DateTime), N'Newspaper', 1063, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7256, CAST(N'2021-04-22T18:24:51.363' AS DateTime), N'Newspaper', 1064, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7257, CAST(N'2021-04-22T18:24:51.413' AS DateTime), N'NewspaperIssue', 5101, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7258, CAST(N'2021-04-22T18:24:51.453' AS DateTime), N'NewspaperIssue', 5101, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7259, CAST(N'2021-04-22T18:24:51.457' AS DateTime), N'Newspaper', 1063, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7260, CAST(N'2021-04-22T18:24:51.457' AS DateTime), N'Newspaper', 1064, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7261, CAST(N'2021-04-22T18:24:51.460' AS DateTime), N'Newspaper', 1064, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7262, CAST(N'2021-04-22T18:25:00.980' AS DateTime), N'Newspaper', 1065, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7263, CAST(N'2021-04-22T18:25:01.117' AS DateTime), N'NewspaperIssue', 5102, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7264, CAST(N'2021-04-22T18:25:01.123' AS DateTime), N'NewspaperIssue', 5103, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7265, CAST(N'2021-04-22T18:25:01.133' AS DateTime), N'NewspaperIssue', 5104, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7266, CAST(N'2021-04-22T18:25:01.137' AS DateTime), N'NewspaperIssue', 5105, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7267, CAST(N'2021-04-22T18:25:01.140' AS DateTime), N'NewspaperIssue', 5106, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7268, CAST(N'2021-04-22T18:25:01.150' AS DateTime), N'Newspaper', 1066, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7269, CAST(N'2021-04-22T18:25:01.150' AS DateTime), N'NewspaperIssue', 5107, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7270, CAST(N'2021-04-22T18:25:01.153' AS DateTime), N'NewspaperIssue', 5108, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7271, CAST(N'2021-04-22T18:25:01.163' AS DateTime), N'NewspaperIssue', 5108, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7272, CAST(N'2021-04-22T18:25:01.163' AS DateTime), N'NewspaperIssue', 5109, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7273, CAST(N'2021-04-22T18:25:01.167' AS DateTime), N'NewspaperIssue', 5110, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7274, CAST(N'2021-04-22T18:25:01.167' AS DateTime), N'NewspaperIssue', 5111, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7275, CAST(N'2021-04-22T18:25:01.183' AS DateTime), N'NewspaperIssues', 5102, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7276, CAST(N'2021-04-22T18:25:01.183' AS DateTime), N'NewspaperIssue', 5102, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7277, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5103, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7278, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5104, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7279, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5105, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7280, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5106, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7281, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5107, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7282, CAST(N'2021-04-22T18:25:01.187' AS DateTime), N'NewspaperIssue', 5109, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7283, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'NewspaperIssue', 5110, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7284, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'NewspaperIssue', 5111, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7285, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'NewspaperIssue', 5102, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7286, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'Newspaper', 1065, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7287, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'Newspaper', 1066, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7288, CAST(N'2021-04-22T18:25:01.190' AS DateTime), N'Newspaper', 1066, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7289, CAST(N'2021-04-22T18:25:17.677' AS DateTime), N'Author', 2532, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7290, CAST(N'2021-04-22T18:25:17.747' AS DateTime), N'Author', 2533, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7291, CAST(N'2021-04-22T18:25:17.750' AS DateTime), N'Author', 2534, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7292, CAST(N'2021-04-22T18:25:17.750' AS DateTime), N'Author', 2535, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7293, CAST(N'2021-04-22T18:25:17.753' AS DateTime), N'Author', 2536, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7294, CAST(N'2021-04-22T18:25:17.763' AS DateTime), N'Author', 2537, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7295, CAST(N'2021-04-22T18:25:17.780' AS DateTime), N'Patent', 5112, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7296, CAST(N'2021-04-22T18:25:17.883' AS DateTime), N'Author', 2538, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7297, CAST(N'2021-04-22T18:25:17.890' AS DateTime), N'Author', 2538, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7298, CAST(N'2021-04-22T18:25:17.890' AS DateTime), N'Author', 2539, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7299, CAST(N'2021-04-22T18:25:17.893' AS DateTime), N'Author', 2540, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7300, CAST(N'2021-04-22T18:25:17.893' AS DateTime), N'Author', 2541, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7301, CAST(N'2021-04-22T18:25:17.897' AS DateTime), N'Author', 2542, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7302, CAST(N'2021-04-22T18:25:17.907' AS DateTime), N'Author', 2543, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7303, CAST(N'2021-04-22T18:25:17.910' AS DateTime), N'Author', 2543, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7304, CAST(N'2021-04-22T18:25:17.913' AS DateTime), N'Patent', 5112, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7305, CAST(N'2021-04-22T18:25:17.913' AS DateTime), N'Author', 2532, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7306, CAST(N'2021-04-22T18:25:17.913' AS DateTime), N'Author', 2533, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7307, CAST(N'2021-04-22T18:25:17.917' AS DateTime), N'Author', 2534, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7308, CAST(N'2021-04-22T18:25:17.917' AS DateTime), N'Author', 2535, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7309, CAST(N'2021-04-22T18:25:17.917' AS DateTime), N'Author', 2536, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7310, CAST(N'2021-04-22T18:25:17.917' AS DateTime), N'Author', 2537, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7311, CAST(N'2021-04-22T18:25:17.920' AS DateTime), N'Author', 2539, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7312, CAST(N'2021-04-22T18:25:17.920' AS DateTime), N'Author', 2540, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7313, CAST(N'2021-04-22T18:25:17.920' AS DateTime), N'Author', 2541, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7314, CAST(N'2021-04-22T18:25:17.920' AS DateTime), N'Author', 2542, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7315, CAST(N'2021-04-22T18:25:17.920' AS DateTime), N'Author', 2543, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7316, CAST(N'2021-04-22T18:25:17.943' AS DateTime), N'Book', 5113, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7317, CAST(N'2021-04-22T18:25:17.957' AS DateTime), N'Book', 5114, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7318, CAST(N'2021-04-22T18:25:17.960' AS DateTime), N'Book', 5115, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7319, CAST(N'2021-04-22T18:25:17.960' AS DateTime), N'Book', 5116, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7320, CAST(N'2021-04-22T18:25:17.970' AS DateTime), N'Book', 5117, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7321, CAST(N'2021-04-22T18:25:17.973' AS DateTime), N'Book', 5118, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7322, CAST(N'2021-04-22T18:25:17.980' AS DateTime), N'Book', 5119, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7323, CAST(N'2021-04-22T18:25:17.980' AS DateTime), N'Book', 5120, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7324, CAST(N'2021-04-22T18:25:17.993' AS DateTime), N'Author', 2544, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7325, CAST(N'2021-04-22T18:25:18.003' AS DateTime), N'Author', 2545, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7326, CAST(N'2021-04-22T18:25:18.007' AS DateTime), N'Book', 5121, N'Add', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7327, CAST(N'2021-04-22T18:25:18.027' AS DateTime), N'Book', 5122, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7328, CAST(N'2021-04-22T18:25:18.030' AS DateTime), N'Book', 5122, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7329, CAST(N'2021-04-22T18:25:18.030' AS DateTime), N'Book', 5123, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7330, CAST(N'2021-04-22T18:25:18.033' AS DateTime), N'Book', 5124, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7331, CAST(N'2021-04-22T18:25:18.037' AS DateTime), N'Book', 5125, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7332, CAST(N'2021-04-22T18:25:18.043' AS DateTime), N'Book', 5126, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7333, CAST(N'2021-04-22T18:25:18.060' AS DateTime), N'Book', 5113, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7334, CAST(N'2021-04-22T18:25:18.060' AS DateTime), N'Book', 5113, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7335, CAST(N'2021-04-22T18:25:18.063' AS DateTime), N'Book', 5114, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7336, CAST(N'2021-04-22T18:25:18.063' AS DateTime), N'Book', 5115, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7337, CAST(N'2021-04-22T18:25:18.063' AS DateTime), N'Book', 5116, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7338, CAST(N'2021-04-22T18:25:18.063' AS DateTime), N'Book', 5117, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7339, CAST(N'2021-04-22T18:25:18.063' AS DateTime), N'Book', 5118, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7340, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5119, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7341, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5120, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7342, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5121, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7343, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5123, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7344, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5124, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7345, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5125, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7346, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5126, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7347, CAST(N'2021-04-22T18:25:18.067' AS DateTime), N'Book', 5113, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7348, CAST(N'2021-04-22T18:25:18.070' AS DateTime), N'Author', 2544, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7349, CAST(N'2021-04-22T18:25:18.070' AS DateTime), N'Author', 2545, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7350, CAST(N'2021-04-22T18:25:18.070' AS DateTime), N'Book', 5127, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7351, CAST(N'2021-04-22T18:25:18.077' AS DateTime), N'Author', 2546, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7352, CAST(N'2021-04-22T18:25:18.083' AS DateTime), N'Author', 2547, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7353, CAST(N'2021-04-22T18:25:18.087' AS DateTime), N'Book', 5128, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7354, CAST(N'2021-04-22T18:25:18.097' AS DateTime), N'Author', 2548, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7355, CAST(N'2021-04-22T18:25:18.107' AS DateTime), N'Patent', 5129, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7356, CAST(N'2021-04-22T18:25:18.120' AS DateTime), N'Author', 2549, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7357, CAST(N'2021-04-22T18:25:18.120' AS DateTime), N'Book', 5130, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7358, CAST(N'2021-04-22T18:25:18.130' AS DateTime), N'Patent', 5131, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7359, CAST(N'2021-04-22T18:25:18.137' AS DateTime), N'Book', 5132, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7360, CAST(N'2021-04-22T18:25:18.143' AS DateTime), N'Book', 5133, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7361, CAST(N'2021-04-22T18:25:18.147' AS DateTime), N'Book', 5134, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7362, CAST(N'2021-04-22T18:25:18.153' AS DateTime), N'Book', 5127, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7363, CAST(N'2021-04-22T18:25:18.153' AS DateTime), N'Book', 5128, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7364, CAST(N'2021-04-22T18:25:18.153' AS DateTime), N'Book', 5130, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7365, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Book', 5132, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7366, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Book', 5133, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7367, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Book', 5134, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7368, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Patent', 5129, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7369, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Patent', 5131, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7370, CAST(N'2021-04-22T18:25:18.157' AS DateTime), N'Author', 2546, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7371, CAST(N'2021-04-22T18:25:18.160' AS DateTime), N'Author', 2547, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7372, CAST(N'2021-04-22T18:25:18.160' AS DateTime), N'Author', 2548, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7373, CAST(N'2021-04-22T18:25:18.160' AS DateTime), N'Author', 2549, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7374, CAST(N'2021-04-22T18:25:18.170' AS DateTime), N'Newspaper', 1067, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7375, CAST(N'2021-04-22T18:25:18.173' AS DateTime), N'Newspaper', 1068, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7376, CAST(N'2021-04-22T18:25:18.180' AS DateTime), N'Newspaper', 1069, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7377, CAST(N'2021-04-22T18:25:18.180' AS DateTime), N'Newspaper', 1069, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7378, CAST(N'2021-04-22T18:25:18.180' AS DateTime), N'Newspaper', 1070, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7379, CAST(N'2021-04-22T18:25:18.183' AS DateTime), N'Newspaper', 1071, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7380, CAST(N'2021-04-22T18:25:18.183' AS DateTime), N'Newspaper', 1072, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7381, CAST(N'2021-04-22T18:25:18.193' AS DateTime), N'Newspaper', 1067, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7382, CAST(N'2021-04-22T18:25:18.197' AS DateTime), N'Newspaper', 1067, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7383, CAST(N'2021-04-22T18:25:18.197' AS DateTime), N'Newspaper', 1068, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7384, CAST(N'2021-04-22T18:25:18.197' AS DateTime), N'Newspaper', 1070, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7385, CAST(N'2021-04-22T18:25:18.200' AS DateTime), N'Newspaper', 1071, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7386, CAST(N'2021-04-22T18:25:18.200' AS DateTime), N'Newspaper', 1072, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7387, CAST(N'2021-04-22T18:25:18.200' AS DateTime), N'Newspaper', 1067, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7388, CAST(N'2021-04-22T18:25:18.200' AS DateTime), N'Newspaper', 1073, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7389, CAST(N'2021-04-22T18:25:18.213' AS DateTime), N'NewspaperIssue', 5135, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7390, CAST(N'2021-04-22T18:25:18.220' AS DateTime), N'NewspaperIssue', 5136, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7391, CAST(N'2021-04-22T18:25:18.227' AS DateTime), N'NewspaperIssue', 5137, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7392, CAST(N'2021-04-22T18:25:18.233' AS DateTime), N'NewspaperIssue', 5138, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7393, CAST(N'2021-04-22T18:25:18.233' AS DateTime), N'NewspaperIssue', 5139, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7394, CAST(N'2021-04-22T18:25:18.240' AS DateTime), N'Newspaper', 1074, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7395, CAST(N'2021-04-22T18:25:18.240' AS DateTime), N'NewspaperIssue', 5140, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7396, CAST(N'2021-04-22T18:25:18.247' AS DateTime), N'NewspaperIssue', 5141, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7397, CAST(N'2021-04-22T18:25:18.250' AS DateTime), N'NewspaperIssue', 5141, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7398, CAST(N'2021-04-22T18:25:18.253' AS DateTime), N'NewspaperIssue', 5142, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7399, CAST(N'2021-04-22T18:25:18.253' AS DateTime), N'NewspaperIssue', 5143, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7400, CAST(N'2021-04-22T18:25:18.257' AS DateTime), N'NewspaperIssue', 5144, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7401, CAST(N'2021-04-22T18:25:18.270' AS DateTime), N'NewspaperIssues', 5135, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7402, CAST(N'2021-04-22T18:25:18.273' AS DateTime), N'NewspaperIssue', 5135, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7403, CAST(N'2021-04-22T18:25:18.273' AS DateTime), N'NewspaperIssue', 5136, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7404, CAST(N'2021-04-22T18:25:18.273' AS DateTime), N'NewspaperIssue', 5137, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7405, CAST(N'2021-04-22T18:25:18.273' AS DateTime), N'NewspaperIssue', 5138, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7406, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5139, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7407, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5140, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7408, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5142, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7409, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5143, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7410, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5144, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7411, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'NewspaperIssue', 5135, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7412, CAST(N'2021-04-22T18:25:18.277' AS DateTime), N'Newspaper', 1073, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7413, CAST(N'2021-04-22T18:25:18.280' AS DateTime), N'Newspaper', 1074, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7414, CAST(N'2021-04-22T18:25:18.280' AS DateTime), N'Newspaper', 1074, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7415, CAST(N'2021-04-22T18:25:18.290' AS DateTime), N'Patent', 5145, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7416, CAST(N'2021-04-22T18:25:18.297' AS DateTime), N'Patent', 5146, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7417, CAST(N'2021-04-22T18:25:18.300' AS DateTime), N'Patent', 5147, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7418, CAST(N'2021-04-22T18:25:18.307' AS DateTime), N'Patent', 5148, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7419, CAST(N'2021-04-22T18:25:18.313' AS DateTime), N'Author', 2550, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7420, CAST(N'2021-04-22T18:25:18.327' AS DateTime), N'Author', 2551, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7421, CAST(N'2021-04-22T18:25:18.330' AS DateTime), N'Patent', 5149, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7422, CAST(N'2021-04-22T18:25:18.347' AS DateTime), N'Patent', 5150, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7423, CAST(N'2021-04-22T18:25:18.350' AS DateTime), N'Patent', 5150, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7424, CAST(N'2021-04-22T18:25:18.350' AS DateTime), N'Patent', 5151, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7425, CAST(N'2021-04-22T18:25:18.357' AS DateTime), N'Patent', 5152, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7426, CAST(N'2021-04-22T18:25:18.360' AS DateTime), N'Patent', 5153, N'Add', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7427, CAST(N'2021-04-22T18:25:18.383' AS DateTime), N'Patent', 5145, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7428, CAST(N'2021-04-22T18:25:18.383' AS DateTime), N'Patent', 5145, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7429, CAST(N'2021-04-22T18:25:18.383' AS DateTime), N'Patent', 5146, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7430, CAST(N'2021-04-22T18:25:18.383' AS DateTime), N'Patent', 5147, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7431, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5148, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7432, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5149, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7433, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5151, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7434, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5152, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7435, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5153, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7436, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Patent', 5145, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7437, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Author', 2550, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7438, CAST(N'2021-04-22T18:25:18.387' AS DateTime), N'Author', 2551, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7439, CAST(N'2021-04-22T18:26:35.470' AS DateTime), N'Author', 2552, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7440, CAST(N'2021-04-22T18:26:35.550' AS DateTime), N'Author', 2553, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7441, CAST(N'2021-04-22T18:26:35.550' AS DateTime), N'Author', 2554, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7442, CAST(N'2021-04-22T18:26:35.553' AS DateTime), N'Author', 2555, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7443, CAST(N'2021-04-22T18:26:35.557' AS DateTime), N'Author', 2556, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7444, CAST(N'2021-04-22T18:26:35.563' AS DateTime), N'Author', 2557, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7445, CAST(N'2021-04-22T18:26:35.580' AS DateTime), N'Patent', 5154, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7446, CAST(N'2021-04-22T18:26:35.683' AS DateTime), N'Author', 2558, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7447, CAST(N'2021-04-22T18:26:35.690' AS DateTime), N'Author', 2558, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7448, CAST(N'2021-04-22T18:26:35.690' AS DateTime), N'Author', 2559, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7449, CAST(N'2021-04-22T18:26:35.693' AS DateTime), N'Author', 2560, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7450, CAST(N'2021-04-22T18:26:35.693' AS DateTime), N'Author', 2561, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7451, CAST(N'2021-04-22T18:26:35.697' AS DateTime), N'Author', 2562, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7452, CAST(N'2021-04-22T18:26:35.707' AS DateTime), N'Author', 2563, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7453, CAST(N'2021-04-22T18:26:35.710' AS DateTime), N'Author', 2563, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7454, CAST(N'2021-04-22T18:26:35.713' AS DateTime), N'Patent', 5154, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7455, CAST(N'2021-04-22T18:26:35.713' AS DateTime), N'Author', 2552, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7456, CAST(N'2021-04-22T18:26:35.713' AS DateTime), N'Author', 2553, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7457, CAST(N'2021-04-22T18:26:35.717' AS DateTime), N'Author', 2554, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7458, CAST(N'2021-04-22T18:26:35.717' AS DateTime), N'Author', 2555, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7459, CAST(N'2021-04-22T18:26:35.717' AS DateTime), N'Author', 2556, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7460, CAST(N'2021-04-22T18:26:35.717' AS DateTime), N'Author', 2557, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7461, CAST(N'2021-04-22T18:26:35.717' AS DateTime), N'Author', 2559, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7462, CAST(N'2021-04-22T18:26:35.720' AS DateTime), N'Author', 2560, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7463, CAST(N'2021-04-22T18:26:35.720' AS DateTime), N'Author', 2561, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7464, CAST(N'2021-04-22T18:26:35.720' AS DateTime), N'Author', 2562, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7465, CAST(N'2021-04-22T18:26:35.720' AS DateTime), N'Author', 2563, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7466, CAST(N'2021-04-22T18:26:35.740' AS DateTime), N'Book', 5155, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7467, CAST(N'2021-04-22T18:26:35.750' AS DateTime), N'Book', 5156, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7468, CAST(N'2021-04-22T18:26:35.757' AS DateTime), N'Book', 5157, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7469, CAST(N'2021-04-22T18:26:35.757' AS DateTime), N'Book', 5158, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7470, CAST(N'2021-04-22T18:26:35.767' AS DateTime), N'Book', 5159, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7471, CAST(N'2021-04-22T18:26:35.767' AS DateTime), N'Book', 5160, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7472, CAST(N'2021-04-22T18:26:35.773' AS DateTime), N'Book', 5161, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7473, CAST(N'2021-04-22T18:26:35.777' AS DateTime), N'Book', 5162, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7474, CAST(N'2021-04-22T18:26:35.787' AS DateTime), N'Author', 2564, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7475, CAST(N'2021-04-22T18:26:35.797' AS DateTime), N'Author', 2565, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7476, CAST(N'2021-04-22T18:26:35.800' AS DateTime), N'Book', 5163, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7477, CAST(N'2021-04-22T18:26:35.820' AS DateTime), N'Book', 5164, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7478, CAST(N'2021-04-22T18:26:35.823' AS DateTime), N'Book', 5164, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7479, CAST(N'2021-04-22T18:26:35.827' AS DateTime), N'Book', 5165, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7480, CAST(N'2021-04-22T18:26:35.830' AS DateTime), N'Book', 5166, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7481, CAST(N'2021-04-22T18:26:35.830' AS DateTime), N'Book', 5167, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7482, CAST(N'2021-04-22T18:26:35.840' AS DateTime), N'Book', 5168, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7483, CAST(N'2021-04-22T18:26:35.853' AS DateTime), N'Book', 5155, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7484, CAST(N'2021-04-22T18:26:35.857' AS DateTime), N'Book', 5155, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7485, CAST(N'2021-04-22T18:26:35.857' AS DateTime), N'Book', 5156, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7486, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5157, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7487, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5158, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7488, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5159, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7489, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5160, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7490, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5161, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7491, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5162, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7492, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5163, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7493, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5165, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7494, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5166, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7495, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5167, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7496, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5168, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7497, CAST(N'2021-04-22T18:26:35.860' AS DateTime), N'Book', 5155, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7498, CAST(N'2021-04-22T18:26:35.863' AS DateTime), N'Author', 2564, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7499, CAST(N'2021-04-22T18:26:35.863' AS DateTime), N'Author', 2565, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7500, CAST(N'2021-04-22T18:26:35.863' AS DateTime), N'Book', 5169, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7501, CAST(N'2021-04-22T18:26:35.870' AS DateTime), N'Author', 2566, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7502, CAST(N'2021-04-22T18:26:35.877' AS DateTime), N'Author', 2567, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7503, CAST(N'2021-04-22T18:26:35.880' AS DateTime), N'Book', 5170, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7504, CAST(N'2021-04-22T18:26:35.890' AS DateTime), N'Author', 2568, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7505, CAST(N'2021-04-22T18:26:35.900' AS DateTime), N'Patent', 5171, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7506, CAST(N'2021-04-22T18:26:35.910' AS DateTime), N'Author', 2569, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7507, CAST(N'2021-04-22T18:26:35.913' AS DateTime), N'Book', 5172, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7508, CAST(N'2021-04-22T18:26:35.923' AS DateTime), N'Patent', 5173, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7509, CAST(N'2021-04-22T18:26:35.930' AS DateTime), N'Book', 5174, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7510, CAST(N'2021-04-22T18:26:35.937' AS DateTime), N'Book', 5175, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7511, CAST(N'2021-04-22T18:26:35.940' AS DateTime), N'Book', 5176, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7512, CAST(N'2021-04-22T18:26:35.947' AS DateTime), N'Book', 5169, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7513, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Book', 5170, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7514, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Book', 5172, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7515, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Book', 5174, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7516, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Book', 5175, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7517, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Book', 5176, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7518, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Patent', 5171, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7519, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Patent', 5173, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7520, CAST(N'2021-04-22T18:26:35.950' AS DateTime), N'Author', 2566, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7521, CAST(N'2021-04-22T18:26:35.953' AS DateTime), N'Author', 2567, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7522, CAST(N'2021-04-22T18:26:35.953' AS DateTime), N'Author', 2568, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7523, CAST(N'2021-04-22T18:26:35.953' AS DateTime), N'Author', 2569, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7524, CAST(N'2021-04-22T18:26:35.963' AS DateTime), N'Newspaper', 1075, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7525, CAST(N'2021-04-22T18:26:35.970' AS DateTime), N'Newspaper', 1076, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7526, CAST(N'2021-04-22T18:26:35.973' AS DateTime), N'Newspaper', 1077, N'Add', N'Librarian')
GO
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7527, CAST(N'2021-04-22T18:26:35.977' AS DateTime), N'Newspaper', 1077, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7528, CAST(N'2021-04-22T18:26:35.977' AS DateTime), N'Newspaper', 1078, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7529, CAST(N'2021-04-22T18:26:35.980' AS DateTime), N'Newspaper', 1079, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7530, CAST(N'2021-04-22T18:26:35.980' AS DateTime), N'Newspaper', 1080, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7531, CAST(N'2021-04-22T18:26:35.990' AS DateTime), N'Newspaper', 1075, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7532, CAST(N'2021-04-22T18:26:35.990' AS DateTime), N'Newspaper', 1075, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7533, CAST(N'2021-04-22T18:26:35.990' AS DateTime), N'Newspaper', 1076, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7534, CAST(N'2021-04-22T18:26:35.993' AS DateTime), N'Newspaper', 1078, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7535, CAST(N'2021-04-22T18:26:35.993' AS DateTime), N'Newspaper', 1079, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7536, CAST(N'2021-04-22T18:26:35.993' AS DateTime), N'Newspaper', 1080, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7537, CAST(N'2021-04-22T18:26:35.993' AS DateTime), N'Newspaper', 1075, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7538, CAST(N'2021-04-22T18:26:35.993' AS DateTime), N'Newspaper', 1081, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7539, CAST(N'2021-04-22T18:26:36.007' AS DateTime), N'NewspaperIssue', 5177, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7540, CAST(N'2021-04-22T18:26:36.013' AS DateTime), N'NewspaperIssue', 5178, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7541, CAST(N'2021-04-22T18:26:36.020' AS DateTime), N'NewspaperIssue', 5179, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7542, CAST(N'2021-04-22T18:26:36.023' AS DateTime), N'NewspaperIssue', 5180, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7543, CAST(N'2021-04-22T18:26:36.027' AS DateTime), N'NewspaperIssue', 5181, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7544, CAST(N'2021-04-22T18:26:36.030' AS DateTime), N'Newspaper', 1082, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7545, CAST(N'2021-04-22T18:26:36.033' AS DateTime), N'NewspaperIssue', 5182, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7546, CAST(N'2021-04-22T18:26:36.040' AS DateTime), N'NewspaperIssue', 5183, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7547, CAST(N'2021-04-22T18:26:36.040' AS DateTime), N'NewspaperIssue', 5183, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7548, CAST(N'2021-04-22T18:26:36.043' AS DateTime), N'NewspaperIssue', 5184, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7549, CAST(N'2021-04-22T18:26:36.043' AS DateTime), N'NewspaperIssue', 5185, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7550, CAST(N'2021-04-22T18:26:36.047' AS DateTime), N'NewspaperIssue', 5186, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7551, CAST(N'2021-04-22T18:26:36.060' AS DateTime), N'NewspaperIssues', 5177, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7552, CAST(N'2021-04-22T18:26:36.060' AS DateTime), N'NewspaperIssue', 5177, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7553, CAST(N'2021-04-22T18:26:36.060' AS DateTime), N'NewspaperIssue', 5178, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7554, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5179, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7555, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5180, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7556, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5181, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7557, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5182, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7558, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5184, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7559, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5185, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7560, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5186, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7561, CAST(N'2021-04-22T18:26:36.063' AS DateTime), N'NewspaperIssue', 5177, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7562, CAST(N'2021-04-22T18:26:36.067' AS DateTime), N'Newspaper', 1081, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7563, CAST(N'2021-04-22T18:26:36.067' AS DateTime), N'Newspaper', 1082, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7564, CAST(N'2021-04-22T18:26:36.067' AS DateTime), N'Newspaper', 1082, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7565, CAST(N'2021-04-22T18:26:36.077' AS DateTime), N'Patent', 5187, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7566, CAST(N'2021-04-22T18:26:36.083' AS DateTime), N'Patent', 5188, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7567, CAST(N'2021-04-22T18:26:36.090' AS DateTime), N'Patent', 5189, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7568, CAST(N'2021-04-22T18:26:36.093' AS DateTime), N'Patent', 5190, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7569, CAST(N'2021-04-22T18:26:36.100' AS DateTime), N'Author', 2570, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7570, CAST(N'2021-04-22T18:26:36.110' AS DateTime), N'Author', 2571, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7571, CAST(N'2021-04-22T18:26:36.113' AS DateTime), N'Patent', 5191, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7572, CAST(N'2021-04-22T18:26:36.133' AS DateTime), N'Patent', 5192, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7573, CAST(N'2021-04-22T18:26:36.133' AS DateTime), N'Patent', 5192, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7574, CAST(N'2021-04-22T18:26:36.137' AS DateTime), N'Patent', 5193, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7575, CAST(N'2021-04-22T18:26:36.140' AS DateTime), N'Patent', 5194, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7576, CAST(N'2021-04-22T18:26:36.143' AS DateTime), N'Patent', 5195, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7577, CAST(N'2021-04-22T18:26:36.167' AS DateTime), N'Patent', 5187, N'Update', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7578, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5187, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7579, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5188, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7580, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5189, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7581, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5190, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7582, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5191, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7583, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5193, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7584, CAST(N'2021-04-22T18:26:36.170' AS DateTime), N'Patent', 5194, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7585, CAST(N'2021-04-22T18:26:36.173' AS DateTime), N'Patent', 5195, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7586, CAST(N'2021-04-22T18:26:36.173' AS DateTime), N'Patent', 5187, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7587, CAST(N'2021-04-22T18:26:36.173' AS DateTime), N'Author', 2570, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7588, CAST(N'2021-04-22T18:26:36.173' AS DateTime), N'Author', 2571, N'Remove', N'Admin')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7589, CAST(N'2021-04-22T18:42:23.633' AS DateTime), N'Newspaper', 1083, N'Add', N'Librarian')
INSERT [dbo].[Logs] ([Id], [Date], [Type], [ObjectId], [Annotation], [UserName]) VALUES (7590, CAST(N'2021-04-22T18:42:46.903' AS DateTime), N'NewspaperIssue', 5196, N'Add', N'Librarian')
SET IDENTITY_INSERT [dbo].[Logs] OFF
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([Id], [Name]) VALUES (1, N'admin')
INSERT [dbo].[Roles] ([Id], [Name]) VALUES (2, N'librarian')
INSERT [dbo].[Roles] ([Id], [Name]) VALUES (3, N'user')
SET IDENTITY_INSERT [dbo].[Roles] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Login], [Password], [RoleId]) VALUES (1, N'Log3', N'<�	��%5MU�!Y�n8�?!s���>�L~z��닅>;�a;1�\�6!M��JB�z/ۄ�k�\D�', 3)
INSERT [dbo].[Users] ([Id], [Login], [Password], [RoleId]) VALUES (2, N'Log2', N'<�	��%5MU�!Y�n8�?!s���>�L~z��닅>;�a;1�\�6!M��JB�z/ۄ�k�\D�', 2)
INSERT [dbo].[Users] ([Id], [Login], [Password], [RoleId]) VALUES (3, N'Log1', N'<�	��%5MU�!Y�n8�?!s���>�L~z��닅>;�a;1�\�6!M��JB�z/ۄ�k�\D�', 1)
SET IDENTITY_INSERT [dbo].[Users] OFF
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
ALTER TABLE [dbo].[NewspaperIssues]  WITH CHECK ADD  CONSTRAINT [FK_NewspaperIssues_Newspaper] FOREIGN KEY([NewspaperId])
REFERENCES [dbo].[Newspapers] ([Id])
GO
ALTER TABLE [dbo].[NewspaperIssues] CHECK CONSTRAINT [FK_NewspaperIssues_Newspaper]
GO
ALTER TABLE [dbo].[NewspaperIssues]  WITH CHECK ADD  CONSTRAINT [FK_Newspapers_Catalogue] FOREIGN KEY([CatalogueId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[NewspaperIssues] CHECK CONSTRAINT [FK_Newspapers_Catalogue]
GO
ALTER TABLE [dbo].[Patents]  WITH CHECK ADD  CONSTRAINT [FK_Patents_Catalogue] FOREIGN KEY([CatalogueId])
REFERENCES [dbo].[Catalogue] ([Id])
GO
ALTER TABLE [dbo].[Patents] CHECK CONSTRAINT [FK_Patents_Catalogue]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Users] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Users]
GO
/****** Object:  StoredProcedure [dbo].[Authors_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_Check]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_Mark]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_SearchByFirstName]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_SearchByLastName]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Authors_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[AuthorsBooksAndPatents_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_GetByAuthorId]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_Mark]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_SearchByName]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_SearchByPublisher]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_SearchByPublishingYear]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Books_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Catalogue_Count]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Catalogue_Count]
AS
BEGIN
	select COUNT(*) as [Count] from Catalogue
	where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_CountByName]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Catalogue_CountByName]
	@SearchLine nvarchar(300) = null
AS
BEGIN
	select COUNT(*) as [Count] from Catalogue
	where	[Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and 
			(Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Catalogue_GetByAuthorId]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Catalogue_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
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
		    NewspaperIssues.CatalogueId as NewspaperId
		from Catalogue
		full join Books on Catalogue.Id = Books.CatalogueId
		full join Patents on Catalogue.Id = Patents.CatalogueId
		full join NewspaperIssues on Catalogue.Id = NewspaperIssues.CatalogueId
		where Catalogue.Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[Catalogue_SearchByName]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Logging_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Logging_Add]
	@Login nvarchar(50),
	@Layer nvarchar(10),
	@Class nvarchar(500),
	@Method nvarchar(500),
	@Message nvarchar(4000)

AS
BEGIN
	insert Logging ([DateTime], [Login], Layer, Class, Method, [Message])
	values (CURRENT_TIMESTAMP, @Login, @Layer, @Class, @Method, @Message)
END

GO
/****** Object:  StoredProcedure [dbo].[Logs_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_Add]
	@Id int = null output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@Number int = null,
	@Date date,
	@NewspaperId int
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaperIssue
				@Name = @Name,
				@Publisher = @Publisher,
				@Date = @Date;

			if @Unique = 0
				set @Id = null;
			else
			begin
				insert Catalogue (Name, NumberOfPages, Annotation, Deleted)
					values (@Name, @NumberOfPages, @Annotation, 0);

				set @Id = @@IDENTITY;

				insert NewspaperIssues(Publisher, PublishingCity, Number, [Date], CatalogueId, NewspaperId)
					values (@Publisher, @PublishingCity, @Number, @Date, @id, @NewspaperId);

				EXEC [dbo].[Logs_Add]
					@Type = N'NewspaperIssue',
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
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_GetAll]
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
				NewspaperId
			from NewspaperIssues
			inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
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
				NewspaperId
			from NewspaperIssues
			inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_GetAllByNewspaperId]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_GetAllByNewspaperId]
	@Id int,
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
			NewspaperId
		FROM NewspaperIssues
		inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
		where NewspaperId = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
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
			NewspaperId
		FROM NewspaperIssues
		inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
		where NewspaperId = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
		order by [Date] asc, [Name] asc
		offset @SizePage * (@Page - 1) Row
		Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_GetById]
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
		Publisher,
		PublishingCity,
		Number,
		[Date],
		NewspaperId
	FROM NewspaperIssues
	inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
	where Catalogue.Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_GetCountByNewspaperId]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_GetCountByNewspaperId]
	@Id int

AS
BEGIN
	SET NOCOUNT ON;

		SELECT Count(*) as [Count] FROM NewspaperIssues
		inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
		where NewspaperId = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_Mark]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NewspaperIssues_Mark]
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
				@Type = N'NewspaperIssue',
				@ObjectId = @Id,
				@Annotation = @Annotation;
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NewspaperIssues_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
				delete top(1) NewspaperIssues where CatalogueId = @Id

				delete top(1) Catalogue where Id = @Id

				EXEC [dbo].[Logs_Add]
					@Type = N'NewspaperIssue',
					@ObjectId = @Id,
					@Annotation = N'Remove'
			end
			else 
			begin
				exec dbo.NewspaperIssues_Mark
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
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_SearchByName]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NewspaperIssues_SearchByName]
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
				NewspaperId
			from NewspaperIssues
			inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
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
				NewspaperId
			from NewspaperIssues
			inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_SearchByPublishingYear]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NewspaperIssues_SearchByPublishingYear]
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
			NewspaperId
		FROM NewspaperIssues
		inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
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
			NewspaperId
		FROM NewspaperIssues
		inner join Catalogue on NewspaperIssues.CatalogueId = Catalogue.Id
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
/****** Object:  StoredProcedure [dbo].[NewspaperIssues_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NewspaperIssues_Update]
	@Id int output,
	@Name nvarchar(300),
	@NumberOfPages int,
	@Annotation nvarchar(2000) = null,
	@Publisher nvarchar(300),
	@PublishingCity nvarchar(200),
	@Number int = null,
	@Date date,
	@NewspaperId int
	
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaperIssue
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

				update NewspaperIssues set
					Publisher = @Publisher,
					PublishingCity = @PublishingCity,
					Number = @Number,
					[Date] = @Date,
					NewspaperId = @NewspaperId
				where CatalogueId = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'NewspaperIssues',
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
/****** Object:  StoredProcedure [dbo].[Newspapers_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Newspapers_Add]
	@Id int output,
	@Name nvarchar(300),
	@Issn nvarchar(14) = null
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaper
				@Name = @Name,
				@Issn = @Issn;

			if @Unique = 0
				set @Id = null;
			else
			begin
				Insert Newspapers([Name], ISSN, Deleted)
				values (@Name, @Issn, 0);

				set @Id = @@IDENTITY;

				EXEC [dbo].[Logs_Add]
					@Type = N'Newspaper',
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
/****** Object:  StoredProcedure [dbo].[Newspapers_Check]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Newspapers_Check]
	@NewspaperIssueIDs dbo.IDList readonly
AS
BEGIN
	SET NOCOUNT ON;

	declare @NewspaperIssueIdCount int;
	set @NewspaperIssueIdCount = (select Count(*) from @NewspaperIssueIDs);

	declare @Count int;
	select @Count = count(*) from Newspapers
	where Id in (select ID from @NewspaperIssueIDs)

	if @NewspaperIssueIdCount = @Count
		select cast(1 as bit) as Result;
	else 
		select cast(0 as bit) as Result;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Newspapers_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Id, 
				[Name],
				ISSN,
				Deleted
			from Newspapers
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Id, 
				[Name],
				ISSN,
				Deleted
			from Newspapers
			where (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Newspapers_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top(1) 
		Id, 
		[Name],
		ISSN,
		Deleted
	FROM Newspapers
	where Id = @Id and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1);
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Mark]    Script Date: 4/22/2021 8:23:30 PM ******/
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
			update Newspapers set
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
/****** Object:  StoredProcedure [dbo].[Newspapers_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Newspapers_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			if IS_ROLEMEMBER('db_admin') = 1
			begin
				delete top(1) Newspapers where Id = @Id

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
/****** Object:  StoredProcedure [dbo].[Newspapers_SearchByName]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Newspapers_SearchByName]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select 
				Id, 
				[Name],
				ISSN,
				Deleted
			from Newspapers
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select 
				Id, 
				[Name],
				ISSN,
				Deleted
			from Newspapers
			where [Name] like N'%' + ISNULL(@SearchLine,N'') + N'%' and (Deleted = 0 or IS_ROLEMEMBER('db_admin') = 1)
			order by [Name] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Newspapers_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Newspapers_Update]
	@Id int output,
	@Name nvarchar(300),
	@Issn nvarchar(14) = null
	
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueNewspaper
				@Id = @Id,
				@Name = @Name,
				@Issn = @Issn;

			if @Unique = 0
				rollback;
			else
			begin

				update Newspapers set
					[Name] = @Name,
					ISSN = @Issn
				where Id = @Id;

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
/****** Object:  StoredProcedure [dbo].[Patents_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_GetByAuthorId]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_Mark]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_SearchByName]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_SearchByPublishingYear]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Patents_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
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
/****** Object:  StoredProcedure [dbo].[Roles_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Roles_Add]
	@Id int output,
	@Name nvarchar(50)
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueRole
				@Name = @Name;

			if @Unique = 0
				set @Id = null;
			else
			begin
				insert Roles ([Name]) values (@Name);

				set @Id = @@IDENTITY;

				EXEC [dbo].[Logs_Add]
					@Type = N'Role',
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
/****** Object:  StoredProcedure [dbo].[Roles_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Roles_GetAll]
	
AS
BEGIN
	SET NOCOUNT ON;

	select Id, [Name] from Roles;
END

GO
/****** Object:  StoredProcedure [dbo].[Roles_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Roles_GetById]
	@Id int
AS
BEGIN
	SET NOCOUNT ON;

	select top(1) Id, [Name] from Roles
	where Id = @Id;
END

GO
/****** Object:  StoredProcedure [dbo].[Roles_GetByName]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Roles_GetByName]
	@Name nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select top(1) Id, [Name] from Roles
	where [Name] = @Name;
END

GO
/****** Object:  StoredProcedure [dbo].[Roles_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Roles_Remove]
	@Id int
AS
BEGIN
	begin try
		begin tran
			delete Roles where Id = @Id;

			EXEC [dbo].[Logs_Add]
				@Type = N'Role',
				@ObjectId = @Id,
				@Annotation = N'Remove';
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Roles_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Roles_Update]
	@Id int output,
	@Name nvarchar(50)
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueRole
				@Id = @Id,
				@Name = @Name;

			if @Unique = 0
				rollback;
			else
			begin
				Update Roles set 
					[Name] = @Name
				where Id = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'Role',
					@ObjectId = @Id,
					@Annotation = N'Update';
			end
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Users_Add]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Users_Add]
	@Id int output,
	@Login nvarchar(50),
	@Password nvarchar(200),
	@RoleId int
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueUser
				@Login = @Login;

			if @Unique = 0
				set @Id = null;
			else
			begin
				insert Users ([Login], [Password], RoleId) values 
							 (@Login, @Password, @RoleId);

				set @Id = @@IDENTITY;

				EXEC [dbo].[Logs_Add]
					@Type = N'User',
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
/****** Object:  StoredProcedure [dbo].[Users_Count]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_Count]
AS
BEGIN
	select COUNT(*) as [Count] from Users
END

GO
/****** Object:  StoredProcedure [dbo].[Users_CountByLogin]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_CountByLogin]
	@SearchLine nvarchar(50) = null
AS
BEGIN
	select COUNT(*) as [Count] from Users
	where	[Login] like N'%' + ISNULL(@SearchLine,N'') + N'%'
END

GO
/****** Object:  StoredProcedure [dbo].[Users_GetAll]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Users_GetAll]
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select Id, [Login], [Password], RoleId from Users
			order by [Login] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, [Login], [Password], RoleId from Users
			order by [Login] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Users_GetById]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_GetById]
	@Id bigint
AS
BEGIN
	SET NOCOUNT ON;

	select top(1) Id, [Login], [Password], RoleId from Users
	where Id = @Id;
END

GO
/****** Object:  StoredProcedure [dbo].[Users_GetByLogin]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_GetByLogin]
	@Login nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select top(1) Id, [Login], [Password], RoleId from Users
	where [Login] = @Login;
END

GO
/****** Object:  StoredProcedure [dbo].[Users_Remove]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_Remove]
	@Id bigint
AS
BEGIN
	begin try
		begin tran
			delete Users where Id = @Id;

			EXEC [dbo].[Logs_Add]
				@Type = N'User',
				@ObjectId = @Id,
				@Annotation = N'Remove';
		commit
	end try
	begin catch
		if @@ERROR <> 0 rollback
	end catch
END

GO
/****** Object:  StoredProcedure [dbo].[Users_SearchByLogin]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Users_SearchByLogin]
	@SearchLine nvarchar(300) = null,
	@SortDescending bit,
	@SizePage int,
	@Page int
	
AS
BEGIN
	SET NOCOUNT ON;

		if @SortDescending = 1
			select Id, [Login], [Password], RoleId from Users
			where [Login] like N'%' + ISNULL(@SearchLine,N'') + N'%'
			order by [Login] desc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
		else
			select Id, [Login], [Password], RoleId from Users
			where [Login] like N'%' + ISNULL(@SearchLine,N'') + N'%'
			order by [Login] asc
			offset @SizePage * (@Page - 1) Row
			Fetch First @SizePage Rows Only;
END

GO
/****** Object:  StoredProcedure [dbo].[Users_Update]    Script Date: 4/22/2021 8:23:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Users_Update]
	@Id int output,
	@Login nvarchar(50),
	@Password nvarchar(200),
	@RoleId int
AS
BEGIN
	begin try
		begin tran
			declare @Unique bit;

			exec @Unique = dbo.CheckUniqueUser
				@Id = @Id,
				@Login = @Login;

			if @Unique = 0
				rollback;
			else
			begin
				update Users set 
					[Login] = @Login,
					[Password] = @Password,
					RoleId = @RoleId
				where Id = @Id;

				EXEC [dbo].[Logs_Add]
					@Type = N'User',
					@ObjectId = @Id,
					@Annotation = N'Update';
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

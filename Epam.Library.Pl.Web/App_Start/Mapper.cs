using AutoMapper;
using Epam.Common.Entities;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Epam.Library.Pl.Web
{
    public class Mapper
    {
        private IMapper _mapper;
        private IAuthorBll _authorBll;
        private IRoleBll _roleBll;

        public Mapper(IAuthorBll authorBll, IRoleBll roleBll)
        {
            _authorBll = authorBll;
            _roleBll = roleBll;

            RegisterMaps();
        }

        public void RegisterMaps()
        {
            _mapper = new MapperConfiguration(cfg =>
            {
                #region ElementVM
                cfg.CreateMap<Book, ElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => GetNameFromBook(c).ToString()))
                    .ForMember(dest => dest.Identity, opt => opt.MapFrom(c => c.Isbn ?? "<no identity>"))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.IsDeleted, opt => opt.MapFrom(c => c.Deleted))
                    .ForMember(dest => dest.Type, opt => opt.MapFrom(c => TypeEnumVM.Book));
                cfg.CreateMap<Patent, ElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => $"\"{c.Name}\" от {c.DateOfPublication.ToString("dd.MM.yyyy")}"))
                    .ForMember(dest => dest.Identity, opt => opt.MapFrom(c => c.RegistrationNumber))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.IsDeleted, opt => opt.MapFrom(c => c.Deleted))
                    .ForMember(dest => dest.Type, opt => opt.MapFrom(c => TypeEnumVM.Patent));
                // Newspapers
                #endregion

                #region BookVM
                cfg.CreateMap<Book, DisplayBookVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Authors, opt => opt.MapFrom(c => GetAuthorsByIDs(c.AuthorIDs, (f, l) => $"{f} {l}")))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.PublishingYear, opt => opt.MapFrom(c => c.PublishingYear))
                    .ForMember(dest => dest.Isbn, opt => opt.MapFrom(c => c.Isbn));

                cfg.CreateMap<Book, CreateEditBookVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.AuthorIDs, opt => opt.MapFrom(c => c.AuthorIDs))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.PublishingYear, opt => opt.MapFrom(c => c.PublishingYear))
                    .ForMember(dest => dest.Isbn, opt => opt.MapFrom(c => c.Isbn));

                cfg.CreateMap<CreateEditBookVM, Book>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Deleted, opt => opt.MapFrom(c => false))
                    .ForMember(dest => dest.AuthorIDs, opt => opt.MapFrom(c => c.AuthorIDs))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.PublishingYear, opt => opt.MapFrom(c => c.PublishingYear))
                    .ForMember(dest => dest.Isbn, opt => opt.MapFrom(c => c.Isbn));
                #endregion

                #region PatentVM
                cfg.CreateMap<Patent, DisplayPatentVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Authors, opt => opt.MapFrom(c => GetAuthorsByIDs(c.AuthorIDs, (f, l) => $"{f} {l}")))
                    .ForMember(dest => dest.Country, opt => opt.MapFrom(c => c.Country))
                    .ForMember(dest => dest.RegistrationNumber, opt => opt.MapFrom(c => c.RegistrationNumber))
                    .ForMember(dest => dest.ApplicationDate, opt => opt.MapFrom(c => c.ApplicationDate))
                    .ForMember(dest => dest.DateOfPublication, opt => opt.MapFrom(c => c.DateOfPublication));

                cfg.CreateMap<Patent, CreateEditPatentVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.AuthorIDs, opt => opt.MapFrom(c => c.AuthorIDs))
                    .ForMember(dest => dest.Country, opt => opt.MapFrom(c => c.Country))
                    .ForMember(dest => dest.RegistrationNumber, opt => opt.MapFrom(c => c.RegistrationNumber))
                    .ForMember(dest => dest.ApplicationDate, opt => opt.MapFrom(c => c.ApplicationDate))
                    .ForMember(dest => dest.DateOfPublication, opt => opt.MapFrom(c => c.DateOfPublication));
                
                cfg.CreateMap<CreateEditPatentVM, Patent>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Deleted, opt => opt.Ignore())
                    .ForMember(dest => dest.AuthorIDs, opt => opt.MapFrom(c => c.AuthorIDs))
                    .ForMember(dest => dest.Country, opt => opt.MapFrom(c => c.Country))
                    .ForMember(dest => dest.RegistrationNumber, opt => opt.MapFrom(c => c.RegistrationNumber))
                    .ForMember(dest => dest.ApplicationDate, opt => opt.MapFrom(c => c.ApplicationDate))
                    .ForMember(dest => dest.DateOfPublication, opt => opt.MapFrom(c => c.DateOfPublication));
                #endregion

                #region AuthorVM
                cfg.CreateMap<Author, DisplayAuthorVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.FirstName, opt => opt.MapFrom(c => c.FirstName))
                    .ForMember(dest => dest.LastName, opt => opt.MapFrom(c => c.LastName))
                    .ForMember(dest => dest.IsDeleted, opt => opt.MapFrom(c => c.Deleted));

                cfg.CreateMap<CreateEditAuthorVM, Author>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.FirstName, opt => opt.MapFrom(c => c.FirstName))
                    .ForMember(dest => dest.LastName, opt => opt.MapFrom(c => c.LastName))
                    .ForMember(dest => dest.Deleted, opt => opt.Ignore());

                cfg.CreateMap<Author, CreateEditAuthorVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.FirstName, opt => opt.MapFrom(c => c.FirstName))
                    .ForMember(dest => dest.LastName, opt => opt.MapFrom(c => c.LastName));
                #endregion

                #region AccountVM
                cfg.CreateMap<Account, AccountVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Login, opt => opt.MapFrom(c => c.Login))
                    .ForMember(dest => dest.Role, opt => opt.MapFrom(c => _roleBll.GetById(c.RoleId)));
                cfg.CreateMap<CreateAccountVM, Account>()
                    .ForMember(dest => dest.Id, opt => opt.Ignore())
                    .ForMember(dest => dest.Login, opt => opt.MapFrom(c => c.Login))
                    .ForMember(dest => dest.Password, opt => opt.MapFrom(c => c.Password))
                    .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                    .ForMember(dest => dest.RoleId, opt => opt.Ignore());
                #endregion
            }).CreateMapper();

            _mapper.ConfigurationProvider.AssertConfigurationIsValid();
        }

        private StringBuilder GetNameFromBook(Book book)
        {
            StringBuilder str = new StringBuilder();

            if (book.AuthorIDs?.Length > 0)
            {
                foreach (var item in book.AuthorIDs)
                {
                    var author = _authorBll.Get(item);

                    if (str.Length != 0)
                    {
                        str.Append(", ");
                    }
                    str.Append($"{author.FirstName.FirstOrDefault()}.{author.LastName}");
                }
                str.Append(" - ");
            }

            str.Append($"{book.Name} ({book.PublishingYear})");

            return str;
        }
        private string GetAuthorsByIDs(int[] authorIDs, Func<string, string, string> format)
        {
            if (authorIDs is null || authorIDs.Length == 0)
            {
                return null;
            }

            StringBuilder builder = new StringBuilder();

            DisplayAuthorVM author;
            foreach (var item in authorIDs)
            {
                if (builder.Length != 0)
                {
                    builder.Append(", ");
                }

                author = Map<DisplayAuthorVM, Author>(_authorBll.Get(item));
                builder.Append(format(author.FirstName, author.LastName));
            }

            return builder.ToString();
        }

        public TResult Map<TResult, TModel>(TModel model)
        {
            return _mapper.Map<TModel, TResult>(model);
        }
    }
}
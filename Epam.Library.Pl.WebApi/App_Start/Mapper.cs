using AutoMapper;
using Epam.Library.Bll.Contracts;
using Epam.Library.Common.Entities;
using Epam.Library.Common.Entities.AuthorElement;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Common.Entities.Newspaper;
using Epam.Library.Pl.WebApi.Models;
using System;
using System.Collections.Generic;

namespace Epam.Library.Pl.WebApi
{
    public class Mapper
    {
        private IMapper _mapper;
        private INewspaperBll _newspaperBll;
        private IAuthorBll _authorBll;
        private IRoleBll _roleBll;
        private RoleType _role;

        public Mapper(IAuthorBll authorBll, INewspaperBll newspaperBll, IRoleBll roleBll)
        {
            _authorBll = authorBll;
            _newspaperBll = newspaperBll;
            _roleBll = roleBll;
            _role = RoleType.externalClient;

            RegisterMaps();
        }

        public void RegisterMaps()
        {
            _mapper = new MapperConfiguration(cfg =>
            {
                #region ElementVM
                cfg.CreateMap<Book, CatalogueElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Type, opt => opt.MapFrom(c => TypeEnumVM.Book.ToString()));
                cfg.CreateMap<Patent, CatalogueElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Type, opt => opt.MapFrom(c => TypeEnumVM.Patent.ToString()));
                cfg.CreateMap<NewspaperIssue, CatalogueElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Type, opt => opt.MapFrom(c => TypeEnumVM.NewspaperIssue.ToString()));
                cfg.CreateMap<Newspaper, ElementVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name));
                cfg.CreateMap<Author, AuthorVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.FirstName, opt => opt.MapFrom(c => c.FirstName))
                    .ForMember(dest => dest.LastName, opt => opt.MapFrom(c => c.LastName));
                #endregion

                #region AuthorVM
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

                #region NewspaperVM
                cfg.CreateMap<Newspaper, DisplayNewspaperVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.ISSN, opt => opt.MapFrom(c => c.Issn));
                cfg.CreateMap<CreateEditNewspaperVM, Newspaper>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.Issn, opt => opt.MapFrom(c => c.ISSN))
                    .ForMember(dest => dest.Deleted, opt => opt.Ignore());
                cfg.CreateMap<Newspaper, CreateEditNewspaperVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.ISSN, opt => opt.MapFrom(c => c.Issn));
                #endregion

                #region BookVM
                cfg.CreateMap<Book, DisplayBookVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Authors, opt => opt.MapFrom(c => GetAuthorsByIDs(c.AuthorIDs)))
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
                    .ForMember(dest => dest.Authors, opt => opt.MapFrom(c => GetAuthorsByIDs(c.AuthorIDs)))
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

                #region NewspaperIssue
                cfg.CreateMap<NewspaperIssue, DisplayNewspaperIssueVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.Number, opt => opt.MapFrom(c => c.Number))
                    .ForMember(dest => dest.Date, opt => opt.MapFrom(c => c.Date))
                    .ForMember(dest => dest.Newspaper, opt => opt.MapFrom(c => Map<DisplayNewspaperVM, Newspaper>(_newspaperBll.Get(c.NewspaperId, _role))));
                cfg.CreateMap<NewspaperIssue, CreateEditNewspaperIssueVM>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.Number, opt => opt.MapFrom(c => c.Number))
                    .ForMember(dest => dest.Date, opt => opt.MapFrom(c => c.Date))
                    .ForMember(dest => dest.NewspaperId, opt => opt.MapFrom(c => c.NewspaperId));
                cfg.CreateMap<CreateEditNewspaperIssueVM, NewspaperIssue>()
                    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                    .ForMember(dest => dest.Name, opt => opt.MapFrom(c => c.Name))
                    .ForMember(dest => dest.NumberOfPages, opt => opt.MapFrom(c => c.NumberOfPages))
                    .ForMember(dest => dest.Annotation, opt => opt.MapFrom(c => c.Annotation))
                    .ForMember(dest => dest.Deleted, opt => opt.MapFrom(c => false))
                    .ForMember(dest => dest.Publisher, opt => opt.MapFrom(c => c.Publisher))
                    .ForMember(dest => dest.PublishingCity, opt => opt.MapFrom(c => c.PublishingCity))
                    .ForMember(dest => dest.PublishingYear, opt => opt.MapFrom(c => c.Date.Year))
                    .ForMember(dest => dest.Number, opt => opt.MapFrom(c => c.Number))
                    .ForMember(dest => dest.Date, opt => opt.MapFrom(c => c.Date))
                    .ForMember(dest => dest.NewspaperId, opt => opt.MapFrom(c => c.NewspaperId));
                #endregion

                ///
                #region AccountVM
                //cfg.CreateMap<Account, AccountVM>()
                //    .ForMember(dest => dest.Id, opt => opt.MapFrom(c => c.Id))
                //    .ForMember(dest => dest.Login, opt => opt.MapFrom(c => c.Login))
                //    .ForMember(dest => dest.Role, opt => opt.MapFrom(c => _roleBll.GetById(c.RoleId)));
                //cfg.CreateMap<CreateAccountVM, Account>()
                //    .ForMember(dest => dest.Id, opt => opt.Ignore())
                //    .ForMember(dest => dest.Login, opt => opt.MapFrom(c => c.Login))
                //    .ForMember(dest => dest.Password, opt => opt.MapFrom(c => c.Password))
                //    .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                //    .ForMember(dest => dest.RoleId, opt => opt.Ignore());
                #endregion
            }).CreateMapper();

            _mapper.ConfigurationProvider.AssertConfigurationIsValid();
        }

        public TResult Map<TResult, TModel>(TModel model)
        {
            return _mapper.Map<TModel, TResult>(model);
        }
        public IEnumerable<TResult> Map<TResult, TModel>(IEnumerable<TModel> models)
        {
            foreach (var item in models)
            {
                yield return _mapper.Map<TModel, TResult>(item);
            }
        }

        private IEnumerable<AuthorVM> GetAuthorsByIDs(int[] authorIDs)
        {
            if (authorIDs is null || authorIDs.Length == 0)
            {
                return null;
            }

            List<Author> authors = new List<Author>();
            Array.ForEach(authorIDs, (i) => authors.Add(_authorBll.Get(i, _role)));

            return Map<AuthorVM, Author>(authors);
        }
    }
}
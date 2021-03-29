using AutoMapper;
using Epam.Library.Common.Entities.AuthorElement.Book;
using Epam.Library.Common.Entities.AuthorElement.Patent;
using Epam.Library.Pl.Web.ViewModels.Catalogue;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Epam.Library.Pl.Web
{
    public static class MapperConfig
    {
        private static IMapper _mapper;

        public static void RegisterMaps()
        {
            _mapper = new MapperConfiguration(cfg =>
            {
            cfg.CreateMap<Book, ElementVM>()
                .ForMember(nameof(ElementVM.Name), opt => opt.MapFrom((c, f) =>
                    {
                        var d = "fdfdf";

                        return d;
                    }))
                    .ForMember(nameof(ElementVM.Identity), opt => opt.MapFrom(c => c.Isbn));
                cfg.CreateMap<Patent, ElementVM>()
                    .ForMember(nameof(ElementVM.Identity), opt => opt.MapFrom(c => c.RegistrationNumber));
                // Newspapers
            }).CreateMapper();

            _mapper.ConfigurationProvider.AssertConfigurationIsValid();
        }

        public static TResult Map<TResult, TModel>(TModel model)
        {
            return _mapper.Map<TModel, TResult>(model);
        }
    }
}
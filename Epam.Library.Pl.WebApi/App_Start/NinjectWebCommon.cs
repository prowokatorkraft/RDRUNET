[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(Epam.Library.Pl.WebApi.NinjectWebCommon), "Start")]
[assembly: WebActivatorEx.ApplicationShutdownMethodAttribute(typeof(Epam.Library.Pl.WebApi.NinjectWebCommon), "Stop")]
//[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace Epam.Library.Pl.WebApi
{
    using System;
    using System.Web;
    using System.Web.Http;
    using Epam.Library.Common.DependencyInjection;
    using Epam.Library.Pl.WebApi.Models;
    //using log4net;
    using Microsoft.Web.Infrastructure.DynamicModuleHelper;
    using Ninject;
    using Ninject.Web.Common;
    using Ninject.Web.Common.WebHost;
    using WebApiContrib.IoC.Ninject;

    public class NinjectWebCommon
    {
        private static readonly Bootstrapper Bootstrapper = new Bootstrapper();

        public static void Start()
        {
            DynamicModuleUtility.RegisterModule(typeof(OnePerRequestHttpModule));
            DynamicModuleUtility.RegisterModule(typeof(NinjectHttpModule));
            Bootstrapper.Initialize(CreateKernel);
        }

        public static void Stop()
        {
            Bootstrapper.ShutDown();
        }

        private static IKernel CreateKernel()
        {
            var kernel = new StandardKernel();

            try
            {
                kernel.Bind<Func<IKernel>>().ToMethod(ctx => () => new Bootstrapper().Kernel);
                kernel.Bind<IHttpModule>().To<HttpApplicationInitializationHttpModule>();
                GlobalConfiguration.Configuration.DependencyResolver = new NinjectResolver(kernel);

                NinjectConfig.RegisterConfig(kernel);

                #region Model
                kernel
                    .Bind<Mapper>()
                    .ToSelf()
                    .InSingletonScope();
                //kernel
                //    .Bind<RoleProviderModel>()
                //    .ToSelf()
                //    .InSingletonScope();
                //kernel.Get<RoleProviderModel>();

                //kernel.Bind<ILog>()
                //    .ToConstant(LogManager.GetLogger("WebPL"))
                //    .InSingletonScope();

                //kernel.Load<FilterBindingModule>();
                #endregion

                return kernel;
            }
            catch
            {
                kernel.Dispose();
                throw;
            }
        }
    }
}

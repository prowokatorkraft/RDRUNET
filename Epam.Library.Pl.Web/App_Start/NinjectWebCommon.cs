[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(Epam.Library.Pl.Web.NinjectWebCommon), "Start")]
[assembly: WebActivatorEx.ApplicationShutdownMethodAttribute(typeof(Epam.Library.Pl.Web.NinjectWebCommon), "Stop")]
[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace Epam.Library.Pl.Web
{
    using System;
    using System.Web;
    using Epam.Library.Common.DependencyInjection;
    using Epam.Library.Pl.Web.Models;
    using log4net;
    using Microsoft.Web.Infrastructure.DynamicModuleHelper;
    using Ninject;
    using Ninject.Web.Common;
    using Ninject.Web.Common.WebHost;

    public static class NinjectWebCommon
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

                NinjectConfig.RegisterConfig(kernel);

                #region Model
                kernel
                    .Bind<Mapper>()
                    .ToSelf()
                    .InSingletonScope();
                kernel
                    .Bind<RoleProviderModel>()
                    .ToSelf()
                    .InSingletonScope();
                kernel.Get<RoleProviderModel>();

                kernel.Bind<ILog>()
                    .ToConstant(LogManager.GetLogger("WebPL"))
                    .InSingletonScope();

                kernel.Load<FilterBindingModule>();
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
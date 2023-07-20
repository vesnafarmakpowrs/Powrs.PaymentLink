using Paiwise;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using TAG.Networking.OpenPaymentsPlatform;
using TAG.Payments.OpenPaymentsPlatform.Api;
using Waher.Events;
using Waher.IoTGateway;
using Waher.Networking.HTTP;
using Waher.Networking.Sniffers;
using Waher.Persistence;
using Waher.Runtime.Inventory;

namespace TAG.Payments.OpenPaymentsPlatform
{

	/// <summary>
	/// Open Payments Platform service provider
	/// </summary>
	public class PayoutServiceProvider : IConfigurableModule
	{
		/// <summary>
		/// Reference to client sniffer for Production communication.
		/// </summary>
		internal static XmlFileSniffer SnifferProduction = null;

		/// <summary>
		/// Reference to client sniffer for Sandbox communication.
		/// </summary>
		internal static XmlFileSniffer SnifferSandbox = null;

		/// <summary>
		/// Sniffable object that can be sniffed on dynamically.
		/// </summary>
		private static readonly Sniffable sniffable = new Sniffable();

		/// <summary>
		/// Sniffer proxy, forwarding sniffer events to <see cref="sniffable"/>.
		/// </summary>
		private static readonly SnifferProxy snifferProxy = new SnifferProxy(sniffable);

		/// <summary>
		/// Users are required to have this privilege in order to show and sign payments using this service.
		/// </summary>
		internal const string RequiredPrivilege = "Admin.Payments.Payout";

		/// <summary>
		/// Open Payments Platform service provider
		/// </summary>
		public PayoutServiceProvider()
		{
		}

		#region IModule

		private readonly static SignPayments signPayments = new SignPayments();
		private readonly static ReturnPayments returnPayments = new ReturnPayments();
		private readonly static RetryPayments retryPayments = new RetryPayments();

		/// <summary>
		/// Starts the service.
		/// </summary>
		public Task Start()
		{
			Gateway.HttpServer.Register(signPayments);
			Gateway.HttpServer.Register(returnPayments);
			Gateway.HttpServer.Register(retryPayments);

			return Task.CompletedTask;
		}

		/// <summary>
		/// Stops the service.
		/// </summary>
		public Task Stop()
		{
			Gateway.HttpServer.Unregister(signPayments);
			Gateway.HttpServer.Unregister(returnPayments);
			Gateway.HttpServer.Unregister(retryPayments);

			SnifferProduction?.Dispose();
			SnifferProduction = null;

			SnifferSandbox?.Dispose();
			SnifferSandbox = null;

			return Task.CompletedTask;
		}

		#endregion

		#region IConfigurableModule interface

		/// <summary>
		/// Gets an array of configurable pages for the module.
		/// </summary>
		/// <returns>Configurable pages</returns>
		public Task<IConfigurablePage[]> GetConfigurablePages()
		{
			return Task.FromResult(new IConfigurablePage[]
			{
				new ConfigurablePage("Open Payments Platform", "/OpenPaymentsPlatform/Settings.md", "Admin.Payments.Paiwise.OpenPaymentsPlatform")
			});
		}

		#endregion

		#region IServiceProvider

		/// <summary>
		/// ID of service
		/// </summary>
		public string Id => ServiceId;

		/// <summary>
		/// ID of service.
		/// </summary>
		public static string ServiceId = typeof(PayoutServiceProvider).Namespace;

		/// <summary>
		/// Name of service
		/// </summary>
		public string Name => "Open Payments Platform";

		/// <summary>
		/// Icon URL
		/// </summary>
		public string IconUrl => "https://docs.openpayments.io/img/header_logo.svg";

		/// <summary>
		/// Width of icon, in pixels.
		/// </summary>
		public int IconWidth => 181;

		/// <summary>
		/// Height of icon, in pixels
		/// </summary>
		public int IconHeight => 150;

		#endregion

		#region Open Payments Platform interface

		private readonly static Dictionary<CaseInsensitiveString, KeyValuePair<OpenPaymentsPlatformService[], DateTime>> productionServicesByCountry = new Dictionary<CaseInsensitiveString, KeyValuePair<OpenPaymentsPlatformService[], DateTime>>();
		private readonly static Dictionary<CaseInsensitiveString, KeyValuePair<OpenPaymentsPlatformService[], DateTime>> sandboxServicesByCountry = new Dictionary<CaseInsensitiveString, KeyValuePair<OpenPaymentsPlatformService[], DateTime>>();
		private readonly static object synchObj = new object();

		internal static void InvalidateServices()
		{
			lock (synchObj)
			{
				productionServicesByCountry.Clear();
				sandboxServicesByCountry.Clear();
			}
		}

		internal static OpenPaymentsPlatformClient CreateClient(ServiceConfiguration Configuration)
		{
			return CreateClient(Configuration, Configuration.OperationMode);
		}

		internal static OpenPaymentsPlatformClient CreateClient(ServiceConfiguration Configuration, OperationMode Mode)
		{
			return CreateClient(Configuration, Mode, Configuration.Purpose);
		}

		internal static OpenPaymentsPlatformClient CreateClient(ServiceConfiguration Configuration, OperationMode Mode,
			ServicePurpose Purpose)
		{
			if (!Configuration.IsWellDefined)
				return null;

			switch (Mode)
			{
				case OperationMode.Production:
					if (SnifferProduction is null)
					{
						SnifferProduction = new XmlFileSniffer(Gateway.AppDataFolder + "OPP_Production" + Path.DirectorySeparatorChar +
							"Log %YEAR%-%MONTH%-%DAY%T%HOUR%.xml",
							Gateway.AppDataFolder + "Transforms" + Path.DirectorySeparatorChar + "SnifferXmlToHtml.xslt",
							7, BinaryPresentationMethod.Base64);
					}

					return OpenPaymentsPlatformClient.CreateProduction(Configuration.ClientID, Configuration.ClientSecret,
						Configuration.Certificate, Purpose, SnifferProduction, snifferProxy);

				case OperationMode.Sandbox:
					if (SnifferSandbox is null)
					{
						SnifferSandbox = new XmlFileSniffer(Gateway.AppDataFolder + "OPP_Sandbox" + Path.DirectorySeparatorChar +
							"Log %YEAR%-%MONTH%-%DAY%T%HOUR%.xml",
							Gateway.AppDataFolder + "Transforms" + Path.DirectorySeparatorChar + "SnifferXmlToHtml.xslt",
							7, BinaryPresentationMethod.Base64);
					}

					return OpenPaymentsPlatformClient.CreateSandbox(Configuration.ClientID, Configuration.ClientSecret,
						Purpose, SnifferSandbox, snifferProxy);

				default:
					return null;
			}
		}

		internal static void Dispose(OpenPaymentsPlatformClient Client, OperationMode Mode)
		{
			Client?.Remove(Mode == OperationMode.Production ? SnifferProduction : SnifferSandbox);
			Client?.Remove(snifferProxy);
			Client?.Dispose();
		}

		/// <summary>
		/// Registers a web sniffer on the stripe client.
		/// </summary>
		/// <param name="SnifferId">Sniffer ID</param>
		/// <param name="Request">HTTP Request for sniffer page.</param>
		/// <param name="UserVariable">Name of user variable.</param>
		/// <param name="Privileges">Privileges required to view content.</param>
		/// <returns>Code to embed into page.</returns>
		public static string RegisterSniffer(string SnifferId, Waher.Networking.HTTP.HttpRequest Request,
			string UserVariable, params string[] Privileges)
		{
			return Gateway.AddWebSniffer(SnifferId, Request, sniffable, UserVariable, Privileges);
		}

		#endregion
	}
}

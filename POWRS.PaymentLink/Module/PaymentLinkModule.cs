using POWRS.PaymentLink.Authorization;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Waher.IoTGateway;
using Waher.Runtime.Cache;

namespace POWRS.PaymentLink.Module
{
    public class PaymentLinkModule : IConfigurableModule
    {
        private static Cache<string, List<string>> userNameOrganizations = new Cache<string, List<string>>(int.MaxValue, TimeSpan.FromSeconds(3600), TimeSpan.FromSeconds(3600));

        public Task<IConfigurablePage[]> GetConfigurablePages()
        {
            return Task.FromResult(new IConfigurablePage[]
            {
                new ConfigurablePage("PaymentLink", "/Payout/Settings.md", "Admin.Payments.Powrs.PaymentLink"),
                new ConfigurablePage("Onboardings", "/Payout/ShowAllOnboardings.md", "Admin.Onboarding.Modify"),
                new ConfigurablePage("Paylink Legal Identities", "/Payout/PaylinkLegalIdentities.md", "Admin.Notarius.Identities"),
                new ConfigurablePage("Organization Client Type", "/Payout/OrganizationClientType.md", "Admin.Notarius.Identities"),
            });
        }

        private readonly static PaylinkLogin paylinkLogin = new();
        private readonly static GenerateAgentApiKey generateAgentApiKey = new();
        private readonly static GetAgentApiKey getAgentApiKey = new();
        private readonly static RemoveApiKey removeApiKey = new();
        private readonly static SmartAdminLogin smartAdminLogin = new();
        public Task Start()
        {
            Gateway.HttpServer.Register(paylinkLogin);
            Gateway.HttpServer.Register(generateAgentApiKey);
            Gateway.HttpServer.Register(getAgentApiKey);
            Gateway.HttpServer.Register(removeApiKey);
            Gateway.HttpServer.Register(smartAdminLogin);
            return Task.CompletedTask;
        }

        public Task Stop()
        {
            Gateway.HttpServer.Unregister(paylinkLogin);
            Gateway.HttpServer.Unregister(generateAgentApiKey);
            Gateway.HttpServer.Unregister(getAgentApiKey);
            Gateway.HttpServer.Unregister(removeApiKey);
            Gateway.HttpServer.Unregister(smartAdminLogin);
            return Task.CompletedTask;
        }

        public static void SetUsernameOrganizations(string userName, List<string> organizations)
        {
            if (userNameOrganizations.ContainsKey(userName))
                userNameOrganizations[userName] = organizations;
            else
                userNameOrganizations.Add(userName, organizations);
        }
        public static List<string> GetUsernameOrganizations(string username)
        {
            if (userNameOrganizations.TryGetValue(username, out List<string> value))
                return value;
            else
                return new List<string>();
        }
    }
}

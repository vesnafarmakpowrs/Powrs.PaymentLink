using POWRS.PaymentLink.Authorization;
using System.Threading.Tasks;
using Waher.IoTGateway;

namespace POWRS.PaymentLink.Module
{
    public class PaymentLinkModule : IConfigurableModule
    {
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
        public Task Start()
        {
            Gateway.HttpServer.Register(paylinkLogin);
            Gateway.HttpServer.Register(generateAgentApiKey);
            Gateway.HttpServer.Register(getAgentApiKey);
            return Task.CompletedTask;
        }

        public Task Stop()
        {
            Gateway.HttpServer.Unregister(paylinkLogin);
            Gateway.HttpServer.Unregister(generateAgentApiKey);
            Gateway.HttpServer.Unregister(getAgentApiKey);
            return Task.CompletedTask;
        }
    }
}

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
                new ConfigurablePage("ShowAllOnboardings", "/Payout/ShowAllOnboardings.md", "Admin.Onboarding.Modify"),
                new ConfigurablePage("Paylink Legal Identities", "/Payout/PaylinkLegalIdentities.md", "Admin.Notarius.Identities"),
                new ConfigurablePage("Organization Client Type", "/Payout/OrganizationClientType.md", "dmin.Payments.Powrs.PaymentLink"),
            });
        }

        public Task Start()
        {
            return Task.CompletedTask;
        }

        public Task Stop()
        {
            return Task.CompletedTask;
        }
    }
}

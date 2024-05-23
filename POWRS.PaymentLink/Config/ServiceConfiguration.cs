using System.Threading.Tasks;
using Waher.Runtime.Settings;

namespace POWRS.PaymentLink
{
    public class ServiceConfiguration
    {
        private static ServiceConfiguration current = null;
        public static string Namespace => "POWRS.PaymentLink";

        public string PayDomain { get; private set; }
        public string ContactEmail { get; private set; }
        public string TemplateId { get; private set; }
        public string ApiKey { get; private set; }
        public string ApiKeySecret { get; private set; }
        public int PayoutPageTokenDuration { get; private set; }
        public string SMSTextLocalKey { get; private set; }
        public string AMLContactEmail { get; private set; }
        public string TermsAndConditionsUrl { get; private set; }

        public static async Task<ServiceConfiguration> GetCurrent()
        {
            if (current is null)
                current = await Load();

            return current;
        }

        public bool IsWellDefined
        {
            get
            {
                return
                    !string.IsNullOrWhiteSpace(this.PayDomain) &&
                    !string.IsNullOrWhiteSpace(this.ContactEmail) &&
                    !string.IsNullOrWhiteSpace(this.TemplateId) &&
                    !string.IsNullOrWhiteSpace(this.ApiKey) &&
                    !string.IsNullOrEmpty(this.ApiKeySecret) &&
                    !string.IsNullOrEmpty(this.SMSTextLocalKey) &&
                    !string.IsNullOrEmpty(this.AMLContactEmail) &&
                    !string.IsNullOrWhiteSpace(this.TermsAndConditionsUrl) &&
                     this.PayoutPageTokenDuration > 0;
            }
        }

        public void EnsureWellDefined()
        {
            if (!IsWellDefined)
            {
                throw new System.Exception("Service not configured properly");
            }
        }

        private static async Task<ServiceConfiguration> Load()
        {
            var Config = new ServiceConfiguration()
            {
                PayDomain = await RuntimeSettings.GetAsync(Namespace + ".PayDomain", string.Empty),
                ContactEmail = await RuntimeSettings.GetAsync(Namespace + ".ContactEmail", string.Empty),
                TemplateId = await RuntimeSettings.GetAsync(Namespace + ".TemplateId", string.Empty),
                ApiKey = await RuntimeSettings.GetAsync(Namespace + ".ApiKey", string.Empty),
                ApiKeySecret = await RuntimeSettings.GetAsync(Namespace + ".ApiKeySecret", string.Empty),
                SMSTextLocalKey = await RuntimeSettings.GetAsync(Namespace + ".SMSTextLocalKey", string.Empty),
                AMLContactEmail = await RuntimeSettings.GetAsync(Namespace + ".AMLContactEmail", string.Empty),
                TermsAndConditionsUrl = await RuntimeSettings.GetAsync(Namespace + ".TermsAndConditionsUrl", string.Empty),
            };

            var strTokenDuration = await RuntimeSettings.GetAsync(Namespace + ".PayoutPageTokenDuration", "5");

            if (int.TryParse(strTokenDuration, out int tokenDuration))
            {
                Config.PayoutPageTokenDuration = tokenDuration;
            }

            return Config;
        }

        public static void InvalidateCurrent()
        {
            current = null;
        }
    }
}

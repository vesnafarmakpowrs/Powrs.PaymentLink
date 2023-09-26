using System.Globalization;
using System.Linq;
using System.Resources;

namespace POWRS.PaymentLink
{
    public class PaylinkLocalization
    {
        private readonly ResourceManager resourceManager;
        private bool isSuported;
        public PaylinkLocalization(string language)
        {
            var lang = IsSupported(language) ? language : "en-Us";
            var cultureInfo = new CultureInfo(lang);
            resourceManager = new ResourceManager("POWRS.PaymentLink.Resx.PaylinkResources",
                                        typeof(PaylinkLocalization).Assembly);
            SetCulture(cultureInfo);
        }

        private bool IsSupported(string language)
        {
            if (string.IsNullOrEmpty(language))
            {
                return false;
            }

            var supportedLanguages = new string[]
            {
                "en-us", "sv-se"
            };

            return supportedLanguages.Contains(language.ToLower());
        }

        private void SetCulture(CultureInfo cultureInfo)
        {
            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;
        }

        public string GetResource(string key)
        {
            return resourceManager.GetString(key, CultureInfo.CurrentUICulture);
        }
    }
}

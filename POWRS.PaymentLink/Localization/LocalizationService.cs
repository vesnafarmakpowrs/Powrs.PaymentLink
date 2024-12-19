using System.Globalization;
using System.Resources;

namespace POWRS.PaymentLink.Localization
{
    public class LocalizationService
    {
        private readonly ResourceManager _resourceManager;
        private readonly CultureInfo _culture;
        public LocalizationService(CultureInfo culture, string ResourceFolder)
        {
            // Set the default culture (e.g., Serbian Latin) or use CultureInfo.CurrentCulture for dynamic setting
            //_culture = new CultureInfo("sr-Latn");
            //_culture = new CultureInfo("en-US");
            _culture = culture;
            _resourceManager = new ResourceManager($"POWRS.PaymentLink.Localization.Resources.{ResourceFolder}.Resource", typeof(LocalizationService).Assembly);
        }

        public string Get(string key)
        {
            return _resourceManager.GetString(key, _culture);
        }
    }
}

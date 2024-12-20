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

        public string GetFormat(string key, string param1)
        {
            return GetFormatted(key, param1);
        }

        public string GetFormat(string key, string param1, string param2)
        {
            return GetFormatted(key, param1, param2);
        }

        public string GetFormat(string key, string param1, string param2, string param3)
        {
            return GetFormatted(key, param1, param2, param3);
        }

        public string GetFormat(string key, string param1, string param2, string param3, string param4)
        {
            return GetFormatted(key, param1, param2, param3, param4);
        }

        public string GetFormat(string key, string param1, string param2, string param3, string param4, string param5)
        {
            return GetFormatted(key, param1, param2, param3, param4, param5);
        }

        private string GetFormatted(string key, params string[] args)
        {
            return string.Format(_resourceManager.GetString(key, _culture), args);
        }
    }
}

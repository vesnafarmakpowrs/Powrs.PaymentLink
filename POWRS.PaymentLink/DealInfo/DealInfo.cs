using System;
using Waher.Events;
using System.Collections.Generic;
using Waher.Persistence;
using System.Text;
using System.Linq;

namespace POWRS.PaymentLink.RS
{
    public class DealInfo
    {
        public static string GetHtmlDealInfo(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, object> IdentityProperties, string Html)
        {
            try
            {
                if (ContractParameters is null || IdentityProperties is null || string.IsNullOrEmpty(Html))
                {
                    throw new Exception("Parameters missing");
                }

                if (!ContractParameters.Any() || !IdentityProperties.Any())
                {
                    throw new Exception("Parameters missing");
                }

                StringBuilder stringBuilder = new(Html);
                ContractParameters.TryGetValue("ShortId", out object ShortId);

                string InvoiceNo = GetInvoiceNo(IdentityProperties, ShortId.ToString());
                stringBuilder = stringBuilder.Replace("{{InvoiceNo}}", InvoiceNo);
                stringBuilder = stringBuilder.Replace("{{YEAR}}", DateTime.Now.Year.ToString());

                ReplaceDictionaryValues(ContractParameters, stringBuilder, Html);
                ReplaceDictionaryValues(IdentityProperties, stringBuilder, Html);

                return stringBuilder.ToString();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }

        private static void ReplaceDictionaryValues(IDictionary<CaseInsensitiveString, object> KeyValuePairs, StringBuilder stringBuilder, string originalHtml)
        {
            foreach (var keyValuePair in KeyValuePairs)
            {
                var patternToReplace = "{{" + keyValuePair.Key + "}}";
                if (!originalHtml.Contains(patternToReplace) || keyValuePair.Value == null)
                {
                    continue;
                }

                var valueToReplacePattern = string.Empty;
                if (keyValuePair.Value is string stringValue)
                {
                    valueToReplacePattern = stringValue;
                }
                else if (keyValuePair.Value is CaseInsensitiveString caseInsensitiveStringValue)
                {
                    valueToReplacePattern = caseInsensitiveStringValue;
                }
                else if (decimal.TryParse(keyValuePair.Value?.ToString(), out decimal decimalValue))
                {
                    valueToReplacePattern = decimalValue.ToString("F");
                }
                else if (keyValuePair.Value is DateTime dateTimeValue)
                {
                    valueToReplacePattern = dateTimeValue.ToLocalTime().ToString("dd-MM-yyyy HH:mm");
                }

                if (!string.IsNullOrEmpty(valueToReplacePattern))
                {
                    stringBuilder.Replace(patternToReplace, valueToReplacePattern);
                }
            }
        }

        public static string GetInvoiceNo(IDictionary<CaseInsensitiveString, object> IdentityProperties, string ShortId)
        {
            if (IdentityProperties is null || string.IsNullOrEmpty(ShortId))
            {
                throw new Exception("Parameters missing");
            }

            IdentityProperties.TryGetValue("AgentName", out object AgentName);
            IdentityProperties.TryGetValue("ORGNAME", out object OrgName);

            string SellerName = !string.IsNullOrEmpty(OrgName?.ToString()) ? OrgName?.ToString() : AgentName?.ToString();
            string SellerId = SellerName.Substring(0, 3).ToUpperInvariant();
            string InvoiceNo = SellerId + ShortId.ToString();

            return InvoiceNo;
        }
    }
}

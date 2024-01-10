using System;
using Waher.Events;
using System.Collections.Generic;
using Waher.Persistence;
using System.Text;

namespace POWRS.PaymentLink
{
    public class DealInfo
    {
        public static string GetHtmlDealInfo(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, object> IdentityProperties, string Html)
        {
            if (ContractParameters is null || IdentityProperties is null || string.IsNullOrEmpty(Html))
            {
                throw new Exception("Parameters missing");
            }

            try
            {
                StringBuilder stringBuilder = new(Html);
                ContractParameters.TryGetValue("ShortId", out object ShortId);

                string InvoiceNo = GetInvoiceNo(IdentityProperties, ShortId.ToString());
                stringBuilder = stringBuilder.Replace("{{InvoiceNo}}", InvoiceNo);

                ReplaceDictionaryValues(ContractParameters, stringBuilder, Html);
                ReplaceDictionaryValues(IdentityProperties, stringBuilder, Html);

                return stringBuilder.ToString();
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return ex.Message;
            }
        }

        private static void ReplaceDictionaryValues(IDictionary<CaseInsensitiveString, object> KeyValuePairs, StringBuilder stringBuilder, string originalHtml)
        {
            foreach (var contractParameter in KeyValuePairs)
            {
                Log.Informational(contractParameter.Key + ": " + contractParameter.Value);

                var patternToReplace = "{{" + contractParameter.Key + "}}";
                if (!originalHtml.Contains(patternToReplace) || contractParameter.Value == null)
                {
                    continue;
                }

                var valueToReplaceKey = string.Empty;
                if (contractParameter.Value is string stringValue)
                {
                    valueToReplaceKey = stringValue;
                }
                else if (contractParameter.Value is CaseInsensitiveString caseInsensitiveStringValue)
                {
                    valueToReplaceKey = caseInsensitiveStringValue;
                }
                else if (contractParameter.Value is decimal decimalValue)
                {
                    valueToReplaceKey = decimalValue.ToString("F");
                }
                else if (contractParameter.Value is DateTime dateTimeValue)
                {
                    valueToReplaceKey = dateTimeValue.ToShortDateString();
                }

                if (!string.IsNullOrEmpty(valueToReplaceKey))
                {
                    stringBuilder.Replace(patternToReplace, valueToReplaceKey);
                }
            }
        }

        public static string GetInvoiceNo(IDictionary<CaseInsensitiveString, object> IdentityProperties, string ShortId)
        {
            if (IdentityProperties is null || ShortId is null)
            {
                throw new Exception("Parameters missing");
            }

            try
            {
                IdentityProperties.TryGetValue("AgentName", out object AgentName);
                IdentityProperties.TryGetValue("ORGNAME", out object OrgName);

                string SellerName = !String.IsNullOrEmpty(OrgName?.ToString()) ? OrgName?.ToString() : AgentName?.ToString();
                string SellerId = SellerName.Substring(0, 3).ToUpperInvariant();
                string InvoiceNo = SellerId + ShortId.ToString();

                return InvoiceNo;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return ex.Message;
            }
        }
    }
}

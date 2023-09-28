using System;
using System.Net.Mail;
using System.Net;
using System.Threading.Tasks;
using Waher.Events;
using System.Collections.Generic;
using Waher.Persistence;
using Waher.Content.Html.Elements;
using System.Reflection.Metadata;

namespace POWRS.PaymentLink
{
    public class DealInfo
    {
        public static string GetHtmlDealInfo(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties, string Html)
        {
            if (ContractParameters is null || IdentityProperties is null ||  Html is null) 
            {
                throw new Exception("Parameters missing");
            }

            try
            {
               IdentityProperties.TryGetValue("AgentName", out CaseInsensitiveString AgentName);
               IdentityProperties.TryGetValue("ORGNAME", out CaseInsensitiveString OrgName);

               string SellerName = !String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;
               string SellerId = SellerName.Substring(0, 3).ToUpperInvariant();

               ContractParameters.TryGetValue("ShortId", out object ShortId);
               string InvoiceNo = SellerId + ShortId.ToString() + ".pdf";

               ContractParameters.TryGetValue("Value", out object Value);
               ContractParameters.TryGetValue("EscrowFee", out object EscrowFee);
                if (!(Value is null) && !(EscrowFee is null))
                {
                    Decimal AmountToPay = Convert.ToDecimal(Value) + Convert.ToDecimal(EscrowFee);

                    Html = Html.Replace("{{escrow_fee}}", EscrowFee.ToString());
                    Html = Html.Replace("{{amount_paid}}", AmountToPay.ToString());
                }
               
               List<string> DateObjects = new List<string>{ "DeliveryDate", "Created"};
               foreach (var parameter in ContractParameters)
                {
                    if (DateObjects.Contains(parameter.Key))
                    {
                        ContractParameters.TryGetValue(parameter.Key, out object DateObj);
                        Html = Html.Replace(parameter.Key, Convert.ToDateTime(DateObj).ToShortDateString());
                    }
                    else {
                        Html = Html.Replace("{{" + parameter.Key + "}}", parameter.Value.ToString());
                    }
                }
             
               return Html;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                return  ex.Message;
            }
        }
    }
}

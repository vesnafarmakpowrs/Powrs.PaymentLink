using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using Waher.Events;

namespace POWRS.PaymentLink.Model
{
    public class InitiatePaymentRequest
    {
        public decimal Amount { get; set; }
        public string Currency { get; set; }
        public string TokenId { get; set; }
        public string OwnerJid { get; set; }
        public string Owner { get; set; }
        public string BuyEdalerTemplateId { get; set; }
        public string ContractID { get; set; }
        public string BankAccount { get; set; }
        public string ServiceProviderId { get; set; }
        public string ServiceProviderType { get; set; }
        public string RemoteEndpoint { get; set; }
        public string TabId { get; set; }
        public bool RequestFromMobilePhone { get; set; }
        public string CallBackUrl { get; set; }

        public void LogRequestValues()
        {
            Type type = this.GetType();
            PropertyInfo[] properties = type.GetProperties();

            foreach (var property in properties)
            {
                var value = property.GetValue(this);
                Log.Informational($"{property.Name}: " + value);
            }
        }
    }
}

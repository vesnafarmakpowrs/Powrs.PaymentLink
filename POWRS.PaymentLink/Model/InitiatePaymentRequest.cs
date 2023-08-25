using POWRS.PaymentLink.Attributes;
using System;
using System.Reflection;
using System.Text;
using Waher.Events;

namespace POWRS.PaymentLink.Model
{
    public class InitiatePaymentRequest
    {
        /// <summary>
        /// Amount which should be paid.
        /// </summary>
        [Mandatory]
        public decimal Amount { get; set; }

        /// <summary>
        /// Currency used for payment
        /// </summary>
        [Mandatory]
        public string Currency { get; set; }

        /// <summary>
        /// Id of the token which is created from contract.
        /// </summary>
        [Mandatory]
        public string TokenId { get; set; }

        /// <summary>
        /// Owner Jid of the token.
        /// </summary>
        [Mandatory]
        public string OwnerJid { get; set; }

        /// <summary>
        /// TemplateId used for creating buyEdaler contract
        /// </summary>
        [Mandatory]
        public string BuyEdalerTemplateId { get; set; }

        /// <summary>
        /// ContractId
        /// </summary>
        [Mandatory]
        public string ContractId { get; set; }

        /// <summary>
        /// Buyer bank account used for buying edaler.
        /// </summary>
        [Mandatory]
        public string BankAccount { get; set; }

        /// <summary>
        /// Id of service provider used to buy edaler.
        /// </summary>
        [Mandatory]
        public string ServiceProviderId { get; set; }

        /// <summary>
        /// Type of service provider used to buy edaler.
        /// </summary>
        [Mandatory]
        public string ServiceProviderType { get; set; }

        /// <summary>
        /// IP of request, will be used for spam protection in the future.
        /// </summary>
        [Mandatory]
        public string RemoteEndpoint { get; set; }

        /// <summary>
        /// Id of client socket connection. Mandatory if client wants UI updates.
        /// </summary>
        [Mandatory]
        public string TabId { get; set; }

        /// <summary>
        /// Personal number of initiator for buying eDaler.
        /// </summary>
        [Mandatory]
        public string PersonalNumber { get; set; }

        /// <summary>
        /// If payment link is initiated from mobile phone.
        /// </summary>
        public bool RequestFromMobilePhone { get; set; }

        /// <summary>
        /// Url to send a response if payment is completed.
        /// </summary>
        public string CallBackUrl { get; set; }

        public string Validate()
        {
            StringBuilder sb = new StringBuilder();
            Type type = this.GetType();
            PropertyInfo[] properties = type.GetProperties();

            foreach (var property in properties)
            {
                var propertyValue = property.GetValue(this);
                var mandatoryAttribute = property.GetCustomAttribute(typeof(MandatoryAttribute));

                if (mandatoryAttribute != null)
                {
                    continue;
                }

                if (property.PropertyType == typeof(string) && string.IsNullOrEmpty(propertyValue?.ToString()))
                {
                    sb.AppendLine($"Property {property.Name} could not be empty");
                }
                else if (property.PropertyType == typeof(decimal) && (decimal)propertyValue >= 0)
                {

                    sb.AppendLine($"Property {property.Name} could not be negative value");
                }

                Log.Informational($"{property.Name}: " + propertyValue);
            }

            return sb.ToString();
        }
    }
}

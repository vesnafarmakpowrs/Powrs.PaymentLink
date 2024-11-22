using System;
using System.Threading.Tasks;
using System.Xml;
using Waher.Content;
using Waher.IoTGateway;

namespace POWRS.PaymentLink
{
    public class TimeZone
    {
        public static async Task NotifyTimeZoneDifference(int timeZoneOffset, string stateCity, string tokenId)
        {
            var xmlNote = $"<BuyerTimeZoneDifference xmlns='https://{Gateway.Domain}/Downloads/EscrowPaylinkRS.xsd' timeZoneOffset='{timeZoneOffset}' state='{stateCity}' />";
            
            XmlDocument xmlDocument = new();
            xmlDocument.LoadXml(xmlNote);

            await InternetContent.PostAsync(
               new Uri("https://" + Gateway.Domain + ":8088/AddNote/" + tokenId),
               xmlDocument,
               Gateway.Certificate);
        }
    }
}

using System;
using System.Threading.Tasks;
using System.Xml;
using Waher.Content;
using Waher.IoTGateway;

namespace POWRS.PaymentLink
{
    public class TimeZone
    {
        private static double GetTimeDifferenceInMinutes(long timestamp)
        {
            DateTime inputDateTime = DateTimeOffset.FromUnixTimeMilliseconds(timestamp).DateTime;
            double minutesDifference = (inputDateTime - DateTime.Now).TotalMinutes;
            return Math.Floor(minutesDifference);
        }

        public static async Task NotifyTimeZoneDifference(long timestamp, string stateCity, string tokenId)
        {
            var differenceInMinutes = GetTimeDifferenceInMinutes(timestamp);
            var xmlNote = $"<BuyerTimeZoneDifference xmlns={Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd")} differenceInMinutes={differenceInMinutes} state={stateCity} />";
            
            XmlDocument xmlDocument = new();
            xmlDocument.LoadXml(xmlNote);

            await InternetContent.PostAsync(
               new Uri("https://" + Gateway.Domain + ":8088/AddNote/" + tokenId),
               xmlDocument,
               Gateway.Certificate);
        }
    }
}

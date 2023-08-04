using System.Threading.Tasks;
using Waher.Events;

namespace LegalLab.Models.Network.Events
{
	/// <summary>
	/// Event Sink, that outputs items to a ListView control.
	/// From the IoTGateway project, with permission.
	/// </summary>
	public class PaymentCompletedEventSink : EventSink
	{
		public static string PaymentCompletedEventId = "PaymentCompleted";
        public PaymentCompletedEventSink()
			: base(string.Empty)
		{
			
		}

		public override Task Queue(Event Event)
		{
			if (Event.EventId == PaymentCompletedEventId)
			  Log.Informational("received event sink Event.EventId:" + Event.EventId + "Event.Message: " + Event.Message + Event.Object);
			return Task.CompletedTask;
		}

	}
}

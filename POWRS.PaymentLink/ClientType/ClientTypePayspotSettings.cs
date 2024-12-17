using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.ClientType
{
    [CollectionName(nameof(ClientTypePayspotSettings) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("ObjectId")]
    [Index("Type")]
    public class ClientTypePayspotSettings
    {
        private string objectId;
        private Enums.ClientType type;
        private string cardTerminalId = "";
        private string iPSTerminalId = "";
        private decimal iPSFee = 0;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public Enums.ClientType Type { get => type; set => type = value; }
        public string CardTerminalId { get => cardTerminalId; set => cardTerminalId = value; }
        public string IPSTerminalId { get => iPSTerminalId; set => iPSTerminalId = value; }
        public decimal IPSFee { get => iPSFee; set => iPSFee = value; }
    }
}

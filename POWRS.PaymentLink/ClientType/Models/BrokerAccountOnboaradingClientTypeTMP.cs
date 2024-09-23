using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.ClientType.Models
{
    [CollectionName(nameof(BrokerAccountOnboaradingClientTypeTMP) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class BrokerAccountOnboaradingClientTypeTMP
    {
        private string objectId;
        private string userName;
        private Enums.ClientType orgClientType;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string UserName { get => userName; set => userName = value; }
        public Enums.ClientType OrgClientType { get => orgClientType; set => orgClientType = value; }
    }
}

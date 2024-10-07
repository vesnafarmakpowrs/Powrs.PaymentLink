using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Authorization
{
    [CollectionName(nameof(AgentApiKey) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("ApiKey")]
    [Index("UserName")]
    public class AgentApiKey
    {
        private string objectId;
        private string apiKey;
        private string signature;
        private string userName;
        private bool isBlocked;
        private bool canBeOverriden;
        private DateTime created;
        private DateTime lastLogin;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string ApiKey { get => apiKey; set => apiKey = value; }
        public string Signature { get => signature; set => signature = value; }
        public string UserName { get => userName; set => userName = value; }
        public bool IsBlocked { get => isBlocked; set => isBlocked = value; }
        public bool CanBeOverriden { get => canBeOverriden; set => canBeOverriden = value; }
        public DateTime Created { get => created; set => created = value; }
        public DateTime LastLogin { get => lastLogin; set => lastLogin = value; }
    }
}

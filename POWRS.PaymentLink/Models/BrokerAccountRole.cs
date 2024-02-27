using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Models
{
    [CollectionName(nameof(BrokerAccountRole) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    [Index("OrgName")]
    public class BrokerAccountRole
    {
        private string objectId;
        private string userName;
        private AccountRole role;
        private string creatorUserName;
        private string orgName;
        private string parentOrgName;

        public string ObjectId { get => objectId; set => objectId = value; }
        public string UserName { get => userName; set => userName = value; }
        public AccountRole Role { get => role; set => role = value; }
        public string CreatorUserName { get => creatorUserName; set => creatorUserName = value; }
        public string OrgName { get => orgName; set => orgName = value; }
        public string ParentOrgName { get => parentOrgName; set => parentOrgName = value; }
    }
}

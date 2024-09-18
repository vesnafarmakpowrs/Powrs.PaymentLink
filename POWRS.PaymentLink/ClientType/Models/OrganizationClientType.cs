using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.ClientType.Models
{
    [CollectionName(nameof(OrganizationClientType) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("OrgName")]
    public class OrganizationClientType
    {
        private string objectId;
        private string organizationName;
        private Enums.ClientType orgClientType;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string OrganizationName { get => organizationName; set => organizationName = value; }
        public Enums.ClientType OrgClientType { get => orgClientType; set => orgClientType = value; }
    }
}

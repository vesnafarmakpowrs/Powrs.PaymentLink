using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Models
{
    [CollectionName(nameof(NewUserTMP) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("ObjectId")]

    public class NewUserTMP
    {
        private string objectId;
        private string parentOrgName;
        private string newOrgName;
        private ClientType.Enums.ClientType newOrgClientType;
        private AccountRole newUserRole;

        public string ObjectId { get => objectId; set => objectId = value; }
        public string ParentOrgName { get => parentOrgName; set => parentOrgName = value; }
        public string NewOrgName { get => newOrgName; set => newOrgName = value; }
        public ClientType.Enums.ClientType NewOrgClientType { get => newOrgClientType; set => newOrgClientType = value; }
        public AccountRole NewUserRole { get => newUserRole; set => newUserRole = value; }
      
    }
}

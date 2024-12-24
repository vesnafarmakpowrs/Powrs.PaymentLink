using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Models
{
    [CollectionName(nameof(NewUserRegistrationDetail) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("ObjectId")]

    public class NewUserRegistrationDetail
    {
        private string objectId;
        private string parentOrgName;
        private string newOrgName;
        private ClientType.Enums.ClientType newOrgClientType;
        private AccountRole newUserRole;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string ParentOrgName { get => parentOrgName; set => parentOrgName = value; }
        public string NewOrgName { get => newOrgName; set => newOrgName = value; }
        public ClientType.Enums.ClientType NewOrgClientType { get => newOrgClientType; set => newOrgClientType = value; }
        public AccountRole NewUserRole { get => newUserRole; set => newUserRole = value; }
      
    }
}

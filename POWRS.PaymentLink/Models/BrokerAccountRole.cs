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
        private string parentAccount;
        private AccountRole role;
        private string orgName;

        public string ObjectId
        {
            get => objectId; 
            set => objectId = value;
        }

        public string UserName
        {
            get => userName; 
            set => userName = value;
        }

        public string ParentAccount
        {
            get => parentAccount; 
            set => parentAccount = value;
        }

        public AccountRole Role
        {
            get => role;
            set => role = value;
        }

        public string OrgName
        {
            get => orgName; 
            set => orgName = value;
        }
    }
}

using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.FeeCalculator.Data
{
    [CollectionName(nameof(FeeCalculator) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("OrganizationNumber")]
    public class FeeCalculator
    {
        public FeeCalculator()
        {
            userName = "";
            companyName = "";
            organizationNumber = "";
            contactPerson = "";
            contactEmail = "";
        }

        private string objectId;
        private string userName;

        private string companyName;
        private string organizationNumber;
        private string contactPerson;
        private string contactEmail;

        private Current currentData;
        private Card cardData;
        private A2A a2aData;
        private HoldingService holdingServiceData;

        private decimal totalSaved;
        private decimal kickBack_Discount;

        [ObjectId]
        public string ObjectId { get => this.objectId; set => this.objectId = value; }
        public string UserName { get => userName; set => userName = value; }
        public string CompanyName { get => companyName; set => companyName = value; }
        public string OrganizationNumber { get => organizationNumber; set => organizationNumber = value; }
        public string ContactPerson { get => contactPerson; set => contactPerson = value; }
        public string ContactEmail { get => contactEmail; set => contactEmail = value; }
        public Current CurrentData { get => currentData; set => currentData = value; }
        public Card CardData { get => cardData; set => cardData = value; }
        public A2A A2AData { get => a2aData; set => a2aData = value; }
        public HoldingService HoldingServiceData { get => holdingServiceData; set => holdingServiceData = value; }
        public decimal TotalSaved { get => totalSaved; set => totalSaved = value; }
        public decimal KickBack_Discount { get => kickBack_Discount; set => kickBack_Discount = value; }
    }
}

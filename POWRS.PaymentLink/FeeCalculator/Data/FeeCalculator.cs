﻿using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.FeeCalculator.Data
{
    [CollectionName(nameof(FeeCalculator) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("OrganizationNumber")]
    [Index("CreatorUserName")]
    [Index("EditorUserName")]
    [Index("CreatorUserName", "EditorUserName")]
    public class FeeCalculator
    {
        public FeeCalculator()
        {
            creatorUserName = "";
            created = DateTime.Now;
            editorUserName = "";
            edited = DateTime.Now;
            companyName = "";
            organizationNumber = "";
            contactPerson = "";
            contactEmail = "";
            currency = "";
        }

        private string objectId;
        private string creatorUserName;
        private DateTime created;
        private string editorUserName;
        private DateTime edited;

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
        private string currency;
        private string note;

        [ObjectId]
        public string ObjectId { get => this.objectId; set => this.objectId = value; }
        public string CreatorUserName { get => creatorUserName; set => creatorUserName = value; }
        public DateTime Created { get => created; set => created = value; }
        public string EditorUserName { get => editorUserName; set => editorUserName = value; }
        public DateTime Edited { get => edited; set => edited = value; }
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
        public string Currency { get => currency; set => currency = value; }
        public string Note { get => note; set => note = value; }
    }
}

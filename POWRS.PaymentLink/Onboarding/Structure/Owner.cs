﻿using POWRS.PaymentLink.Onboarding.Enums;
using System;

namespace POWRS.PaymentLink.Onboarding
{
    public class Owner
    {
        public Owner()
        {
            fullName = "";
            personalNumber = "";
            placeOfBirth = "";
            addressOfResidence = "";
            cityOfResidence = "";
            role = "";
            documentNumber = "";
            issuerName = "";
            documentIssuancePlace = "";
            citizenship = "";
            dateOfBirthStr = "";
            issueDateStr = "";
        }

        private string fullName;
        private string personalNumber;
        private DateTime? dateOfBirth;
        private string placeOfBirth;
        private string addressOfResidence;
        private string cityOfResidence;
        private bool isPoliticallyExposedPerson;
        private decimal owningPercentage;
        private string role;
        private DocumentType documentType;
        private string documentNumber;
        private DateTime? issueDate;
        private string issuerName;
        private string documentIssuancePlace;
        private string citizenship;

        private string dateOfBirthStr;
        private string issueDateStr;

        public string FullName
        {
            get { return fullName; }
            set { fullName = value; }
        }
        public string PersonalNumber
        {
            get { return personalNumber; }
            set { personalNumber = value; }
        }
        public DateTime? DateOfBirth
        {
            get { return dateOfBirth; }
            set
            {
                dateOfBirth = value;
                dateOfBirthStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
            }
        }
        public string PlaceOfBirth
        {
            get { return placeOfBirth; }
            set { placeOfBirth = value; }
        }
        public string AddressOfResidence
        {
            get { return addressOfResidence; }
            set { addressOfResidence = value; }
        }
        public bool IsPoliticallyExposedPerson
        {
            get { return isPoliticallyExposedPerson; }
            set { isPoliticallyExposedPerson = value; }
        }
        public DocumentType DocumentType
        {
            get { return documentType; }
            set { documentType = value; }
        }
        public string DocumentNumber
        {
            get { return documentNumber; }
            set { documentNumber = value; }
        }
        public DateTime? IssueDate
        {
            get { return issueDate; }
            set
            {
                issueDate = value;
                issueDateStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
            }
        }
        public string IssuerName
        {
            get { return issuerName; }
            set { issuerName = value; }
        }
        public string DocumentIssuancePlace
        {
            get { return documentIssuancePlace; }
            set { documentIssuancePlace = value; }
        }
        public string Citizenship
        {
            get { return citizenship; }
            set { citizenship = value; }
        }
        public decimal OwningPercentage
        {
            get { return owningPercentage; }
            set { owningPercentage = value; }
        }
        public string Role
        {
            get { return role; }
            set { role = value; }
        }
        public string DateOfBirthStr { get => dateOfBirthStr; set => dateOfBirthStr = value; }
        public string IssueDateStr { get => issueDateStr; set => issueDateStr = value; }
        public string CityOfResidence { get => cityOfResidence; set => cityOfResidence = value; }
    }
}

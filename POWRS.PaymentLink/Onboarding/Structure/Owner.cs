using POWRS.PaymentLink.Onboarding.Enums;
using System;

namespace POWRS.PaymentLink.Onboarding
{
    public class Owner
    {
        private string fullName;
        private string personalNumber;
        private DateTime? dateOfBirth;
        private string placeOfBirth;
        private string addressAndPlaceOfResidence;
        private bool isPoliticallyExposedPerson;
        private string statementOfOfficialDocument;
        private decimal owningPercentage;
        private string role;
        private DocumentType documentType;
        private string documentNumber;
        private DateTime? issueDate;
        private string issuerName;
        private string documentIssuancePlace;
        private string citizenship;
        private string idCard;

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
            set { dateOfBirth = value; }
        }

        public string PlaceOfBirth
        {
            get { return placeOfBirth; }
            set { placeOfBirth = value; }
        }
        public string AddressAndPlaceOfResidence
        {
            get { return addressAndPlaceOfResidence; }
            set { addressAndPlaceOfResidence = value; }
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
            set { issueDate = value; }
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

        public string StatementOfOfficialDocument
        {
            get { return statementOfOfficialDocument; }
            set { statementOfOfficialDocument = value; }
        }

        public string IdCard
        {
            get { return idCard; }
            set { idCard = value; }
        }
    }
}

using POWRS.PaymentLink.Onboarding.Enums;
using System;

namespace POWRS.PaymentLink.Onboarding.Structure
{
    public class Owner
    {
        private string fullName;
        private string personalNumber;
        private DateTime? dateOfBirth;
        private string placeOfBirth;
        private bool officialOfRepublicOfSerbia;
        private DocumentType documentType;
        private string documentNumber;
        private DateTime? issueDate;
        private string issuerName;
        private string citizenship;
        private int? owningPercentage;
        private string role;

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

        public bool OfficialOfRepublicOfSerbia
        {
            get { return officialOfRepublicOfSerbia; }
            set { officialOfRepublicOfSerbia = value; }
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

        public string Citizenship
        {
            get { return citizenship; }
            set { citizenship = value; }
        }

        public int? OwningPercentage
        {
            get { return owningPercentage; }
            set { owningPercentage = value; }
        }

        public string Role
        {
            get { return role; }
            set { role = value; }
        }
    }
}

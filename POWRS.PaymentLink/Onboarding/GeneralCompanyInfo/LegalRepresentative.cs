using POWRS.PaymentLink.Onboarding.Enums;
using System;

namespace POWRS.PaymentLink.Onboarding
{
    public class LegalRepresentative
    {
        public LegalRepresentative()
        {
            fullName = "";
            personalNumber = "";
            placeOfBirth = "";
            addressOfResidence = "";
            cityOfResidence = "";
            statementOfOfficialDocument = "";
            documentNumber = "";
            placeOfIssue = "";
            issuerName = "";
            idCard = "";
            dateOfBirthStr = "";
            dateOfIssueStr = "";
        }

        private string fullName;
        private string personalNumber;
        private DateTime? dateOfBirth;
        private string placeOfBirth;
        private string addressOfResidence;
        private string cityOfResidence;
        private bool isPoliticallyExposedPerson;
        private string statementOfOfficialDocument;
        private DocumentType documentType;
        private string documentNumber;
        private DateTime? dateOfIssue;
        private string placeOfIssue;
        private string issuerName;
        private string idCard;

        private string dateOfBirthStr;
        private string dateOfIssueStr;

        public string FullName { get => fullName; set => fullName = value; }
        public DateTime? DateOfBirth
        {
            get => dateOfBirth;
            set
            {
                dateOfBirth = value;
                dateOfBirthStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
            }
        }
        public DocumentType DocumentType { get => documentType; set => documentType = value; }
        public string DocumentNumber { get => documentNumber; set => documentNumber = value; }
        public DateTime? DateOfIssue
        {
            get => dateOfIssue;
            set
            {
                dateOfIssue = value;
                dateOfIssueStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
            }
        }
        public string PlaceOfIssue { get => placeOfIssue; set => placeOfIssue = value; }
        public string StatementOfOfficialDocument { get => statementOfOfficialDocument; set => statementOfOfficialDocument = value; }
        public string IdCard { get => idCard; set => idCard = value; }
        public bool IsPoliticallyExposedPerson { get => isPoliticallyExposedPerson; set => isPoliticallyExposedPerson = value; }
        public string DateOfBirthStr { get => dateOfBirthStr; set => dateOfBirthStr = value; }
        public string DateOfIssueStr { get => dateOfIssueStr; set => dateOfIssueStr = value; }
        public string IssuerName { get => issuerName; set => issuerName = value; }
        public string PlaceOfBirth { get => placeOfBirth; set => placeOfBirth = value; }
        public string AddressOfResidence { get => addressOfResidence; set => addressOfResidence = value; }
        public string CityOfResidence { get => cityOfResidence; set => cityOfResidence = value; }
        public string PersonalNumber { get => personalNumber; set => personalNumber = value; }
    }
}

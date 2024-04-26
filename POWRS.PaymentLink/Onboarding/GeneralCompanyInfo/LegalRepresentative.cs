using POWRS.PaymentLink.Onboarding.Enums;
using System;

namespace POWRS.PaymentLink.Onboarding
{
    public class LegalRepresentative
    {
        private string fullName;
        private DateTime? dateOfBirth;
        private bool isPoliticallyExposedPerson;
        private string statementOfOfficialDocument;
        private DocumentType documentType;
        private string documentNumber;
        private DateTime? dateOfIssue;
        private string placeOfIssue;
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
                DateOfBirthStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
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
                DateOfIssueStr = value != null ? Convert.ToDateTime(value).ToString("dd/MM/yyyy") : "";
            }
        }
        public string PlaceOfIssue { get => placeOfIssue; set => placeOfIssue = value; }
        public string StatementOfOfficialDocument { get => statementOfOfficialDocument; set => statementOfOfficialDocument = value; }
        public string IdCard { get => idCard; set => idCard = value; }
        public bool IsPoliticallyExposedPerson { get => isPoliticallyExposedPerson; set => isPoliticallyExposedPerson = value; }
        public string DateOfBirthStr { get => dateOfBirthStr; set => dateOfBirthStr = value; }
        public string DateOfIssueStr { get => dateOfIssueStr; set => dateOfIssueStr = value; }
    }
}

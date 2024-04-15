using POWRS.PaymentLink.Onboarding.Enums;

namespace POWRS.PaymentLink.Onboarding
{
    public class LegalRepresentative
    {
        private string fullName;
        private string dateOfBirth;
        private DocumentType documentType;
        private string documentNumber;
        private string dateOfIssue;
        private string placeOfIssue;

        public string FullName { get => fullName; set => fullName = value; }
        public string DateOfBirth { get => dateOfBirth; set => dateOfBirth = value; }
        public DocumentType DocumentType { get => documentType; set => documentType = value; }
        public string DocumentNumber { get => documentNumber; set => documentNumber = value; }
        public string DateOfIssue { get => dateOfIssue; set => dateOfIssue = value; }
        public string PlaceOfIssue { get => placeOfIssue; set => placeOfIssue = value; }
    }
}

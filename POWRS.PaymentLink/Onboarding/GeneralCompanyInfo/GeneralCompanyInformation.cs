using POWRS.PaymentLink.Onboarding.Enums;
using System;
using System.Linq;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(GeneralCompanyInformation) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class GeneralCompanyInformation : BaseOnboardingModel<GeneralCompanyInformation>
    {
        public GeneralCompanyInformation()
        {
            fullName = "";
            shortName = "";
            companyAddress = "";
            companyCity = "";
            organizationNumber = "";
            taxNumber = "";
            activityNumber = "";
            otherCompanyActivities = "";

            bankName = "";
            bankAccountNumber = "";

            companyWebsite = "";
            companyWebshop = "";
            legalRepresentatives = new LegalRepresentative[0];
            created = DateTime.Now;
            canEdit = true;
        }
        public GeneralCompanyInformation(string userName) : base(userName) { }

        private string fullName;
        private string shortName;
        private string companyAddress;
        private string companyCity;
        private string organizationNumber;
        private string taxNumber;
        private string activityNumber;
        private string otherCompanyActivities;
        private bool stampUsage;
        private string bankName;
        private string bankAccountNumber;
        private bool taxLiability;
        private OnboardingPurpose onboardingPurpose;
        private PlatformUsage platformUsage;
        private string companyWebsite;
        private string companyWebshop;
        private LegalRepresentative[] legalRepresentatives;
        private DateTime created;
        private bool canEdit;

        public string FullName { get => fullName; set => fullName = value; }
        public string ShortName { get => shortName; set => shortName = value; }
        public string CompanyAddress { get => companyAddress; set => companyAddress = value; }
        public string CompanyCity { get => companyCity; set => companyCity = value; }
        public string OrganizationNumber { get => organizationNumber; set => organizationNumber = value; }
        public string TaxNumber { get => taxNumber; set => taxNumber = value; }
        public string ActivityNumber { get => activityNumber; set => activityNumber = value; }
        public string OtherCompanyActivities { get => otherCompanyActivities; set => otherCompanyActivities = value; }
        public string BankName { get => bankName; set => bankName = value; }
        public string BankAccountNumber { get => bankAccountNumber; set => bankAccountNumber = value; }
        public bool StampUsage { get => stampUsage; set => stampUsage = value; }
        public bool TaxLiability { get => taxLiability; set => taxLiability = value; }
        public OnboardingPurpose OnboardingPurpose { get => onboardingPurpose; set => onboardingPurpose = value; }
        public PlatformUsage PlatformUsage { get => platformUsage; set => platformUsage = value; }
        public string CompanyWebsite { get => companyWebsite; set => companyWebsite = value; }
        public string CompanyWebshop { get => companyWebshop; set => companyWebshop = value; }
        public LegalRepresentative[] LegalRepresentatives { get => legalRepresentatives; set => legalRepresentatives = value; }
        public DateTime Created { get => created; set => created = value; }
        public bool CanEdit { get => canEdit; set => canEdit = value; }

        public override bool IsCompleted()
        {
            bool informationsCompleted = !string.IsNullOrWhiteSpace(FullName) &&
                !string.IsNullOrWhiteSpace(ShortName) &&
                !string.IsNullOrWhiteSpace(CompanyAddress) &&
                !string.IsNullOrWhiteSpace(CompanyCity) &&
                !string.IsNullOrWhiteSpace(OrganizationNumber) &&
                !string.IsNullOrWhiteSpace(TaxNumber) &&
                !string.IsNullOrWhiteSpace(ActivityNumber) &&
                !string.IsNullOrWhiteSpace(BankName) &&
                !string.IsNullOrWhiteSpace(BankAccountNumber) &&
                (LegalRepresentatives != null && legalRepresentatives.Length > 0);

            if (!informationsCompleted)
            {
                return informationsCompleted;
            }

            bool legalRepresentativesIncompleted = LegalRepresentatives.Any(m =>
             string.IsNullOrWhiteSpace(m.FullName) ||
             m.DateOfBirth == null ||
             string.IsNullOrWhiteSpace(m.DocumentNumber) ||
             m.DateOfIssue == null ||
             string.IsNullOrWhiteSpace(m.PlaceOfIssue) ||
             string.IsNullOrWhiteSpace(m.StatementOfOfficialDocument) ||
             string.IsNullOrWhiteSpace(m.IdCard) ||
             string.IsNullOrWhiteSpace(m.IssuerName) ||
             string.IsNullOrWhiteSpace(m.PlaceOfBirth) ||
             string.IsNullOrWhiteSpace(m.AddressOfResidence) ||
             string.IsNullOrWhiteSpace(m.CityOfResidence) ||
             string.IsNullOrWhiteSpace(m.PersonalNumber)
             );

            return !legalRepresentativesIncompleted;
        }
    }
}

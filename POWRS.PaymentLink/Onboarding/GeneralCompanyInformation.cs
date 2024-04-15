using POWRS.PaymentLink.Onboarding.Enums;
using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(GeneralCompanyInformation) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class GeneralCompanyInformation : BaseOnboardingModel<GeneralCompanyInformation>
    {
        public GeneralCompanyInformation() { }
        public GeneralCompanyInformation(string userName) : base(userName) { }

        private string fullName;
        private string shortName;
        private string companyAddress;
        private string companyCity;
        private string organizationNumber;
        private string taxNumber;
        private string activityNumber;
        private string otherCompanyActivities;
        private string bankName;
        private string bankAccountNumber;
        private StampUsage stampUsage;
        private TaxLiability taxLiability;
        private OnboardingPurpose onboardingPurpose;
        private PlatformUsage platformUsage;
        private string companyWebsite;
        private string companyWebshop;
        private LegalRepresentative[] legalRepresentatives;

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
        public StampUsage StampUsage { get => stampUsage; set => stampUsage = value; }
        public TaxLiability TaxLiability { get => taxLiability; set => taxLiability = value; }
        public OnboardingPurpose OnboardingPurpose { get => onboardingPurpose; set => onboardingPurpose = value; }
        public PlatformUsage PlatformUsage { get => platformUsage; set => platformUsage = value; }
        public string CompanyWebsite { get => companyWebsite; set => companyWebsite = value; }
        public string CompanyWebshop { get => companyWebshop; set => companyWebshop = value; }
        public LegalRepresentative[] LegalRepresentatives { get => legalRepresentatives; set => legalRepresentatives = value; }
    }
}

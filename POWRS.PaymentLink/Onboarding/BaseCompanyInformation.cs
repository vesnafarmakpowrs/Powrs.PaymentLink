using POWRS.PaymentLink.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(BaseCompanyInformation) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class BaseCompanyInformation : BaseOnboarding<BaseCompanyInformation>
    {
        private string objectId;
        private string userName;
        private string applicantName;
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
        private string companyBussinesArea;
        private string companyWebsite;
        private string companyWebshop;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string ApplicantName { get => applicantName; set => applicantName = value; }
        public string UserName { get => userName; set => userName = value; }
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
        public string CompanyBussinesArea { get => companyBussinesArea; set => companyBussinesArea = value; }
        public string CompanyWebsite { get => companyWebsite; set => companyWebsite = value; }
        public string CompanyWebshop { get => companyWebshop; set => companyWebshop = value; }
    }
}

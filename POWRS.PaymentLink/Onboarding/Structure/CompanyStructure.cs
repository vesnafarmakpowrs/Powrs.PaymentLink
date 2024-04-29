using System;
using Waher.Persistence.Attributes;
using POWRS.PaymentLink.Onboarding.Enums;
using System.Linq;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(CompanyStructure) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class CompanyStructure : BaseOnboardingModel<CompanyStructure>
    {
        public CompanyStructure() { }
        public CompanyStructure(string userName) : base(userName) { }

        private string[] countriesOfBussines;
        private string nameOfTheForeignExchangeAndIDNumber;
        private int percentageOfForeignUsers;
        private bool offShoreFoundationInOwnerStructure;
        private OwnerStructure ownerStructure;
        private Owner[] owners;

        public string[] CountriesOfBusiness
        {
            get { return countriesOfBussines; }
            set { countriesOfBussines = value; }
        }
        public string NameOfTheForeignExchangeAndIDNumber
        {
            get { return nameOfTheForeignExchangeAndIDNumber; }
            set { nameOfTheForeignExchangeAndIDNumber = value; }
        }
        public int PercentageOfForeignUsers
        {
            get { return percentageOfForeignUsers; }
            set { percentageOfForeignUsers = value; }
        }
        public bool OffShoreFoundationInOwnerStructure
        {
            get { return offShoreFoundationInOwnerStructure; }
            set { offShoreFoundationInOwnerStructure = value; }
        }
        public OwnerStructure OwnerStructure
        {
            get { return ownerStructure; }
            set { ownerStructure = value; }
        }
        public Owner[] Owners
        {
            get { return owners; }
            set { owners = value; }
        }

        public override bool IsCompleted()
        {
            bool isStructureValid = CountriesOfBusiness != null && CountriesOfBusiness.Length > 0 &&
                PercentageOfForeignUsers < 0 &&
                Owners != null && Owners.Length > 0;

            if (!isStructureValid)
            {
                return isStructureValid;
            }

            bool incompleteOwnerFormsExists = Owners.Any(m => string.IsNullOrWhiteSpace(m.FullName) ||
                string.IsNullOrWhiteSpace(m.PersonalNumber) ||
                (m.DateOfBirth == null || m.DateOfBirth == DateTime.MinValue) ||
                string.IsNullOrWhiteSpace(m.PlaceOfBirth) ||
                string.IsNullOrWhiteSpace(m.AddressAndPlaceOfResidence) ||
                (m.IsPoliticallyExposedPerson && string.IsNullOrWhiteSpace(m.StatementOfOfficialDocument)) ||
                m.OwningPercentage <= 0 ||
                string.IsNullOrWhiteSpace(m.Role) ||
                string.IsNullOrWhiteSpace(m.DocumentNumber) ||
                (m.IssueDate == null && m.IssueDate == DateTime.MinValue) ||
                string.IsNullOrWhiteSpace(m.IssuerName) ||
                string.IsNullOrWhiteSpace(m.DocumentIssuancePlace) ||
                string.IsNullOrWhiteSpace(m.Citizenship) ||
                string.IsNullOrWhiteSpace(m.IdCard));

            return !incompleteOwnerFormsExists;
        }
    }
}

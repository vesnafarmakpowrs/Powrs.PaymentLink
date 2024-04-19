using System;
using Waher.Persistence.Attributes;
using POWRS.PaymentLink.Onboarding.Enums;
using System.Linq;

namespace POWRS.PaymentLink.Onboarding.Structure
{
    [CollectionName(nameof(CompanyStructure) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class CompanyStructure : BaseOnboardingModel<CompanyStructure>
    {
        public CompanyStructure() { }
        public CompanyStructure(string userName) : base(userName) { }

        private string[] countriesOfBussines;
        private int? percentageOfForeignUsers;
        private bool offShoreFoundationInOwnerStructure;
        private OwnerStructure ownerStructure;
        private Owner[] owners;

        public string[] CountriesOfBusiness
        {
            get { return countriesOfBussines; }
            set { countriesOfBussines = value; }
        }

        public int? PercentageOfForeignUsers
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
                PercentageOfForeignUsers != null &&
                Owners != null && Owners.Length > 0;

            if (!isStructureValid)
            {
                return isStructureValid;
            }

            bool incompleteOwnerFormsExists = Owners.Any(m => string.IsNullOrEmpty(m.FullName) ||
                string.IsNullOrEmpty(m.PersonalNumber) ||
                (m.DateOfBirth == null || m.DateOfBirth == DateTime.MinValue) ||
                string.IsNullOrEmpty(m.PlaceOfBirth) ||
                string.IsNullOrEmpty(m.DocumentNumber) ||
                (m.IssueDate == null && m.IssueDate == DateTime.MinValue) ||
                string.IsNullOrEmpty(m.IssuerName) ||
                string.IsNullOrEmpty(m.Citizenship) ||
                (m.OwningPercentage == null || m.OwningPercentage <= 0) ||
                string.IsNullOrEmpty(m.StatementOfOfficialDocument) ||
                string.IsNullOrEmpty(m.IdCard));

            return !incompleteOwnerFormsExists;
        }
    }
}

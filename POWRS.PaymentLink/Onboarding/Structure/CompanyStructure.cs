using System;
using Waher.Persistence.Attributes;
using POWRS.PaymentLink.Onboarding.Enums;

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
    }
}

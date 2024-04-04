using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(CompanyModel) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class CompanyModel : BaseOnboardingModel<CompanyModel>
    {
        public CompanyModel() { }
        public CompanyModel(string userName) : base(userName) { }

        private string businessModel;
        private int complaintsPerMonth;
        private int complaintsPerYear;
        private int daysPaymentToDelivery;

        private string fullNameOwnerLargestShare;
        private string personalNum;
        private DateTime birthDate;
        private string birthPlace;
        private string addressAndPlaceOfResidence;

        private string documentNumber;
        private DateTime documentIssueDate;
        private string documentIssueBy;
        private string documentIssuePlace;

        public string BusinessModel
        {
            get => businessModel;
            set => businessModel = value;
        }

        public int ComplaintsPerMonth
        {
            get => complaintsPerMonth;
            set => complaintsPerMonth = value;
        }

        public int ComplaintsPerYear
        {
            get => complaintsPerYear;
            set => complaintsPerYear = value;
        }

        public int DaysPaymentToDelivery
        {
            get => daysPaymentToDelivery;
            set => daysPaymentToDelivery = value;
        }

        public string FullNameOwnerLargestShare
        {
            get => fullNameOwnerLargestShare;
            set => fullNameOwnerLargestShare = value;
        }

        public string PersonalNum
        {
            get => personalNum;
            set => personalNum = value;
        }

        public DateTime BirthDate
        {
            get => birthDate;
            set => birthDate = value;
        }

        public string BirthPlace
        {
            get => birthPlace;
            set => birthPlace = value; 
        }

        public string AddressAndPlaceOfResidence
        {
            get => addressAndPlaceOfResidence;
            set => addressAndPlaceOfResidence = value;
        }

        public string DocumentNumber
        {
            get => documentNumber;
            set => documentNumber = value;
        }

        public DateTime DocumentIssueDate
        {
            get => documentIssueDate;
            set => documentIssueDate = value;
        }

        public string DocumentIssueBy
        {
            get => documentIssueBy;
            set => documentIssueBy = value;
        }

        public string DocumentIssuePlace
        {
            get => documentIssuePlace;
            set => documentIssuePlace = value;
        }
    }
}

using POWRS.PaymentLink.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Waher.Content.Html.Elements;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(CompanyModel) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class CompanyModel
    {
        private string objectId;
        public string userName;
        private string businessModel;
        private int complaintsPerMonth;
        private int complaintsPerYear;
        private int daysPaymentToDelivery;

        private string fullNameOwnerLargestShare;
        private int personalNum;
        private DateTime birthDate;
        private string birthPlace;
        private string addressAndPlaceOfResidence;

        private int documentNumber;
        private DateTime documentIssueDate;
        private string documentIssueBy;
        private string documentIssuePlace;

        [ObjectId]
        public string ObjectId
        {
            get => objectId;
            set => objectId = value;
        }

        public string UserName 
        { 
            get => userName; 
            set => userName = value; 
        }

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

        public int PersonalNum
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

        public int DocumentNumber
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

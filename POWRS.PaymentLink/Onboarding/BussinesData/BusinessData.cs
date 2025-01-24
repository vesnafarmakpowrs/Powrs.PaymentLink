using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(BusinessData) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class BusinessData : BaseOnboardingModel<BusinessData>
    {
        public BusinessData()
        {
            businessModel = "";
            methodOfDeliveringGoodsToCustomers = "";
            descriptionOfTheGoodsToBeSoldOnline = "";
            eComerceContactFullName = "";
            eComerceResponsiblePersonPhone = "";
            eComerceContactEmail = "";
        }
        public BusinessData(string userName) : base(userName) { }

        private string businessModel;
        private int retailersNumber;
        private int expectedMonthlyTurnover;
        private int expectedYearlyTurnover;
        private int threeMonthAccountTurnover;
        private int cardPaymentPercentage;
        private int averageTransactionAmount;
        private int averageDailyTurnover;
        private int cheapestProductAmount;
        private int mostExpensiveProductAmount;
        private bool sellingGoodsWithDelayedDelivery;
        private int periodFromPaymentToDeliveryInDays;
        private string methodOfDeliveringGoodsToCustomers;
        private int complaintsPerMonth;
        private int complaintsPerYear;
        private string descriptionOfTheGoodsToBeSoldOnline;
        private string eComerceContactFullName;
        private string eComerceResponsiblePersonPhone;
        private string eComerceContactEmail;
        private bool iPSOnly;

        public string BusinessModel
        {
            get => businessModel;
            set => businessModel = value;
        }

        public int RetailersNumber
        {
            get { return retailersNumber; }
            set { retailersNumber = value; }
        }

        public int ExpectedMonthlyTurnover
        {
            get { return expectedMonthlyTurnover; }
            set { expectedMonthlyTurnover = value; }
        }

        public int ExpectedYearlyTurnover
        {
            get { return expectedYearlyTurnover; }
            set { expectedYearlyTurnover = value; }
        }

        public int ThreeMonthAccountTurnover
        {
            get { return threeMonthAccountTurnover; }
            set { threeMonthAccountTurnover = value; }
        }

        public int CardPaymentPercentage
        {
            get { return cardPaymentPercentage; }
            set { cardPaymentPercentage = value; }
        }

        public int AverageTransactionAmount
        {
            get { return averageTransactionAmount; }
            set { averageTransactionAmount = value; }
        }

        public int AverageDailyTurnover
        {
            get { return averageDailyTurnover; }
            set { averageDailyTurnover = value; }
        }

        public int CheapestProductAmount
        {
            get { return cheapestProductAmount; }
            set { cheapestProductAmount = value; }
        }

        public int MostExpensiveProductAmount
        {
            get { return mostExpensiveProductAmount; }
            set { mostExpensiveProductAmount = value; }
        }
        public bool SellingGoodsWithDelayedDelivery
        {
            get => sellingGoodsWithDelayedDelivery;
            set => sellingGoodsWithDelayedDelivery = value;
        }

        public int PeriodFromPaymentToDeliveryInDays
        {
            get => periodFromPaymentToDeliveryInDays;
            set => periodFromPaymentToDeliveryInDays = value;
        }
        public string MethodOfDeliveringGoodsToCustomers { get => methodOfDeliveringGoodsToCustomers; set => methodOfDeliveringGoodsToCustomers = value; }

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
        public string DescriptionOfTheGoodsToBeSoldOnline { get => descriptionOfTheGoodsToBeSoldOnline; set => descriptionOfTheGoodsToBeSoldOnline = value; }
        public string EComerceContactFullName { get => eComerceContactFullName; set => eComerceContactFullName = value; }
        public string EComerceResponsiblePersonPhone { get => eComerceResponsiblePersonPhone; set => eComerceResponsiblePersonPhone = value; }
        public string EComerceContactEmail { get => eComerceContactEmail; set => eComerceContactEmail = value; }
        public bool IPSOnly { get => iPSOnly; set => iPSOnly = value; }

        public override bool IsCompleted()
        {
            return !string.IsNullOrWhiteSpace(BusinessModel) &&
                !string.IsNullOrWhiteSpace(methodOfDeliveringGoodsToCustomers) &&
                !string.IsNullOrWhiteSpace(descriptionOfTheGoodsToBeSoldOnline) &&
                !string.IsNullOrWhiteSpace(eComerceContactFullName) &&
                !string.IsNullOrWhiteSpace(eComerceResponsiblePersonPhone) &&
                !string.IsNullOrWhiteSpace(eComerceContactEmail) &&

                RetailersNumber >= 0 &&
                ExpectedMonthlyTurnover > 0 &&
                ExpectedYearlyTurnover > 0 &&
                ThreeMonthAccountTurnover > 0 &&
                CardPaymentPercentage >= 0 &&
                AverageTransactionAmount >= 0 &&
                AverageDailyTurnover >= 0 &&
                CheapestProductAmount > 0 &&
                MostExpensiveProductAmount > 0 &&
                ComplaintsPerMonth >= 0 &&
                ComplaintsPerYear >= 0 &&
                PeriodFromPaymentToDeliveryInDays >= 0
            ;
        }
    }
}

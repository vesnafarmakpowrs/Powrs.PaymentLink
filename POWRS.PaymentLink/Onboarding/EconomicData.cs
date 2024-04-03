using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(EconomicData) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class EconomicData
    {
        [ObjectId]
        private string objectId;
        private string userName;

        private int retailersNumber;
        private decimal expectedMonthlyTurnover;
        private decimal expectedYearlyTurnover;
        private decimal threeMonthAccountTurnover;
        private decimal cardPaymentPercentage;
        private decimal averageTransactionAmount;
        private decimal averageDailyTurnover;
        private decimal cheapestProductAmount;
        private decimal mostExpensiveProductAmount;

        public string ObjectId
        {
            get { return objectId; }
            set { objectId = value; }
        }

        public string UserName
        {
            get { return userName; }
            set { userName = value; }
        }

        public int RetailersNumber
        {
            get { return retailersNumber; }
            set { retailersNumber = value; }
        }

        public decimal ExpectedMonthlyTurnover
        {
            get { return expectedMonthlyTurnover; }
            set { expectedMonthlyTurnover = value; }
        }

        public decimal ExpectedYearlyTurnover
        {
            get { return expectedYearlyTurnover; }
            set { expectedYearlyTurnover = value; }
        }

        public decimal ThreeMonthAccountTurnover
        {
            get { return threeMonthAccountTurnover; }
            set { threeMonthAccountTurnover = value; }
        }

        public decimal CardPaymentPercentage
        {
            get { return cardPaymentPercentage; }
            set { cardPaymentPercentage = value; }
        }

        public decimal AverageTransactionAmount
        {
            get { return averageTransactionAmount; }
            set { averageTransactionAmount = value; }
        }

        public decimal AverageDailyTurnover
        {
            get { return averageDailyTurnover; }
            set { averageDailyTurnover = value; }
        }

        public decimal CheapestProductAmount
        {
            get { return cheapestProductAmount; }
            set { cheapestProductAmount = value; }
        }

        public decimal MostExpensiveProductAmount
        {
            get { return mostExpensiveProductAmount; }
            set { mostExpensiveProductAmount = value; }
        }
    }
}

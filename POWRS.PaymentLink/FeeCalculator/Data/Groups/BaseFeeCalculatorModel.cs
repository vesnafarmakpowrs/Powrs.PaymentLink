
namespace POWRS.PaymentLink.FeeCalculator.Data
{
    public class BaseFeeCalculatorModel
    {
        public BaseFeeCalculatorModel() { }
        public BaseFeeCalculatorModel(bool showGroup, decimal transactionPercentage, int numberOfTransactions, decimal fee, decimal cost)
        {
            this.showGroup = showGroup;
            this.transactionPercentage = transactionPercentage;
            this.numberOfTransactions = numberOfTransactions;
            this.fee = fee;
            this.cost = cost;
        }

        private bool showGroup;
        private decimal transactionPercentage;
        private int numberOfTransactions;
        private decimal fee;
        private decimal cost;


        public bool ShowGroup { get => showGroup; set => showGroup = value; }
        public decimal TransactionPercentage { get => transactionPercentage; set => transactionPercentage = value; }
        public int NumberOfTransactions { get => numberOfTransactions; set => numberOfTransactions = value; }
        public decimal Fee { get => fee; set => fee = value; }
        public decimal Cost { get => cost; set => cost = value; }
    }
}

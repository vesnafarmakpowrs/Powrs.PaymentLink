
namespace POWRS.PaymentLink.FeeCalculator.Data
{
    public class Current
    {
        private int totalRevenue;
        private decimal averageAmount;
        private int totalTransactions;
        private decimal cardTransactionPercentage;
        private decimal cardFee;

        private int totalCardTransactions;
        private decimal totalCardCost;

        public int TotalRevenue { get => totalRevenue; set => totalRevenue = value; }
        public decimal AverageAmount { get => averageAmount; set => averageAmount = value; }
        public int TotalTransactions { get => totalTransactions; set => totalTransactions = value; }
        public decimal CardTransactionPercentage { get => cardTransactionPercentage; set => cardTransactionPercentage = value; }
        public decimal CardFee { get => cardFee; set => cardFee = value; }
        public int TotalCardTransactions { get => totalCardTransactions; set => totalCardTransactions = value; }
        public decimal TotalCardCost { get => totalCardCost; set => totalCardCost = value; }
    }
}

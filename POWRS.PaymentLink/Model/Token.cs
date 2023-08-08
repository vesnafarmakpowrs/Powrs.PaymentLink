namespace POWRS.PaymentLink.Model
{
    public class Token
    {
        public string TokenId { get; set; }
        public decimal Value { get; set; }
        public string Currency { get; set; }
        public string OwnerJid { get; set; }
        public string Owner { get; set; }
        public string CallBackUrl { get; set; }

        public bool IsValid()
        {
            if (string.IsNullOrEmpty(TokenId) ||
              string.IsNullOrEmpty(Currency) ||
              string.IsNullOrEmpty(OwnerJid) ||
              string.IsNullOrEmpty(Owner) ||
              Value <= 0)
            {
                return false;
            }

            return true;
        }
    }
}

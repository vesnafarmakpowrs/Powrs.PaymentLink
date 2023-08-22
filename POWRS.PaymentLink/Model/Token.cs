namespace POWRS.PaymentLink.Model
{
    public class Token
    {
        public string TokenId { get; set; }
        public string OwnerJid { get; set; }
        public string Owner { get; set; }

        public bool IsValid()
        {
            if (string.IsNullOrEmpty(TokenId) ||
              string.IsNullOrEmpty(OwnerJid) ||
              string.IsNullOrEmpty(Owner))
            {
                return false;
            }

            return true;
        }
    }
}

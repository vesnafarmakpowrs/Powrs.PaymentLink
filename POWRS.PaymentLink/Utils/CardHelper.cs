using System;

namespace POWRS.PaymentLink
{
    public static class CardHelper
    {
        public static bool IsCardExpired(DateTime dateToCompare, string cardExpiry)
        {
            if (cardExpiry.Length != 4 || !int.TryParse(cardExpiry, out int expiryInt))
            {
                throw new ArgumentException("Invalid card expiry format. Use MMYY format.");
            }

            int expiryYear = expiryInt / 100;
            int expiryMonth = expiryInt % 100;

            if (expiryMonth < 1 || expiryMonth > 12)
            {
                throw new ArgumentException("Invalid month in card expiry date.");
            }

            expiryYear += 2000;
            DateTime cardExpiryDate = new(expiryYear, expiryMonth, DateTime.DaysInMonth(expiryYear, expiryMonth));

            return dateToCompare.Date > cardExpiryDate.Date;
        }
    }
}

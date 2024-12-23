using System;
using Waher.Events;

namespace POWRS.PaymentLink.Contracts.Enums
{
    public enum PaymentCompletedStates
    {
        PaymentCompleted,
        ServiceDelivered,
        ReleasedFundsToSeller,
        ReleaseFundsToSellerFailed,
        AwaitingforRefundPayment,
        RefundBuyer,
        RefundBuyerFailed,
        Done
    }

    public static class EnumHelper
    {
        public static bool IsPaymentCompleted(string State)
        {
            try
            {
                foreach (string completedState in PaymentCompletedStates.GetNames(typeof(PaymentCompletedStates)))
                {
                    if (State == completedState)
                        return true;
                }
                return false;
            } 
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
}

    }
}

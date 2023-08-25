namespace POWRS.PaymentLink.Model
{
    internal class CreateContractResult
    {
        public string ContractId { get; set; } 
        public string ErrorMessage { get; set; }

        public bool IsSuccess
        {
            get
            {
                return !string.IsNullOrEmpty(ContractId) && string.IsNullOrEmpty(ErrorMessage);
            }
        }
    }
}

using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding.Documents
{
    [CollectionName(nameof(LegalDocuments))]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class LegalDocuments : BaseOnboardingModel<LegalDocuments>
    {
        public LegalDocuments() { }
        public LegalDocuments(string UserName) : base(UserName) { }

        private string bussinesCooperationRequest;
        private string contractWithVaulter;
        private string contractWithEMI;
        private string promissoryNote;

        public string BussinesCooperationRequest { get =>  bussinesCooperationRequest; set => bussinesCooperationRequest = value; }
        public string ContractWithVaulter { get => contractWithVaulter; set => contractWithVaulter = value; }
        public string ContractWithEMI { get => contractWithEMI; set => contractWithEMI = value; }
        public string PromissoryNote { get => promissoryNote; set => promissoryNote = value; }

        public override bool IsCompleted()
        {
            return !string.IsNullOrEmpty(this.BussinesCooperationRequest) &&
                    !string.IsNullOrEmpty(this.ContractWithVaulter) &&
                    !string.IsNullOrEmpty(this.ContractWithEMI) &&
                    !string.IsNullOrEmpty(this.PromissoryNote);
        }
    }
}

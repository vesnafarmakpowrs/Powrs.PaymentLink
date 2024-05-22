using System;
using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(LegalDocuments))]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class LegalDocuments : BaseOnboardingModel<LegalDocuments>
    {
        public LegalDocuments()
        {
            businessCooperationRequest = "";
            contractWithVaulter = "";
            contractWithEMI = "";
            promissoryNote = "";
            politicalStatement = "";
        }
        public LegalDocuments(string UserName) : base(UserName) { }

        private string businessCooperationRequest;
        private string contractWithVaulter;
        private string contractWithEMI;
        private string promissoryNote;
        private string politicalStatement;

        public string BusinessCooperationRequest { get => businessCooperationRequest; set => businessCooperationRequest = value; }
        public string ContractWithVaulter { get => contractWithVaulter; set => contractWithVaulter = value; }
        public string ContractWithEMI { get => contractWithEMI; set => contractWithEMI = value; }
        public string PromissoryNote { get => promissoryNote; set => promissoryNote = value; }
        public string PoliticalStatement { get => politicalStatement; set => politicalStatement = value; }

        public override bool IsCompleted()
        {
            return !string.IsNullOrEmpty(this.BusinessCooperationRequest) &&
                    !string.IsNullOrEmpty(this.ContractWithVaulter) &&
                    !string.IsNullOrEmpty(this.ContractWithEMI) &&
                    !string.IsNullOrEmpty(this.PromissoryNote);
        }
    }
}

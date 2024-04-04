using System;
using Waher.Persistence.Attributes;
using POWRS.PaymentLink.Onboarding.Enums;

namespace POWRS.PaymentLink.Onboarding
{
    [CollectionName(nameof(CompanyStructure) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    public class CompanyStructure : BaseOnboardingModel<CompanyStructure>
    {
        public CompanyStructure() { }
        public CompanyStructure(string userName) : base(userName) { }

        private string fullNameAuthorizedRepresentative;
        private DateTime authorizedRepresentativeBirthDate;
        private string otherAuthorizedRepresentatives;
        private string personalDocumentNum;
        private DocumentType documentType;
        private DateTime dateOfIssuePersonalDocument;

        private string companyBusinessCountry;
        private OwnerStrcture ownerStrcture;
        private FunctionaStatusBeneficialOwner functionaStatusBeneficialOwner;
        private OffShoreFondationTrast offShoreFondationTrast;

       
        private string foreignExchangeIdentificationNum;
        private int foreignServiceUsersPercentage;
        private string realOwnersData;

        public string FullNameAuthorizedRepresentative 
        { 
             get => fullNameAuthorizedRepresentative; 
             set => fullNameAuthorizedRepresentative = value; 
        }
                
        public DateTime AuthorizedRepresentativeBirthDate 
        { 
            get => authorizedRepresentativeBirthDate; 
            set => authorizedRepresentativeBirthDate = value; 
        }

        public string OtherAuthorizedRepresentatives
        {
            get => otherAuthorizedRepresentatives;
            set => otherAuthorizedRepresentatives = value;
        }

        public string PersonalDocumentNum
        {
            get => personalDocumentNum;
            set => personalDocumentNum = value;
        }

        public DocumentType DocumentType
        {
            get => documentType;
            set => documentType = value;
        }

        public string CompanyBusinessCountry
        {
            get => companyBusinessCountry;
            set => companyBusinessCountry = value;
        }

        public OwnerStrcture OwnerStrcture
        {
            get => ownerStrcture;
            set => ownerStrcture = value;
        }

        public FunctionaStatusBeneficialOwner FunctionaStatusBeneficialOwner
        {
            get => functionaStatusBeneficialOwner;
            set => functionaStatusBeneficialOwner = value;
        }

        public OffShoreFondationTrast OffShoreFondationTrast
        {
            get => offShoreFondationTrast;
            set => offShoreFondationTrast = value;
        }
        public DateTime DateOfIssuePersonalDocument
        {
            get => dateOfIssuePersonalDocument;
            set => dateOfIssuePersonalDocument = value;
        }
                
        public string ForeignExchangeIdentificationNum
        {
            get => foreignExchangeIdentificationNum;
            set => foreignExchangeIdentificationNum = value;
        }

        public int ForeignServiceUsersPercentage
        {
            get => foreignServiceUsersPercentage;
            set => foreignServiceUsersPercentage = value;
        }        

        public string RealOwnersData
        {
            get => realOwnersData;
            set => realOwnersData = value;
        }        
    }
}

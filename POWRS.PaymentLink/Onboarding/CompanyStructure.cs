using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Waher.Networking.HTTP.ScriptExtensions.Functions.Security;

namespace POWRS.PaymentLink.Onboarding
{
    public class CompanyStructure
    {
        private string fullNameAuthorizedRepresentative;
        private DateTime authorizedRepresentativeBirthDate;
        private string otherAuthorizedRepresentatives;
        private string personalDocumentNum;
        private DateTime dateOfIssuePersonalDocument;
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

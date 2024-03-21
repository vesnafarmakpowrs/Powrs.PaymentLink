using Waher.Persistence.Attributes;

namespace POWRS.PaymentLink
{
    [CollectionName(nameof(OrganizationContactInfo))]
    [TypeName(TypeNameSerialization.None)]
    [Index("Account")]
    public class OrganizationContactInfo
    {
        private string objectId;
        private string organizationName;
        private string webAddress;
        private string email;
        private string phoneNumber;
        private string termsAndConditions;

        [ObjectId]
        public string ObjectId
        {
            get => objectId;
            set => objectId = value;
        }
        public string OrganizationName
        {
            get => organizationName;
            set => organizationName = value;
        }
        public string WebAddress
        {
            get => webAddress;
            set => webAddress = value;
        }
        public string Email
        {
            get => email;
            set => email = value;
        }
        public string PhoneNumber
        {
            get => phoneNumber;
            set => phoneNumber = value;
        }
        public string TermsAndConditions
        {
            get => termsAndConditions;
            set => termsAndConditions = value;
        }

        public bool IsValid()
        {
            return !string.IsNullOrWhiteSpace(OrganizationName) &&
                !string.IsNullOrWhiteSpace(WebAddress) &&
                !string.IsNullOrWhiteSpace(Email) &&
                !string.IsNullOrWhiteSpace(PhoneNumber) &&
                !string.IsNullOrWhiteSpace(TermsAndConditions);
        }
    }
}

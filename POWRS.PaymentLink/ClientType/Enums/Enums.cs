
namespace POWRS.PaymentLink.ClientType.Enums
{
    public enum ClientType
    {
        Small,
        Medium,
        Large
    }

    public static class EnumHelper
    {
        private const string SmallClientTypePath = "registerclient";
        private const string MediumClientTypePath = "registration";
        private const string LargeClientTypePath = "registerorganization";

        public static ClientType GetEnumByUrlPathName(string pathName)
        {
            switch (pathName)
            {
                case SmallClientTypePath:
                    return ClientType.Small;
                case MediumClientTypePath:
                    return ClientType.Medium;
                case LargeClientTypePath:
                    return ClientType.Large;
                default:
                    return ClientType.Small;
            }
        }

        public static string GetPathNameByEnum(ClientType clientType)
        {
            switch (clientType)
            {
                case ClientType.Small:
                    return SmallClientTypePath;
                case ClientType.Medium:
                    return MediumClientTypePath;
                case ClientType.Large:
                    return LargeClientTypePath;
                default:
                    return "";
            }
        }

    }
}

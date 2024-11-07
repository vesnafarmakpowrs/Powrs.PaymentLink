
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
        private const string pathClientType_Small = "registerclient";
        private const string pathClientType_Medium = "registration";
        private const string pathClientType_Large = "registerorganization";

        public static ClientType GetEnumByUrlPathName(string pathName)
        {
            switch (pathName)
            {
                case pathClientType_Small:
                    return ClientType.Small;
                case pathClientType_Medium:
                    return ClientType.Medium;
                case pathClientType_Large:
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
                    return pathClientType_Small;
                case ClientType.Medium:
                    return pathClientType_Medium;
                case ClientType.Large:
                    return pathClientType_Large;
                default:
                    return "";
            }
        }

    }
}

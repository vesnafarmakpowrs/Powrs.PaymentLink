
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
        public static ClientType GetEnumByUrlPathName(string pathName)
        {
            switch (pathName)
            {
                case "registration":
                    return ClientType.Small;
                case "registerclient":
                    return ClientType.Medium;
                case "registerorganization":
                    return ClientType.Large;
                default:
                    return ClientType.Small;
            }
        }
    }
}

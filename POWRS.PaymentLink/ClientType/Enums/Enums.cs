
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
                case "registerclient":
                    return ClientType.Small;
                case "registration":
                    return ClientType.Medium;
                case "registerorganization":
                    return ClientType.Large;
                default:
                    return ClientType.Small;
            }
        }
    }
}

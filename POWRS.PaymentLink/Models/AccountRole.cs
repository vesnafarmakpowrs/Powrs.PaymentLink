using System;
using System.Collections.Generic;

namespace POWRS.PaymentLink.Models
{
    /// <summary>
    /// Role definition:
    /// SuperAdmin  -> Powrs (Will have full access)
    /// Admin       -> Yuta (Can see and get details from all children. CAN'T create new user (legal id)
    /// Client      -> Org admins. Can see and get details from all children. CAN Create user with same or lower role
    /// User        -> user from Org. Can see only his transactions. CAN'T create new user (legal id)
    /// </summary>
    public enum AccountRole
    {
        SuperAdmin,
        Admin,
        Client,
        User
    }

    public static class EnumHelper
    {
        public static bool IsEnumDefined(Type enumType, int enumValue)
        {
            return Enum.IsDefined(enumType, enumValue);
        }

        public static Dictionary<string, int> ListAllValues(Type enumType)
        {
            Dictionary<string, int> enumDictionary = new();

            foreach (var value in Enum.GetValues(enumType))
            {
                enumDictionary.Add(value.ToString(), (int)value);
            }

            return enumDictionary;
        }
    }
}

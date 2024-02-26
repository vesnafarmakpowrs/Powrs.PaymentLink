using System;
using System.Collections.Generic;

namespace POWRS.PaymentLink.Models
{
    public enum AccountRole
    {
        User,
        Admin
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

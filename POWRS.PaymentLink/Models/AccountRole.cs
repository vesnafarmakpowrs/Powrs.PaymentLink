using System;
using System.Collections.Generic;

namespace POWRS.PaymentLink.Models
{
    /// <summary>
    /// Role definition:
    /// SuperAdmin      -> Powrs (Will have full access)
    /// GroupAdmin      -> Yuta (Can see and get details from all children. CAN'T create new user (legal id)
    /// ClientAdmin     -> Org admins. Can see and get details from all children. CAN Create user with same or lower role
    /// User            -> user from Org. Can see only his transactions. CAN'T create new user (legal id)
    /// Client          -> Stara rola... dok se ne uradi update u bazi
    /// </summary>
    public enum AccountRole
    {
        SuperAdmin,
        GroupAdmin,
        ClientAdmin,
        User
    }

    public static class EnumHelper
    {
        public static bool IsEnumDefined(Type enumType, int enumValue)
        {
            return Enum.IsDefined(enumType, enumValue);
        }

        public static AccountRole GetEnumByIndex(int index)
        {
            return (AccountRole)index;
        }

        public static int GetIndexByName(Type enumType, string value)
        {
            int index = 0;
            foreach (var item in Enum.GetValues(enumType))
            {
                if (value == item.ToString())
                {
                    index = (int)item;
                    break;
                }
            }

            return index;
        }

        public static Dictionary<string, int> ListAllSubValues(Type enumType, int minValue)
        {
            Dictionary<string, int> enumDictionary = new();

            foreach (var item in Enum.GetValues(enumType))
            {
                if ((int)item >= minValue)
                    enumDictionary.Add(item.ToString(), (int)item);
            }

            return enumDictionary;
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

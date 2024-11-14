﻿using POWRS.PaymentLink.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Waher.Persistence;

namespace POWRS.PaymentLink
{
    public static class Utils
    {
        public static bool IsValidBase64String(string base64String, decimal maxSizeMB)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(base64String))
                {
                    return false;
                }

                byte[] byteArray = Convert.FromBase64String(base64String);
                return byteArray.Length <= maxSizeMB * 1024 * 1024;
            }
            catch (FormatException)
            {
                return false;
            }
        }

        public static string PrepareStringForFileName(string fileName)
        {
            return fileName.Replace("Č", "C")
                .Replace("č", "c")
                .Replace("Ć", "C")
                .Replace("ć", "c")
                .Replace("Š", "S")
                .Replace("š", "s")
                .Replace("Đ", "Dj")
                .Replace("đ", "dj")
                .Replace("Ž", "Z")
                .Replace("ž", "z")
                .Replace(" ", "")
                .Replace("'", "")
                .Replace("\"", "");
        }

        public static async Task<List<string>> GetAllOrganizationChildren(string parentOrgName)
        {
            var brokerAccounrRoleList = await Database.Find<BrokerAccountRole>();
            int generation = 1;
            var resultList = GetAllChildren(brokerAccounrRoleList, parentOrgName, generation).Distinct().ToList();
            resultList.Insert(0, parentOrgName);

            return resultList;
        }

        private static List<string> GetAllChildren(IEnumerable<BrokerAccountRole> brokerAccRoleList, string parentOrgName, int generation)
        {
            var resultList = new List<string>();
            var directChildren = brokerAccRoleList.Where(x => x.ParentOrgName == parentOrgName).ToList();

            foreach (var item in directChildren)
            {
                if (!resultList.Contains(item.OrgName) && item.OrgName != "")
                {
                    resultList.Add(item.OrgName);
                    if (generation < 100)
                        resultList.AddRange(GetAllChildren(brokerAccRoleList, item.OrgName, generation + 1));
                }
            }

            return resultList;
        }

    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Waher.Persistence;
using Waher.Persistence.Attributes;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Models
{
    [CollectionName(nameof(BrokerAccountRole) + "s")]
    [TypeName(TypeNameSerialization.None)]
    [Index("UserName")]
    [Index("OrgName")]
    public class BrokerAccountRole
    {
        private string objectId;
        private string userName;
        private AccountRole role;
        private string creatorUserName;
        private string orgName;
        private string parentOrgName;

        [ObjectId]
        public string ObjectId { get => objectId; set => objectId = value; }
        public string UserName { get => userName; set => userName = value; }
        public AccountRole Role { get => role; set => role = value; }
        public string CreatorUserName { get => creatorUserName; set => creatorUserName = value; }
        public string OrgName { get => orgName; set => orgName = value; }
        public string ParentOrgName { get => parentOrgName; set => parentOrgName = value; }


        public static async Task<List<string>> GetAllOrganizationChildren(string parentOrgName)
        {
            var brokerAccounrRoleList = await Database.Find<BrokerAccountRole>();
            brokerAccounrRoleList = brokerAccounrRoleList.Where(x => x.OrgName != "");

            int generation = 1; //control counter to avoid infinite loop
            var resultList = GetAllChildren(brokerAccounrRoleList, parentOrgName, generation);
            resultList.Add(parentOrgName);

            return resultList.Distinct().OrderBy(x => x).ToList();
        }
        private static List<string> GetAllChildren(IEnumerable<BrokerAccountRole> brokerAccRoleList, string parentOrgName, int generation)
        {
            var resultList = new List<string>();
            var directChildren = brokerAccRoleList.Where(x => x.ParentOrgName == parentOrgName).ToList();

            foreach (var item in directChildren)
            {
                if (!resultList.Contains(item.OrgName))
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

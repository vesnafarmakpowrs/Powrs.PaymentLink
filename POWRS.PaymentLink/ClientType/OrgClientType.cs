using POWRS.PaymentLink.ClientType.Models;
using System;
using System.Threading.Tasks;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.ClientType
{
    public class OrgClientType
    {
        public OrganizationClientType OrganizationClientType { get; set; } = new OrganizationClientType();
        public BrokerAccountOnboaradingClientTypeTMP BrokerAccountOnboaradingClientTypeTMP { get; set; } = new BrokerAccountOnboaradingClientTypeTMP();


        public static async Task<OrgClientType> GetOrgClientTypeData(string orgName)
        {
            if (string.IsNullOrWhiteSpace(orgName))
            {
                throw new Exception("parameter orgName is mandatory");
            }

            var orgNameFilter = new FilterFieldEqualTo("OrganizationName", orgName);
            var orgClientTypeTask = Database.FindFirstDeleteRest<OrganizationClientType>(orgNameFilter);

            await orgClientTypeTask;

            var orgClientTypeResult = new OrgClientType { OrganizationClientType = orgClientTypeTask.Result ?? new OrganizationClientType() };
            return orgClientTypeResult;
        }

        public static async Task<OrgClientType> GetBrokerAccClientType(string userName)
        {
            if (string.IsNullOrWhiteSpace(userName))
            {
                throw new Exception("parameter userName is mandatory");
            }

            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var brokerAccClientTypeTask = Database.FindFirstDeleteRest<BrokerAccountOnboaradingClientTypeTMP>(userNameFilter);

            await brokerAccClientTypeTask;

            var brokerAccClientTypeResult = new OrgClientType { BrokerAccountOnboaradingClientTypeTMP = brokerAccClientTypeTask.Result ?? new BrokerAccountOnboaradingClientTypeTMP() };
            return brokerAccClientTypeResult;
        }
    }
}

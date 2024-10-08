using POWRS.PaymentLink.ClientType.Models;
using POWRS.PaymentLink.Onboarding;
using System;
using System.Threading.Tasks;
using Waher.Events;
using Waher.Networking.XMPP.Contracts;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.ClientType
{
    public class OrgClientType
    {
        public OrganizationClientType OrganizationClientType { get; set; } = new OrganizationClientType();
        public BrokerAccountOnboaradingClientTypeTMP BrokerAccountOnboaradingClientTypeTMP { get; set; } = new BrokerAccountOnboaradingClientTypeTMP();

        public static async Task<Enums.ClientType> GetClientTypeByUserName(string userName)
        {
            //try get by broker account client type tmp tbl
            //if not try get org name by onboarding general info
            // get client type by  

            Enums.ClientType enumClientType = Enums.ClientType.Small;

            if (string.IsNullOrWhiteSpace(userName))
            {
                throw new Exception("parameter userName is mandatory");
            }

            //try get by BrokerAccountOnboaradingClientTypeTMP
            var brokerAccClientTypeTask = await GetBrokerAccClientType(userName);
            if (brokerAccClientTypeTask.BrokerAccountOnboaradingClientTypeTMP != null)
            {
                return brokerAccClientTypeTask.BrokerAccountOnboaradingClientTypeTMP.OrgClientType;
            }

            string userOrgName = string.Empty;

            //if not try get org name by onboarding general info
            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var generalCompanyInformation = await Database.FindFirstDeleteRest<GeneralCompanyInformation>(userNameFilter);
            if (generalCompanyInformation != null && !string.IsNullOrWhiteSpace(generalCompanyInformation.ShortName))
            {
                userOrgName = generalCompanyInformation.ShortName;

                //get data by OrganizationClientType
                var orgClientType = await GetOrgClientTypeData(userOrgName);
                if (orgClientType.OrganizationClientType != null)
                {
                    enumClientType = orgClientType.OrganizationClientType.OrgClientType;
                }
            }

            return enumClientType;
        }

        public static async Task<OrgClientType> GetOrgClientTypeData(string orgName)
        {
            var orgNameFilter = new FilterFieldEqualTo("OrganizationName", orgName);
            var orgClientType = await Database.FindFirstDeleteRest<OrganizationClientType>(orgNameFilter);

            return new OrgClientType { OrganizationClientType = orgClientType };
        }

        public static async Task<OrgClientType> GetBrokerAccClientType(string userName)
        {
            var userNameFilter = new FilterFieldEqualTo("UserName", userName);
            var brokerAccClientType = await Database.FindFirstDeleteRest<BrokerAccountOnboaradingClientTypeTMP>(userNameFilter);

            return new OrgClientType { BrokerAccountOnboaradingClientTypeTMP = brokerAccClientType };
        }
    }
}

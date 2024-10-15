using System.Collections.Generic;
using System.Threading.Tasks;
using Waher.Networking.HTTP;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Authorization
{
    public class RemoveApiKey : BasePaylinkAuthorization, IHttpPostMethod
    {
        public bool AllowsPOST => true;

        public RemoveApiKey()
            : base("/Agent/Paylink/RemoveAgentApiKey") { }

        public async Task POST(HttpRequest Request, HttpResponse Response)
        {
            Account BrokerAccount = await GetAccountFromJwtToken(Request);
            AgentApiKey agentApiKey = await Database.FindFirstDeleteRest<AgentApiKey>(new FilterFieldEqualTo("UserName", BrokerAccount.UserName));

            if (agentApiKey != null)
            {
                if (!agentApiKey.CanBeOverriden)
                {
                    throw new ForbiddenException("Api key could not be removed.");
                }

                await Database.Delete(agentApiKey);
            }

            await Response.Return(new Dictionary<string, object>
            {
                { "Success", true }
            });
        }
    }
}

using System.Collections.Generic;
using System.Threading.Tasks;
using Waher.Networking.HTTP;
using Waher.Persistence;
using Waher.Persistence.Filters;

namespace POWRS.PaymentLink.Authorization
{
    public class GetAgentApiKey : BasePaylinkAuthorization, IHttpPostMethod
    {
        public GetAgentApiKey()
            : base("/Agent/Paylink/GetApiKey")
        {
        }

        public bool AllowsPOST => true;

        public async Task POST(HttpRequest Request, HttpResponse Response)
        {
            ConfigureResponse(Response);

            Account account = await GetAccountFromJwtToken(Request);
            AgentApiKey agentApiKey = await Database.FindFirstDeleteRest<AgentApiKey>(new FilterFieldEqualTo("UserName", account.UserName));

            var response = new Dictionary<string, object>();
            if (agentApiKey != null)
            {
                response = new Dictionary<string, object>()
                {
                    { "ApiKey", agentApiKey.ApiKey },
                    { "CanBeOverriden", agentApiKey.CanBeOverriden},
                    { "Created",  agentApiKey.Created},
                    { "LastLogin", agentApiKey.LastLogin  },
                    { "IsBlocked", agentApiKey.IsBlocked  }
                };
            }

            await Response.Return(response);
        }
    }
}

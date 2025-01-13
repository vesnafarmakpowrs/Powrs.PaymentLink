using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Waher.Content;
using Waher.Networking.HTTP;
using Waher.Persistence;
using Waher.Persistence.Filters;
using Waher.Security;
using Waher.Security.JWT;

namespace POWRS.PaymentLink.Authorization
{
    public sealed class PaylinkLogin : BasePaylinkAuthorization, IHttpPostMethod
    {
        public PaylinkLogin()
            : base("/Agent/Paylink/Login") { }

        public bool AllowsPOST => true;

        public async Task POST(HttpRequest Request, HttpResponse Response)
        {
            ConfigureResponse(Response);

            await EnsureEndpointCanLogin(Request);

            Dictionary<string, object> requestBody = await GetRequestBody(Request);

            string apikey = string.Empty;
            string apiSecret = string.Empty;

            if (requestBody.TryGetValue("ApiKey", out object apiKeyObject))
            {
                apikey = apiKeyObject.ToString();
            }
            if (requestBody.TryGetValue("ApiSecret", out object apiSecretObject))
            {
                apiSecret = apiSecretObject.ToString();
            }

            if (string.IsNullOrEmpty(apikey) || string.IsNullOrEmpty(apiSecret))
            {
                await ThrowLoginFailure("Api key and secret are mandatory.", "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }

            AgentApiKey agentApiKey = await Database.FindFirstDeleteRest<AgentApiKey>(new FilterFieldEqualTo("ApiKey", apikey));
            if (agentApiKey == null)
            {
                await ThrowLoginFailure("Login Failed. Invalid agent api key.", "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }
            if (agentApiKey.Signature != Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Encoding.UTF8.GetBytes(apikey), Encoding.UTF8.GetBytes(apiSecret))))
            {
                await ThrowLoginFailure("Login Failed. Key and secret not valid.", agentApiKey.UserName ?? "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }
            if (agentApiKey.IsBlocked)
            {
                await ThrowLoginFailure("Login Failed. Api key blocked.", agentApiKey.UserName ?? "", Request.RemoteEndPoint, HttpStatusCode.Forbidden);
            }
            if (string.IsNullOrEmpty(agentApiKey.UserName))
            {
                await ThrowLoginFailure("Login Failed. Username empty.", agentApiKey.UserName ?? "", Request.RemoteEndPoint, HttpStatusCode.Forbidden);
            }

            _ = await GetEnabledAccount(agentApiKey.UserName, Request.RemoteEndPoint);

            int duration = GetDurationParameter(requestBody);
            JwtToken jwtToken = CreateJwtFactoryToken(agentApiKey.UserName, duration);

            agentApiKey.LastLogin = DateTime.UtcNow;
            await Database.Update(agentApiKey);

            await ProcessLoginSuccess(Request.RemoteEndPoint, agentApiKey.UserName);

            await Response.Return(new Dictionary<string, object>
            {
                { "jwt", jwtToken.Token },
                { "expires", (int)Math.Round(Convert.ToDateTime(jwtToken.Expiration).Subtract(JSON.UnixEpoch).TotalSeconds) },
            });
        }
    }
}

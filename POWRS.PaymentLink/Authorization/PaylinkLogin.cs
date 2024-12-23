using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Waher.Content;
using Waher.Events;
using Waher.IoTGateway;
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

            DateTime? loginOpportunity = await Gateway.LoginAuditor.GetEarliestLoginOpportunity(Request.RemoteEndPoint, "HTTPS");
            if (loginOpportunity > DateTime.UtcNow)
            {
                throw new TooManyRequestsException($"Login is blocked for: {Request.RemoteEndPoint}. Next login attempt could be made: {loginOpportunity}");
            }

            Dictionary<string, object> requestBody = await GetRequestBody(Request);

            string apikey = string.Empty;
            string apiSecret = string.Empty;
            int duration = 3600;

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

            _ = await GetEnabledAccount(agentApiKey.UserName, async () =>
            {
                Log.Error("Login Failed. Account not found.", agentApiKey.UserName, Request.RemoteEndPoint, "LoginFailure");
                await Gateway.LoginAuditor.ProcessLoginFailure(Request.RemoteEndPoint, "HTTPS", DateTime.UtcNow, "Login Failed. Account not found.");
            });

            if (requestBody.TryGetValue("Duration", out object durationObject) && int.TryParse(durationObject?.ToString(), out int parsedDuration))
            {
                if (parsedDuration > duration || parsedDuration <= 0)
                {
                    throw new BadRequestException("Min Duration: 0, Max duration is 3600s.");
                }

                duration = parsedDuration;
            }

            JwtToken token = CreateJwtFactoryToken(agentApiKey.UserName, duration);

            agentApiKey.LastLogin = DateTime.UtcNow;
            await Database.Update(agentApiKey);

            await Gateway.LoginAuditor.ProcessLoginSuccessful(Request.RemoteEndPoint, "HTTPS");
            Log.Notice("Login success", agentApiKey.UserName, Request.RemoteEndPoint, "LoginSuccess");

            await Response.Return(new Dictionary<string, object>
            {
                { "jwt", token },
                { "expires", (int)Math.Round(DateTime.UtcNow.Subtract(JSON.UnixEpoch).TotalSeconds) + duration },
            });
        }

        private async Task ThrowLoginFailure(string Message, string UserName, string Endpoint, HttpStatusCode statusCode)
        {
            Log.Error(Message, UserName, Endpoint, "LoginFailure");
            await Gateway.LoginAuditor.ProcessLoginFailure(Endpoint, "HTTPS", DateTime.UtcNow, UserName);
            throw new HttpException((int)statusCode, Message);
        }
    }
}

using POWRS.PaymentLink.Models;
using POWRS.PaymentLink.Module;
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
using Waher.Runtime.Settings;
using Waher.Security;
using Waher.Security.JWT;

namespace POWRS.PaymentLink.Authorization
{
    public sealed class SmartAdminLogin : BasePaylinkAuthorization, IHttpPostMethod
    {
        public SmartAdminLogin()
            : base("/Agent/SmartAdmin/Login") { }

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

            string userName = string.Empty;
            string nonce = string.Empty;
            string signature = string.Empty;
            int duration = 3600;

            //validate header valuess
            if (requestBody.TryGetValue("userName", out object userNameObject))
            {
                userName = userNameObject.ToString();
            }
            if (requestBody.TryGetValue("nonce", out object nonceObject))
            {
                nonce = nonceObject.ToString();
            }
            if (requestBody.TryGetValue("signature", out object signatureObject))
            {
                signature = signatureObject.ToString();
            }
            if (string.IsNullOrEmpty(userName) || string.IsNullOrEmpty(nonce) || string.IsNullOrEmpty(signature))
            {
                await ThrowLoginFailure("Username, nonce and signature are mandatory.", "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }

            //Check KeyId and KeyPassword
            var KeyId = await RuntimeSettings.GetAsync(userName + ".KeyId", "");
            var KeyPassword = await RuntimeSettings.GetAsync(userName + ".KeySecret", "");

            if (string.IsNullOrEmpty(KeyId) || string.IsNullOrEmpty(KeyPassword))
            {
                await ThrowLoginFailure($"No signing keys or password available for user: {userName}", "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }

            //check and get account details
            var account = await GetEnabledAccount(userName, async () =>
            {
                Log.Error("Login Failed. Account not found.", userName, Request.RemoteEndPoint, "LoginFailure");
                await Gateway.LoginAuditor.ProcessLoginFailure(Request.RemoteEndPoint, "HTTPS", DateTime.UtcNow, "Login Failed. Account not found.");
            });

            //validate signature
            string s = $"{userName}:{Gateway.Domain?.Value ?? string.Empty}:{nonce}";
            string controlSignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Encoding.UTF8.GetBytes(account.Password), Encoding.UTF8.GetBytes(s)));

            if (signature != controlSignature)
            {
                await ThrowLoginFailure("Login Failed. Signature not valid.", userName ?? "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }

            //validate users role
            var brokerAccountRole = await Database.FindFirstDeleteRest<BrokerAccountRole>(new FilterFieldEqualTo("UserName", userName));
            if (brokerAccountRole?.Role != AccountRole.SuperAdmin && brokerAccountRole?.Role != AccountRole.GroupAdmin)
            {
                await ThrowLoginFailure("Login Failed. User don't have right to log in.", userName ?? "", Request.RemoteEndPoint, HttpStatusCode.Unauthorized);
            }

            //get users defined companies
            var userOrganizations = await BrokerAccountRole.GetAllOrganizationChildren(brokerAccountRole.OrgName);
            PaymentLinkModule.SetUsernameOrganizations(userName, userOrganizations);

            if (requestBody.TryGetValue("duration", out object durationObject) && int.TryParse(durationObject?.ToString(), out int parsedDuration))
            {
                if (parsedDuration > duration || parsedDuration <= 0)
                {
                    throw new BadRequestException("Min Duration: 0, Max duration is 3600s.");
                }

                duration = parsedDuration;
            }

            JwtToken jwtToken = CreateJwtFactoryToken(userName, duration);

            await Gateway.LoginAuditor.ProcessLoginSuccessful(Request.RemoteEndPoint, "HTTPS");
            Log.Notice("Login success", userName, Request.RemoteEndPoint, "LoginSuccess");

            await Response.Return(new Dictionary<string, object>
            {
                { "jwt", jwtToken.Token },
                { "expires", (int)Math.Round(Convert.ToDateTime(jwtToken.Expiration).Subtract(JSON.UnixEpoch).TotalSeconds) },
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

using POWRS.PaymentLink.Models;
using POWRS.PaymentLink.Module;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Waher.Content;
using Waher.Events;
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
            await EnsureEndpointCanLogin(Request);

            Dictionary<string, object> requestBody = await GetRequestBody(Request);

            string userName = string.Empty;
            string nonce = string.Empty;
            string signature = string.Empty;

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
            var account = await GetEnabledAccount(userName, Request.RemoteEndPoint, true);

            //validate signature
            string domain = Request.Header["Host"];
            Log.Debug($"Domain from header: {domain}", userName, userName, "SmartAdminLogIn");

            string s = $"{userName}:{domain ?? string.Empty}:{nonce}";
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

            int duration = GetDurationParameter(requestBody);
            JwtToken jwtToken = CreateJwtFactoryToken(userName, duration);

            await ProcessLoginSuccess(Request.RemoteEndPoint, userName);

            await Response.Return(new Dictionary<string, object>
            {
                { "jwt", jwtToken.Token },
                { "expires", (int)Math.Round(Convert.ToDateTime(jwtToken.Expiration).Subtract(JSON.UnixEpoch).TotalSeconds) },
            });
        }
    }
}

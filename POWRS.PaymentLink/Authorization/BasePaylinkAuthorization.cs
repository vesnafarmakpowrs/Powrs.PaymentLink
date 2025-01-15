using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Waher.Networking.HTTP;
using Waher.Persistence.Filters;
using Waher.Persistence.Serialization;
using Waher.Persistence;
using Waher.Security.JWT;
using System.Collections.Concurrent;
using Waher.IoTGateway;
using Waher.Content;
using System.Net;
using Waher.Events;

namespace POWRS.PaymentLink.Authorization
{
    public abstract class BasePaylinkAuthorization : HttpAsynchronousResource
    {
        protected static ConcurrentDictionary<string, List<string>> userNameOrganizations = new ConcurrentDictionary<string, List<string>>();

        public BasePaylinkAuthorization(string ResourceName)
            : base(ResourceName) { }

        public override bool HandlesSubPaths => false;

        public override bool UserSessions => false;

        protected void ConfigureResponse(HttpResponse Response)
        {
            Response.SetHeader("Access-Control-Allow-Origin", "*");
        }

        protected async Task<Dictionary<string, object>> GetRequestBody(HttpRequest Request)
        {

            if (!Request.HasData)
            {
                throw new BadRequestException("Request body is missing");
            }

            if (await Request.DecodeDataAsync() is not Dictionary<string, object> requestBody)
            {
                throw new BadRequestException("Expected content response type object.");
            }

            return requestBody;
        }

        protected async Task<Account> GetAccountFromJwtToken(HttpRequest Request)
        {
            string authorizationHeaderValue = Request.Header?.Authorization?.Value;
            if (string.IsNullOrEmpty(authorizationHeaderValue))
            {
                throw new HttpException(401, "Jwt not present in authorization header.");
            }

            if (authorizationHeaderValue.StartsWith("Bearer", StringComparison.OrdinalIgnoreCase))
            {
                authorizationHeaderValue = authorizationHeaderValue[6..].TrimStart();
            }

            JwtFactory jwtFactory = GetJwtFactory();
            JwtToken token;
            try
            {
                token = new(authorizationHeaderValue);
            }
            catch
            {
                throw new HttpException(401, "Jwt token not valid"); 
            }

            if (!jwtFactory.IsValid(token, out Reason reason))
            {
                throw new HttpException(401, $"Jwt token not valid: {reason}");
            }

            if (string.IsNullOrEmpty(token.Subject))
            {
                throw new HttpException(401, "Jwt token not valid");
            }

            string[] subjectParts = token.Subject.Split(new char[] { '@' });
            if (subjectParts.Length != 2)
            {
                throw new HttpException(401, "Jwt token not valid");
            }

            string userName = subjectParts[0];
            return await GetEnabledAccount(userName, Request.RemoteEndPoint);
        }
        protected JwtFactory GetJwtFactory()
        {
            Waher.Runtime.Inventory.Types.TryGetModuleParameter("JWT", out object factory);
            if (factory is not JwtFactory jwtFactory)
            {
                throw new InternalServerErrorException("Unable to initiate jwt creation.");
            }

            return jwtFactory;
        }
        protected JwtToken CreateJwtFactoryToken(string userName, int duration)
        {
            int issuedAt = (int)Math.Round(DateTime.UtcNow.Subtract(JSON.UnixEpoch).TotalSeconds);
            int expires = issuedAt + duration;

            JwtFactory jwtFactory = GetJwtFactory();
            string token = jwtFactory.Create(
                new KeyValuePair<string, object>("jti", Convert.ToBase64String(Gateway.NextBytes(32))),
                new KeyValuePair<string, object>("iss", Gateway.Domain?.Value ?? string.Empty),
                new KeyValuePair<string, object>("sub", userName + "@" + (Gateway.Domain?.Value ?? string.Empty)),
                new KeyValuePair<string, object>("iat", issuedAt),
                new KeyValuePair<string, object>("exp", expires));

            JwtToken jwtToken = new(token);

            return jwtToken;
        }

        protected async Task<Account> GetEnabledAccount(string UserName, string endpoint, bool logIfNotFound = true)
        {
            IEnumerable<GenericObject> accounts = await Database.Find<GenericObject>("BrokerAccounts", 0, 1, new FilterFieldEqualTo("UserName", UserName));
            if (!accounts.Any())
            {
                if (logIfNotFound)
                {
                    Log.Error("Account not found.", UserName, endpoint, "LoginFailure");
                    await Gateway.LoginAuditor.ProcessLoginFailure(endpoint, "HTTPS", DateTime.UtcNow, "Account not found.");
                }

                throw new ForbiddenException("No account found.");
            }

            GenericObject account = accounts.Single();
            if (account["Enabled"] is bool isEnabled && isEnabled == false)
            {
                throw new ForbiddenException("Account is not enabled for agent login.");
            }

            return new Account()
            {
                IsEnabled = true,
                UserName = account["UserName"].ToString(),
                Password = account["Password"].ToString()
            };
        }

        protected async Task ThrowLoginFailure(string Message, string UserName, string Endpoint, HttpStatusCode statusCode)
        {
            Log.Error(Message, UserName, Endpoint, "LoginFailure");
            await Gateway.LoginAuditor.ProcessLoginFailure(Endpoint, "HTTPS", DateTime.UtcNow, UserName);
            throw new HttpException((int)statusCode, Message);
        }

        protected async Task ProcessLoginSuccess(string endpoint, string userName)
        {
            await Gateway.LoginAuditor.ProcessLoginSuccessful(endpoint, "HTTPS");
            Log.Notice("Login success", userName, userName, "LoginSuccess");
        }

        protected int GetDurationParameter(Dictionary<string, object> requestBody)
        {
            int duration = 3600;
            if (requestBody.TryGetValue("Duration", out object durationObject) && int.TryParse(durationObject?.ToString(), out int parsedDuration))
            {
                if (parsedDuration > duration || parsedDuration <= 0)
                {
                    throw new BadRequestException("Min Duration: 0, Max duration is 3600s.");
                }

                duration = parsedDuration;
            }

            return duration;
        }

        protected async Task EnsureEndpointCanLogin(HttpRequest Request)
        {
            DateTime? loginOpportunity = await Gateway.LoginAuditor.GetEarliestLoginOpportunity(Request.RemoteEndPoint, "HTTPS");
            if (loginOpportunity > DateTime.UtcNow)
            {
                throw new TooManyRequestsException($"Login is blocked for: {Request.RemoteEndPoint}. Next login attempt could be made: {loginOpportunity}");
            }
        }
    }
}

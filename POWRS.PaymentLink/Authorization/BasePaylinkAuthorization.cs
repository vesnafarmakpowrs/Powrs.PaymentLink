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
                throw new BadRequestException("Expected JSON object.");
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
            return await GetEnabledAccount(userName);
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

        protected async Task<Account> GetEnabledAccount(string UserName, Func<Task> OnNoAccountFound = null)
        {
            IEnumerable<GenericObject> accounts = await Database.Find<GenericObject>("BrokerAccounts", 0, 1, new FilterFieldEqualTo("UserName", UserName));
            if (!accounts.Any())
            {
                OnNoAccountFound?.Invoke();
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
    }
}

using System;
using System.Threading.Tasks;
using Waher.Networking.HTTP;
using Waher.Persistence.Filters;
using Waher.Persistence;
using Waher.Security.JWT;
using Waher.Security;
using System.Text;
using Waher.Content;
using System.Collections.Generic;

namespace POWRS.PaymentLink.Authorization
{
    public class GenerateAgentApiKey : BasePaylinkAuthorization, IHttpPostMethod
    {
        public bool AllowsPOST => true;

        public GenerateAgentApiKey()
            : base("/Agent/Paylink/GenerateApiKey") { }

        public async Task POST(HttpRequest Request, HttpResponse Response)
        {
            Account BrokerAccount = await GetAccountFromJwtToken(Request);
            AgentApiKey agentApiKey = await Database.FindFirstDeleteRest<AgentApiKey>(new FilterFieldEqualTo("UserName", BrokerAccount.UserName));

            if (agentApiKey != null)
            {
                if (!agentApiKey.CanBeOverriden)
                {
                    throw new HttpException(403, "Api key already exists and could not be re-generated.");
                }

                await Database.Delete(agentApiKey);
            }

            var apiKey = GenerateRandomString(64);
            var apiSecret = GenerateRandomString(128);

            agentApiKey = new AgentApiKey()
            {
                Created = DateTime.UtcNow,
                UserName = BrokerAccount.UserName,
                ApiKey = apiKey,
                Signature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Encoding.UTF8.GetBytes(apiKey), Encoding.UTF8.GetBytes(apiSecret)))
            };

            await Database.Insert(agentApiKey);

            await Response.Return(new Dictionary<string, object>
            {
                { "ApiKey", agentApiKey.ApiKey },
                { "ApiSecret", apiSecret},
                { "CanBeOverriden", agentApiKey.CanBeOverriden},
                { "Created",  agentApiKey.Created},
                { "IsBlocked",  agentApiKey.IsBlocked}
            });
        }

        private string GenerateRandomString(int length)
        {
            string allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/";
            Random random = new();
            char[] randomString = new char[length];

            for (int i = 0; i < length; i++)
            {
                randomString[i] = allowedChars[random.Next(allowedChars.Length)];
            }

            return new string(randomString);
        }
    }
}

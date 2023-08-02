using EDaler;
using Paiwise;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Waher.Content;
using Waher.Content.Xml;
using Waher.Events;
using Waher.IoTGateway;
using Waher.Networking.Sniffers;
using Waher.Networking.XMPP;
using Waher.Networking.XMPP.Contracts;
using Waher.Persistence;
using Waher.Persistence.Filters;
using Waher.Persistence.Serialization;
using Waher.Runtime.Profiling.Events;
using Waher.Runtime.Settings;
using Waher.Security;
using POWRS.PaymentLink.Model;

namespace POWRS.Payout
{
    /// <summary>
    /// Open Payments Platform service
    /// </summary>
    public class PayoutService
    {
        private readonly string ComponentJid = "edaler.lab.neuron.vaulter.rs";
        private XmppClient _xmppClient;
        private ContractsClient _contractsClient;
        private EDalerClient _edalerClient;
        private string PaymentContractId;
        private Token PaymentToken;
        private string PaymentJwtToken;

        /// <summary>
        /// Processes payment for buying eDaler.
        ///  <param name="ContractID">Tab ID</param>
        /// <param name="TabId">Tab ID</param>
		/// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
        /// <returns>Result of operation.</returns>
        public async Task<PaymentResult> BuyEDaler(string ContractID, string BankAccount, string TabId, bool RequestFromMobilePhone, string RemoteEndpoint)
        {
            try
            {
                Log.Informational("PaymentLinkBuyEDaler started");

                bool isConnected = await ConnectClientAsync();

                if (!isConnected)
                {
                    Log.Informational("Unable to Connect to xmppClient");
                    return new PaymentResult("Unable to Connect to xmppClient");
                }

                string Jwt = await LoginToUserAgent();

                if (string.IsNullOrEmpty(Jwt))
                {
                    Log.Informational("Unable to LoginToUserAgent");
                    return new PaymentResult("Unable to LoginToUserAgent");
                }


                Token Token = await GetToken(ContractID, Jwt);

                if (Token == null)
                {
                    Log.Informational("No token for contractId: " + ContractID);
                    return new PaymentResult("No token for contractId: " + ContractID);
                }

                if (!Token.IsValid())
                {
                    Log.Informational("Parameters for token are not valid.");
                    return new PaymentResult("Parameters for token are not valid");
                }

                string ContractIdBuyEdaler = await CreateBuyEdalerContract(Jwt, Token, BankAccount, TabId, RequestFromMobilePhone);

                PaymentContractId = ContractIdBuyEdaler;
                PaymentToken = Token;
                PaymentJwtToken = Jwt;

                await SignContract(ContractIdBuyEdaler, Jwt);

                return new PaymentResult("Contract created ");
            }
            catch (System.Exception ex)
            {
                await DisplayUserMessage(TabId, ex.Message);
                return new PaymentResult(ex.Message);
            }
        }
        private async Task<bool> ConnectClientAsync()
        {
            try
            {
                int Port = 5222;    // Default XMPP Client-to-Server port.

                string Account = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUser", string.Empty);
                string Password = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserPass", string.Empty);

                XmppCredentials XmppCredentials = new XmppCredentials
                {
                    Port = Port,
                    Host = Gateway.Domain,
                    Password = Password,
                    Account = Account
                };
                Log.Informational("XmppClient create");

                this._xmppClient = new XmppClient(XmppCredentials, "en", System.Reflection.Assembly.GetEntryAssembly(), new InMemorySniffer(250))
                {
                    TrustServer = true
                };
                Log.Informational("XmppClient trust");

                this._xmppClient.AllowEncryption = true;
                this._xmppClient.OnStateChanged += this.Client_OnStateChanged;
                this._xmppClient.OnConnectionError += this.Client_OnConnectionError;
                this._xmppClient.Connect(Gateway.Domain);

                this._contractsClient = new ContractsClient(this._xmppClient, ComponentJid);

                this._edalerClient = new EDalerClient(this._xmppClient, this._contractsClient, ComponentJid);
                this._edalerClient.BalanceUpdated += EDalerClient_BalanceUpdated;

                Log.Informational("XmppClient connected");
                return true;
            }
            catch (System.Exception ex)
            {
                Log.Informational("client connect" + ex.Message);
            }

            return false;
        }

        private Task Client_OnStateChanged(object Sender, XmppState NewState)
        {
            Log.Informational("Client_OnStateChanged" + NewState.ToString());
            return Task.CompletedTask;
        }
        private Task Client_OnConnectionError(object Sender, System.Exception Exception)
        {

            Log.Informational("Client_OnConnectionError" + Exception.Message);
            return Task.CompletedTask;
        }

        private async Task EDalerClient_BalanceUpdated(object Sender, BalanceEventArgs e)
        {
            Log.Informational("EDalerClient_BalanceUpdated" + e.Balance.Amount.ToString());

            string ContractId = "iotsc:" + PaymentContractId;
            Log.Informational("Wallet_BalanceUpdated: " + e.Balance.Event.Message);

            Log.Informational("BalanceMessage: " + e.Balance?.Event?.Message ?? "Message is null");
            if (e.Balance.Event.Message == ContractId)
            {
                try
                {
                    Log.Informational("Amount: " + e.Balance.Amount ?? "Amount is null");
                    Log.Informational("Currency: " + e.Balance.Currency ?? "Currency is null");

                    await UpdateContractWithTransactionStatusAsync();
                    PaymentContractId = string.Empty;
                }
                catch (System.Exception ex)
                {
                    Log.Informational(ex.Message);
                }
            }
        }

        private async Task DisplayUserMessage(string tabId, string message, bool isSuccess = false)
        {
            Log.Informational("DisplayUserMessage  " + message);
            await ClientEvents.PushEvent(new string[] { tabId }, "DisplayTransactionResult",
                    JSON.Encode(new Dictionary<string, object>()
                    {
                        { "ok", isSuccess },
                        { "message", message },
                    }, false), true);
        }

        public class RandomBytesGenerator
        {
            public static byte[] GetRandomBytes(int length)
            {
                // Create a byte array to store the random bytes
                byte[] randomBytes = new byte[length];

                // Create a Random object to generate random numbers
                Random random = new Random();

                // Generate random bytes and store them in the byte array
                random.NextBytes(randomBytes);

                return randomBytes;
            }
        }

        private static byte[] Utf8Encode(string input)
        {
            // Create an instance of the UTF-8 encoding
            Encoding utf8 = Encoding.UTF8;

            // Encode the input string to a byte array in UTF-8 format
            byte[] encodedBytes = utf8.GetBytes(input);

            return encodedBytes;
        }

        private async Task UpdateContractWithTransactionStatusAsync()
        {
            try
            {
                string fullPaymentUri = await CreateFullPaymentUri(PaymentToken.OwnerJid, PaymentToken.Value, PaymentToken.Currency, 364, "nfeat:" + PaymentToken.TokenId);
                Log.Informational("FullPaymentUri: " + fullPaymentUri);

                string Signiture = await GetSigniture(fullPaymentUri, PaymentJwtToken);
                fullPaymentUri += ";s=" + Signiture;
                await SendPaymentUri(fullPaymentUri, PaymentJwtToken);
            }
            catch (System.Exception ex)
            {
                Log.Error(ex);
            }
        }

        private async Task<string> LoginToUserAgent()
        {
            try
            {
                string UserName = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUser", string.Empty);
                string Password = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserPass", string.Empty);

                byte[] randomBytes = RandomBytesGenerator.GetRandomBytes(32);

                string Nonce = Convert.ToBase64String(randomBytes);
                string S = UserName + ":" + Gateway.Domain + ":" + Nonce;

                string Signature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Password), Utf8Encode(S)));

                object Result = await InternetContent.PostAsync(
                    new Uri("https://" + Gateway.Domain + "/Agent/Account/Login"),
                    new Dictionary<string, object>()
                    {
                        { "userName", UserName },
                        { "nonce", Nonce },
                        { "signature", Signature },
                        { "seconds", 3600 },
                    },
                    new KeyValuePair<string, string>("Accept", "application/json"));

                if (Result is Dictionary<string, object> Response)
                    if (Response.TryGetValue("jwt", out object ObjJwt) && ObjJwt is string Jwt)
                    {
                        return Jwt;
                    }
            }
            catch (System.Exception ex)
            {
                Log.Error(ex);
            }

            return null;
        }

        private async Task<object> SendXmlNote(string TokenId, string Jwt)
        {
            string xmlNote = "<PaymentCompleted xmlns='https://neuron.vaulter.rs/Downloads/EscrowRebnis.xsd' />";

            object ResultXmlNote = await InternetContent.PostAsync(
            new Uri("https://" + Gateway.Domain + "/Agent/Tokens/AddXmlNote"),
             new Dictionary<string, object>()
                {
                        { "tokenId", TokenId },
                        { "note", xmlNote },
                        { "personal", false }
                },
            new KeyValuePair<string, string>("Accept", "application/json"),
            new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));

            Log.Informational("ResultXmlNote" + ResultXmlNote);
            return ResultXmlNote;
        }

        private async Task<object> SendPaymentUri(string PaymentUri, string Jwt)
        {
            object ResultPaymentUri = await InternetContent.PostAsync(
             new Uri("https://" + Gateway.Domain + "/Agent/Wallet/ProcessEDalerUri"),
              new Dictionary<string, object>()
                 {
                            { "uri", PaymentUri },
                 },
             new KeyValuePair<string, string>("Accept", "application/json"),
             new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));

            Log.Informational("ResultPaymentUri" + ResultPaymentUri);
            return ResultPaymentUri;
        }

        private async Task<Token> GetToken(string ContractId, string Jwt)
        {
            try
            {
                object TokensResult = await InternetContent.PostAsync(
                 new Uri("https://" + Gateway.Domain + "/Agent/Tokens/GetContractTokens"),
                  new Dictionary<string, object>()
                     {
                            { "contractId", ContractId },
                            { "offset", null },
                            { "maxCount", null },
                            { "references", false },
                     },
                 new KeyValuePair<string, string>("Accept", "application/json"),
                 new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));

                if (TokensResult is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Tokens", out object ObjTokens) && ObjTokens is Dictionary<string, object> Tokens)
                    {
                        if (Tokens.TryGetValue("token", out object ObjToken) && ObjToken is Dictionary<string, object> Token)
                        {
                            Log.Informational("Token: " + Token);
                            Token token = new Token();

                            if (Token.TryGetValue("id", out object ObjTokenId) && ObjTokenId is string TokenId)
                            {
                                Log.Informational("id: " + TokenId);
                                token.TokenId = TokenId;
                            }
                            if (Token.TryGetValue("value", out object ObjTokenValue) && ObjTokenValue is string Value)
                            {
                                Log.Informational("value: " + Value);
                                token.Value = Convert.ToDecimal(Value);
                            }
                            if (Token.TryGetValue("currency", out object ObjTokenCurrency) && ObjTokenCurrency is string Currency)
                            {
                                Log.Informational("currency: " + Currency);
                                token.Currency = Currency;
                            }
                            if (Token.TryGetValue("owner", out object ObjTokenOwner) && ObjTokenOwner is string Owner)
                            {
                                Log.Informational("owner: " + Owner);
                                token.Owner = Owner;
                            }
                            if (Token.TryGetValue("ownerJid", out object ObjTokenOwnerJid) && ObjTokenOwnerJid is string OwnerJid)
                            {
                                Log.Informational("ownerJid: " + OwnerJid);
                                token.OwnerJid = OwnerJid;
                            }

                            return token;
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                Log.Informational("GetToken " + ex.Message);
            }
            return null;
        }

        private async Task<string> GetSigniture(string PaymentUri, string Jwt)
        {
            try
            {
                string LegalId = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserLegalId", string.Empty);
                string UserName = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUser", string.Empty);
                string Password = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserPass", string.Empty);
                string KeyId = await RuntimeSettings.GetAsync("POWRS.PaymentLink.KeyId", string.Empty);
                string Secret = await RuntimeSettings.GetAsync("POWRS.PaymentLink.Secret", string.Empty);

                string DataBase64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(PaymentUri));
                string LocalName = "ed448";
                string Namespace = "urn:ieee:iot:e2e:1.0";

                string s1 = UserName + ":" + Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
                Log.Informational("s1: " + s1);
                string KeySignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Secret), Utf8Encode(s1)));
                Log.Informational("KeySignature: " + KeySignature);

                string s2 = s1 + ":" + KeySignature + ":" + DataBase64 + ":" + LegalId;
                Log.Informational("s2: " + s2);

                string RequestSignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Password), Utf8Encode(s2)));
                Log.Informational("RequestSignature: " + RequestSignature);

                object ResultSignature = await InternetContent.PostAsync(
                 new Uri("https://" + Gateway.Domain + "/Agent/Legal/SignData"),
                  new Dictionary<string, object>()
                     {
                            { "keyId", KeyId },
                            { "legalId", LegalId },
                            { "dataBase64", DataBase64},
                            { "keySignature", KeySignature },
                            { "requestSignature", RequestSignature },
                     },
                 new KeyValuePair<string, string>("Accept", "application/json"),
                 new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));


                Log.Informational("ResultSignature " + JSON.Encode(ResultSignature, false).ToString());
                if (ResultSignature is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Signature", out object ObjSignature) && ObjSignature is string Signature)
                        return Signature;
                }
            }
            catch (System.Exception ex)
            {
                Log.Informational("GetSigniture errorMessage: " + ex.Message);
            }
            return String.Empty;
        }

        private async Task<string> SignContract(string ContractId, string Jwt)
        {
            try
            {
                string UserName = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUser", string.Empty);
                string Password = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserPass", string.Empty);
                string LegalId = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserLegalId", string.Empty);

                string KeyId = await RuntimeSettings.GetAsync("POWRS.PaymentLink.KeyId", string.Empty);
                string Secret = await RuntimeSettings.GetAsync("POWRS.PaymentLink.Secret", string.Empty);

                string LocalName = "ed448";
                string Namespace = "urn:ieee:iot:e2e:1.0";

                string s1 = UserName + ":" + Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
                string KeySignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Secret), Utf8Encode(s1)));

                string Role = "Buyer";
                string Nonce = Convert.ToBase64String(RandomBytesGenerator.GetRandomBytes(32));

                string s2 = s1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;

                string RequestSignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Password), Utf8Encode(s2)));
                Log.Informational("sign Contract: " + RequestSignature);

                object ResultSignature = await InternetContent.PostAsync(
                 new Uri("https://" + Gateway.Domain + "/Agent/Legal/SignContract"),
                  new Dictionary<string, object>()
                     {
                            { "keyId", KeyId },
                            { "legalId", LegalId },
                            { "contractId", ContractId},
                            { "role", Role},
                            { "nonce", Nonce },
                            { "keySignature", KeySignature },
                            { "requestSignature", RequestSignature },
                     },
                 new KeyValuePair<string, string>("Accept", "application/json"),
                 new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));

                //Log.Informational("ResultSignature " + JSON.Encode(ResultSignature, false).ToString());
                if (ResultSignature is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Contract", out object ObjSignature) && ObjSignature is string Signature)
                        return Signature;
                }
            }
            catch (System.Exception ex)
            {
                Log.Informational("Sign Contract errorMessage: " + ex.Message);
            }
            return String.Empty;
        }

        private async Task<string> CreateBuyEdalerContract(string Jwt, Token token, string BankAccount, string TabId, bool requestFromMobilePhone)
        {
            try
            {
                string OwnerId = "2c523e34-c122-58ec-e81d-570f5370f803@legal.neuron.vaulter.rs";

                string LegalIdOPPUser = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserLegalId", string.Empty);
                string BuyEDalerTemplateContractId = await RuntimeSettings.GetAsync("POWRS.PaymentLink.BuyEDalerTemplateContractId", string.Empty);

                List<IDictionary<CaseInsensitiveString, object>> PartsList = new List<IDictionary<CaseInsensitiveString, object>>()
                 {
                  new Dictionary<CaseInsensitiveString, object>()
                    {
                        { "role" , "Buyer" },
                        { "legalId" , LegalIdOPPUser }
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {
                         { "role" , "TrustProvider" },
                         { "legalId" , OwnerId }
                    }
                };

                List<IDictionary<CaseInsensitiveString, object>> ParametersList = new List<IDictionary<CaseInsensitiveString, object>>()
                {
                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Amount" },
                         { "value" , token.Value }
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Currency" },
                         { "value" , token.Currency }
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Account" },
                         { "value" , BankAccount}
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Message" },
                         { "value" , "Vaulter" }
                    },
                   new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "requestFromMobilePhone" },
                         { "value" , "false" }
                    },
                     new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "tabId" },
                         { "value" , TabId }
                    }
                };

                object ResultContractBuyEdaler = await InternetContent.PostAsync(
                 new Uri("https://" + Gateway.Domain + "/Agent/Legal/CreateContract"),
                  new Dictionary<string, object>()
                     {
                            { "templateId", BuyEDalerTemplateContractId },
                            { "visibility", "CreatorAndParts" },
                            { "Parts", PartsList},
                            { "Parameters", ParametersList }
                     },
                 new KeyValuePair<string, string>("Accept", "application/json"),
                 new KeyValuePair<string, string>("Authorization", "Bearer " + Jwt));

                if (ResultContractBuyEdaler is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Contract", out object ObjContract) && ObjContract is Dictionary<string, object> Contract)
                        if (Contract.TryGetValue("id", out object ObjContractId) && ObjContractId is string ContractId)
                        {
                            Log.Informational("buyeDalerContractCreated" + ContractId);

                            return ContractId;
                        }
                }

            }
            catch (System.Exception ex)
            {
                Log.Informational("CreateBuyEdalerContract errorMessage: " + ex.Message);
            }
            return String.Empty;
        }

        public async Task<string> CreateFullPaymentUri(string ToBareJid, decimal Amount,
           CaseInsensitiveString Currency, int ValidNrDays, string Message)
        {
            string UserName = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUser", string.Empty);
            string loggedUserJid = UserName + "@" + Gateway.Domain;

            StringBuilder Uri = new StringBuilder();
            DateTime Created = DateTime.UtcNow;
            DateTime Expires = DateTime.Today.AddDays(ValidNrDays);
            Guid Id = Guid.NewGuid();

            Uri.Append("edaler:id=");
            Uri.Append(Id.ToString());

            Uri.Append(";f=");
            Uri.Append(XML.Encode(loggedUserJid));

            Uri.Append(";t=");
            Uri.Append(XML.Encode(ToBareJid));

            Uri.Append(";am=");
            Uri.Append(CommonTypes.Encode(Amount));

            Uri.Append(";cu=");
            Uri.Append(XML.Encode(Currency));

            Uri.Append(";cr=");
            Uri.Append(XML.Encode(Created, false));

            Uri.Append(";ex=");
            Uri.Append(XML.Encode(Expires, true));

            if (!string.IsNullOrEmpty(Message))
            {
                Uri.Append(";m=");
                Uri.Append(Convert.ToBase64String(Encoding.UTF8.GetBytes(Message)));
            }

            return Uri.ToString();
        }
    }
}

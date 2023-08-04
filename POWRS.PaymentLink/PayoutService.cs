using EDaler;
using Paiwise;
using System;
using System.Collections.Generic;
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
using Waher.Runtime.Settings;
using Waher.Security;
using POWRS.PaymentLink.Model;
using Waher.Networking.HTTP;
using LegalLab.Models.Network.Events;

namespace POWRS.Payout
{
    /// <summary>
    /// Open Payments Platform service
    /// </summary>
    public class PayoutService : IDisposable
    {
        private readonly string ComponentJid = "edaler." + Gateway.Domain;
        private XmppClient _xmppClient;
        private ContractsClient _contractsClient;
        private EDalerClient _edalerClient;

        private Token CurrentToken = null;
        private string BuyEdalerContractId;
        private string JwtToken;
        private decimal totalAmountPaid;

        public PayoutService()
        {
            if (!ConnectClient())
            {
                Log.Informational("Unable to login to xmppClient");
                throw new Exception("Unable to login to xmppClient");
            }
            
            Log.Register(new PaymentCompletedEventSink());
        }

        private async Task<bool> IsConnected()
        {
            if (this._xmppClient is null)
            {
                return false;
            }

            if (this._xmppClient.State == XmppState.Connected)
            {
                return true;
            }

            await _xmppClient.WaitStateAsync(3000, XmppState.Connected);
            return this._xmppClient?.State == XmppState.Connected;
        }

        /// <summary>
        /// Processes payment for buying eDaler.
        /// <param name="ContractID">Tab ID</param>
        /// <param name="BankAccount">Tab ID</param>
        /// <param name="TabId">Tab ID</param>
		/// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
        /// <param name="RemoteEndpoint">Tab ID</param>
        /// <returns>Result of operation.</returns>
        public async Task<PaymentResult> BuyEDaler(string BuyEdalerTemplateId, string ContractID, string BankAccount, string TabId, bool RequestFromMobilePhone, string RemoteEndpoint)
        {
            try
            {
                Log.Informational("PaymentLinkBuyEDaler started");

                if (string.IsNullOrEmpty(BuyEdalerTemplateId))
                {
                    Log.Informational("BuyEdalerTemplateId could not be empty");
                    return new PaymentResult("BuyEdalerTemplateId could not be empty");
                }
                if (string.IsNullOrEmpty(ContractID))
                {
                    Log.Informational("ContractID could not be empty");
                    return new PaymentResult("ContractID could not be empty");
                }
                if (string.IsNullOrEmpty(BankAccount))
                {
                    Log.Informational("BankAccount could not be empty");
                    return new PaymentResult("BankAccount could not be empty");
                }

                if (!await IsConnected())
                {
                    Log.Informational("Unable to Connect to xmppClient");
                    return new PaymentResult("Unable to Connect to xmppClient");
                }

                JwtToken = await LoginToUserAgent();

                if (string.IsNullOrEmpty(JwtToken))
                {
                    Log.Informational("Unable to LoginToUserAgent");
                    return new PaymentResult("Unable to LoginToUserAgent");
                }

                Token Token = await GetToken(ContractID, JwtToken);

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

                string ContractIdBuyEdaler = await CreateBuyEdalerContract(BuyEdalerTemplateId, JwtToken, Token, BankAccount, TabId, RequestFromMobilePhone);

                CurrentToken = Token;
                BuyEdalerContractId = ContractIdBuyEdaler;

                await SignContract(ContractIdBuyEdaler, JwtToken);

                return new PaymentResult("Contract created ");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                await DisplayUserMessage(TabId, ex.Message);
                return new PaymentResult(ex.Message);
            }
        }

        private bool ConnectClient()
        {
            try
            {
                int Port = 5222;    // Default XMPP Client-to-Server port.

                string Account = RuntimeSettings.Get("POWRS.PaymentLink.OPPUser", string.Empty);
                string Password = RuntimeSettings.Get("POWRS.PaymentLink.OPPUserPass", string.Empty);

                XmppCredentials XmppCredentials = new XmppCredentials
                {
                    Port = Port,
                    Host = Gateway.Domain,
                    Password = Password,
                    Account = Account
                };
                Log.Informational("XmppClient create");

                _xmppClient = new XmppClient(XmppCredentials, "en", System.Reflection.Assembly.GetEntryAssembly(), new InMemorySniffer(250))
                {
                    TrustServer = true
                };
                Log.Informational("XmppClient trust");

                _xmppClient.AllowEncryption = true;
                _xmppClient.Connect(Gateway.Domain);

                _contractsClient = new ContractsClient(_xmppClient, ComponentJid);

                _edalerClient = new EDalerClient(_xmppClient, _contractsClient, ComponentJid);
                _edalerClient.BalanceUpdated += EDalerClient_BalanceUpdated;

                return true;
            }
            catch (Exception ex)
            {
                Log.Informational("client connect" + ex.Message);
            }

            return false;
        }

        private async Task EDalerClient_BalanceUpdated(object Sender, BalanceEventArgs e)
        {
            try
            {
                if (CurrentToken is null)
                {
                    Log.Error(new Exception("Token is null"));
                    return;
                }

                if (e.Balance?.Event?.Change == null)
                {
                    Log.Error(new Exception("Change could not be null"));
                    return;
                }

              //  Log.Informational("Change: " + e.Balance.Event.Change);
              //  Log.Informational("TransactionId: " + e.Balance.Event.TransactionId);
              //  Log.Informational("Message: " + e.Balance.Event.Message);

                if (e.Balance.Event.Change > 0)
                {
                    await EdalerAddedInWallet(e.Balance.Event);
                }
            }
            catch (Exception ex)
            {
                Log.Informational(ex.Message);
            }
            finally
            {
                Log.Unregister(new PaymentCompletedEventSink());
                Dispose();
            }
        }

        private async Task EdalerAddedInWallet(AccountEvent accountEvent)
        {
            string contract = "iotsc:" + BuyEdalerContractId;

            if (string.IsNullOrEmpty(accountEvent.Message) || contract != accountEvent.Message)
            {
                return;
            }

            totalAmountPaid = accountEvent.Change;
            await UpdateContractWithTransactionStatusAsync(CurrentToken);
        }

        private async Task DisplayUserMessage(string tabId, string message, bool isSuccess = false)
        {
            //Log.Informational("DisplayUserMessage  " + message);
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

        private async Task UpdateContractWithTransactionStatusAsync(Token PaymentToken)
        {
            try
            {
                string fullPaymentUri = await CreateFullPaymentUri(PaymentToken.OwnerJid, PaymentToken.Value, PaymentToken.Currency, 364, "nfeat:" + PaymentToken.TokenId);
               // Log.Informational("FullPaymentUri: " + fullPaymentUri);

                string Signiture = await GetSigniture(fullPaymentUri, JwtToken);
                fullPaymentUri += ";s=" + Signiture;
                await SendPaymentUri(fullPaymentUri, JwtToken);
            }
            catch (Exception ex)
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

        private async Task<object> SendPaymentCompletedXmlNote()
        {
            string nmspc = $"https://{Gateway.Domain}/Downloads/EscrowRebnis.xsd";
            string xmlNote = $"<PaymentCompleted xmlns='{nmspc}' amountPaid='{XML.Encode(totalAmountPaid.ToString())}'/>";

            object ResultXmlNote = await InternetContent.PostAsync(
            new Uri("https://" + Gateway.Domain + "/Agent/Tokens/AddXmlNote"),
             new Dictionary<string, object>()
                {
                        { "tokenId", CurrentToken.TokenId },
                        { "note", xmlNote },
                        { "personal", false }
                },
            new KeyValuePair<string, string>("Accept", "application/json"),
            new KeyValuePair<string, string>("Authorization", "Bearer " + JwtToken));

            //Log.Informational("ResultXmlNote" + ResultXmlNote);
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

            //Log.Informational("ResultPaymentUri" + ResultPaymentUri);
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
                            //Log.Informational("Token: " + Token);
                            Token token = new Token();

                            if (Token.TryGetValue("id", out object ObjTokenId) && ObjTokenId is string TokenId)
                            {
                                //Log.Informational("id: " + TokenId);
                                token.TokenId = TokenId;
                            }
                            if (Token.TryGetValue("value", out object ObjTokenValue) && ObjTokenValue is string Value)
                            {
                                //Log.Informational("value: " + Value);
                                token.Value = Convert.ToDecimal(Value);
                            }
                            if (Token.TryGetValue("currency", out object ObjTokenCurrency) && ObjTokenCurrency is string Currency)
                            {
                                //Log.Informational("currency: " + Currency);
                                token.Currency = Currency;
                            }
                            if (Token.TryGetValue("owner", out object ObjTokenOwner) && ObjTokenOwner is string Owner)
                            {
                                //Log.Informational("owner: " + Owner);
                                token.Owner = Owner;
                            }
                            if (Token.TryGetValue("ownerJid", out object ObjTokenOwnerJid) && ObjTokenOwnerJid is string OwnerJid)
                            {
                               // Log.Informational("ownerJid: " + OwnerJid);
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
                string KeySignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Secret), Utf8Encode(s1)));

                string s2 = s1 + ":" + KeySignature + ":" + DataBase64 + ":" + LegalId;

                string RequestSignature = Convert.ToBase64String(Hashes.ComputeHMACSHA256Hash(Utf8Encode(Password), Utf8Encode(s2)));

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

                if (ResultSignature is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Contract", out object ObjSignature) && ObjSignature is string Signature)
                        return Signature;
                }
            }
            catch (Exception ex)
            {
                Log.Informational("Sign Contract errorMessage: " + ex.Message);
            }
            return String.Empty;
        }

        private async Task<string> CreateBuyEdalerContract(string BuyEdalerTemplateId, string Jwt, Token token, string BankAccount, string TabId, bool requestFromMobilePhone)
        {
            try
            {
                string OwnerId = "2c523e34-c122-58ec-e81d-570f5370f803@legal.neuron.vaulter.rs";
                string LegalIdOPPUser = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserLegalId", string.Empty);

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
                            { "templateId", BuyEdalerTemplateId },
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
            catch (Exception ex)
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

            Uri.Append("edaler:id=");
            Uri.Append(Guid.NewGuid().ToString());

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

        public void Dispose()
        {
            this._edalerClient?.Dispose();
            this._contractsClient?.Dispose();
            this._xmppClient.Dispose();
            this.CurrentToken = null;
            this.BuyEdalerContractId = null;
            this.JwtToken = null;
        }
    }
}

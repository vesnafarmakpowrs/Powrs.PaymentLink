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

        private InitiatePaymentRequest _ongoingPaymentRequest;
        private string _ongoingBuyEdalerContractId;
        private string JwtToken;

        public PayoutService()
        {
            if (!ConnectClient())
            {
                Log.Informational("Unable to login to xmppClient");
                throw new Exception("Unable to login to xmppClient");
            }

            // Log.Register(new PaymentCompletedEventSink());
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
        public async Task<PaymentResult> InitiatePayment(InitiatePaymentRequest Request)
        {
            try
            {
                Log.Informational("PaymentLinkBuyEDaler started");

                if (Request is null)
                {
                    return new PaymentResult("Payment request could not be empty");
                }

                string validationMessage = Request.Validate();

                if (!string.IsNullOrEmpty(validationMessage))
                {
                    Log.Informational(validationMessage);
                    return new PaymentResult(validationMessage);
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

                await SendServiceProviderSelectedXmlNote(Request);

                CreateContractResult CreateContractResult = await CreateBuyEdalerContract(JwtToken, Request);

                if (!CreateContractResult.IsSuccess)
                {
                    Log.Error(CreateContractResult.ErrorMessage + "ContractId: " + CreateContractResult.ContractId ?? string.Empty);
                    return new PaymentResult(CreateContractResult.ErrorMessage);
                }

                _ongoingPaymentRequest = Request;
                _ongoingBuyEdalerContractId = CreateContractResult.ContractId;

                await SignContract(CreateContractResult.ContractId, JwtToken);

                return new PaymentResult("Contract created ");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                await DisplayUserMessage(Request.TabId, ex.Message);
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

                _xmppClient = new XmppClient(XmppCredentials, "en", System.Reflection.Assembly.GetEntryAssembly(), new InMemorySniffer(250))
                {
                    TrustServer = true,
                    AllowEncryption = true
                };

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
            if (_ongoingPaymentRequest is null || string.IsNullOrEmpty(_ongoingBuyEdalerContractId))
            {
                return;
            }

            var balanceEvent = e.Balance.Event;
            string contract = "iotsc:" + _ongoingBuyEdalerContractId;

            if (string.IsNullOrEmpty(balanceEvent.Message) || contract != balanceEvent.Message)
            {
                return;
            }

            if (balanceEvent.Change > 0)
            {
                await UpdateContractWithTransactionStatusAsync(e.Balance);
            }
        }

        private async Task DisplayUserMessage(string tabId, string message, bool isSuccess = false)
        {
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
                byte[] randomBytes = new byte[length];
                Random random = new Random();
                random.NextBytes(randomBytes);

                return randomBytes;
            }
        }

        private static byte[] Utf8Encode(string input)
        {
            Encoding utf8 = Encoding.UTF8;
            byte[] encodedBytes = utf8.GetBytes(input);

            return encodedBytes;
        }

        private async Task UpdateContractWithTransactionStatusAsync(Balance Balance)
        {
            try
            {
                string fullPaymentUri = await CreateFullPaymentUri(_ongoingPaymentRequest.OwnerJid,
                        Balance.Event.Change,
                        Balance.Currency,
                        364,
                        "nfeat:" + _ongoingPaymentRequest.TokenId);

                string Signiture = await GetSigniture(fullPaymentUri, JwtToken);
                fullPaymentUri += ";s=" + Signiture;

                await SendPaymentUri(fullPaymentUri, JwtToken);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
            finally
            {
                Dispose();
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
                        { "seconds", 60 },
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

        private async Task<object> SendServiceProviderSelectedXmlNote(InitiatePaymentRequest Request)
        {
            try
            {
                string nmspc = $"https://{Gateway.Domain}/Downloads/EscrowRebnis.xsd";
                string xmlNote = $"<ServiceProviderSelected xmlns='{nmspc}' buyerBankAccount='{Request.BankAccount}' buyEdalerServiceProviderId='{Request.ServiceProviderId}' buyEdalerServiceProviderType='{Request.ServiceProviderType}'/>";

                object ResultXmlNote = await InternetContent.PostAsync(
                new Uri("https://" + Gateway.Domain + "/Agent/Tokens/AddXmlNote"),
                 new Dictionary<string, object>()
                    {
                        { "tokenId", Request.TokenId },
                        { "note", xmlNote },
                        { "personal", false }
                    },
                new KeyValuePair<string, string>("Accept", "application/json"),
                new KeyValuePair<string, string>("Authorization", "Bearer " + JwtToken));

                return ResultXmlNote;
            }
            catch (System.Exception ex)
            {
                Log.Error(ex);
            }
            return null;
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

            return ResultPaymentUri;
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
                    {
                        return Signature;
                    }
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

        private async Task<CreateContractResult> CreateBuyEdalerContract(string Jwt, InitiatePaymentRequest Request)
        {
            CreateContractResult Result = new CreateContractResult();
            try
            {
                string TrustProvider = await RuntimeSettings.GetAsync("POWRS.PaymentLink.TrustProviderLegalId", string.Empty); ;
                string LegalIdOPPUser = await RuntimeSettings.GetAsync("POWRS.PaymentLink.OPPUserLegalId", string.Empty);

                Log.Informational("TrustProvider: " + TrustProvider);
                Log.Informational("LegalIdOPPUser:" + LegalIdOPPUser);

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
                         { "legalId" , TrustProvider }
                    }
                };

                List<IDictionary<CaseInsensitiveString, object>> ParametersList = new List<IDictionary<CaseInsensitiveString, object>>()
                {
                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Amount" },
                         { "value" , Request.Amount }
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Currency" },
                         { "value" , Request.Currency }
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Account" },
                         { "value" , Request.BankAccount}
                    },

                  new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "Message" },
                         { "value" , "Vaulter" }
                    },
                   new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "requestFromMobilePhone" },
                         { "value" , Request.RequestFromMobilePhone.ToString().ToLowerInvariant() }
                    },
                     new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "tabId" },
                         { "value" , Request.TabId }
                    },
                     new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "callBackUrl" },
                         { "value" , Request.CallBackUrl }
                    },
                      new Dictionary<CaseInsensitiveString, object>()
                    {    { "name" , "personalNumber" },
                         { "value" , Request.PersonalNumber }
                    }
                };

                object ResultContractBuyEdaler = await InternetContent.PostAsync(
                 new Uri("https://" + Gateway.Domain + "/Agent/Legal/CreateContract"),
                  new Dictionary<string, object>()
                     {
                            { "templateId", Request.BuyEdalerTemplateId },
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
                            Result.ContractId = ContractId;
                        }
                }

            }
            catch (Exception ex)
            {
                Result.ErrorMessage = ex.Message;
            }

            return Result;
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
            try
            {
                this._edalerClient?.Dispose();
                this._contractsClient?.Dispose();
                this._xmppClient.Dispose();
                this._ongoingPaymentRequest = null;
                this._ongoingBuyEdalerContractId = null;
                this.JwtToken = null;
                _edalerClient.BalanceUpdated -= EDalerClient_BalanceUpdated;
            }
            catch (Exception ex)
            {
                Log.Error("Unable to dispose payout service. Error: " + ex.Message);
            }
        }
    }
}

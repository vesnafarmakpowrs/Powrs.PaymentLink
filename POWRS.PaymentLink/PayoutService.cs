using NeuroFeatures;
using Paiwise;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using TAG.Networking.OpenPaymentsPlatform;
using TAG.Payments.OpenPaymentsPlatform;
using Waher.Content;
using Waher.Content.Html;
using Waher.Content.Html.Elements;
using Waher.Content.Xml;
using Waher.Events;
using Waher.IoTGateway;
using Waher.Persistence;
using Waher.Persistence.Filters;
using Waher.Persistence.Serialization;
using Waher.Runtime.Inventory;
using Waher.Runtime.Settings;
using Waher.Script;
using Waher.Script.Content.Functions.Encoding;
using Waher.Script.Functions.Vectors;
using Waher.Security;

namespace POWRS.Payout
{
    public class Token
    {
        public string TokenId { get; set; }
        public decimal Value { get; set; }
        public string Currency { get; set; }
        public string OwnerJid { get; set; }
        public string Owner { get; set; }

        public bool IsValid()
        {
            if (string.IsNullOrEmpty(TokenId) ||
              string.IsNullOrEmpty(Currency) ||
              string.IsNullOrEmpty(OwnerJid) ||
              string.IsNullOrEmpty(Owner) ||
              Value <= 0)
            {
                return false;
            }

            return true;
        }
    }

    /// <summary>
    /// Open Payments Platform service
    /// </summary>
    public class PayoutService
    {
        private static readonly Dictionary<string, string> buyTemplateIdsProduction = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2bebf3fe-151c-76cd-180b-8e272c027c0d@legal.paiwise.tagroot.io" },
            { "ESSESESS", "2bebf416-151c-76d0-180b-8e272c8a8890@legal.paiwise.tagroot.io" },
            { "HANDSESS", "2bebf426-151c-76d2-180b-8e272c4a5d69@legal.paiwise.tagroot.io" },
            { "NDEASESS", "2bebf434-151c-76d6-180b-8e272cb1e584@legal.paiwise.tagroot.io" },
            { "SWEDSESS", "2bebf441-151c-76d8-180b-8e272cf43b0a@legal.paiwise.tagroot.io" },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private static readonly Dictionary<string, string> buyTemplateIdsSandbox = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2ba713cc-5c13-354c-8409-54d68d1e35ce@legal.lab.tagroot.io" },
            { "ESSESESS", "2ba713d9-5c13-354e-8409-54d68d144838@legal.lab.tagroot.io" },
            { "HANDSESS", "2ba713e2-5c13-3550-8409-54d68d7545d2@legal.lab.tagroot.io" },
            { "NDEASESS", "2ba713eb-5c13-3552-8409-54d68dc6093d@legal.lab.tagroot.io" },
            { "SWEDSESS", "2ba713f6-5c13-3556-8409-54d68d2492da@legal.lab.tagroot.io" },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private static readonly Dictionary<string, string> buyTemplateIdsLocalDev = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2be5a9bc-0022-b121-8029-227baed8c9db@legal." },
            { "ESSESESS", "2be5a9dc-0022-b127-8029-227bae11c604@legal." },
            { "HANDSESS", "2be5a9e9-0022-b12a-8029-227baeb0c983@legal." },
            { "NDEASESS", "2be5a9fa-0022-b12c-8029-227baee190ce@legal." },
            { "SWEDSESS", "2be5aa07-0022-b12e-8029-227baeb2d454@legal." },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private static readonly Dictionary<string, string> sellTemplateIdsProduction = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2bebf475-151c-76dd-180b-8e272c2cdda8@legal.paiwise.tagroot.io" },
            { "ESSESESS", "2bebf49a-151c-76e0-180b-8e272c2d1ec1@legal.paiwise.tagroot.io" },
            { "HANDSESS", "2bebf4a7-151c-76e2-180b-8e272c8433da@legal.paiwise.tagroot.io" },
            { "NDEASESS", "2bebf4b7-151c-76e6-180b-8e272cb7e7d1@legal.paiwise.tagroot.io" },
            { "SWEDSESS", "2bebf4c2-151c-76e8-180b-8e272cae5fcd@legal.paiwise.tagroot.io" },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private static readonly Dictionary<string, string> sellTemplateIdsSandbox = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2ba7143d-5c13-3570-8409-54d68df89117@legal.lab.tagroot.io" },
            { "ESSESESS", "2ba71449-5c13-3572-8409-54d68ddf81b4@legal.lab.tagroot.io" },
            { "HANDSESS", "2ba71451-5c13-3574-8409-54d68d7d414a@legal.lab.tagroot.io" },
            { "NDEASESS", "2ba7145a-5c13-3576-8409-54d68d243631@legal.lab.tagroot.io" },
            { "SWEDSESS", "2ba71464-5c13-3578-8409-54d68d68c6a3@legal.lab.tagroot.io" },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private static readonly Dictionary<string, string> sellTemplateIdsLocalDev = new Dictionary<string, string>()
        {
            { "ELLFSESS", "2be5aa2d-0022-b13c-8029-227bae3aeeed@legal." },
            { "ESSESESS", "2be5aa3a-0022-b147-8029-227bae306db1@legal." },
            { "HANDSESS", "2be5aa46-0022-b14e-8029-227bae4f3831@legal." },
            { "NDEASESS", "2be5aa52-0022-b150-8029-227bae7fdd4d@legal." },
            { "SWEDSESS", "2be5aa5f-0022-b152-8029-227baef01fa8@legal." },
            { "NDEAFIHH", string.Empty },
            { "DABASESX", string.Empty },
            { "DNBANOKK", string.Empty },
            { "NDEANOKK", string.Empty },
            { "NDEADKKK", string.Empty },
            { "OKOYFIHH", null },
            { "DNBASESX", null },
            { "DNBADEHX", null },
            { "DNBAGB2L", null }
        };

        private readonly PayoutServiceProvider provider;
        private readonly CaseInsensitiveString country;
        private readonly AspServiceProvider service;
        private readonly OperationMode mode;
        private readonly string buyTemplateId;
        private readonly string sellTemplateId;
        private readonly string id;
        //private string sessionId;
        //private bool requestFromMobilePhone;
        //private string tabId;
        //private IPAddress clientIpAddress;

        /// <summary>
        /// Open Payments Platform service
        /// </summary>
        /// <param name="Country">Country where service operates</param>
        /// <param name="Service">Service reference</param>
        /// <param name="Mode">Operation mode</param>
        /// <param name="Provider">Service provider.</param>
        public PayoutService(CaseInsensitiveString Country, AspServiceProvider Service, OperationMode Mode,
            PayoutServiceProvider Provider)
        {
            this.country = Country;
            this.service = Service;
            this.mode = Mode;
            this.provider = Provider;

            if (Mode == OperationMode.Production)
            {
                this.id = "Production." + this.service.BicFi;

                if (!buyTemplateIdsProduction.TryGetValue(Service.BicFi.ToUpper(), out this.buyTemplateId))
                    this.buyTemplateId = null;

                if (!sellTemplateIdsProduction.TryGetValue(Service.BicFi.ToUpper(), out this.sellTemplateId))
                    this.sellTemplateId = null;
            }
            else
            {
                this.id = "Sandbox." + this.service.BicFi;

                if (string.IsNullOrEmpty(Gateway.Domain))
                {
                    if (!buyTemplateIdsLocalDev.TryGetValue(Service.BicFi.ToUpper(), out this.buyTemplateId))
                        this.buyTemplateId = null;

                    if (!sellTemplateIdsLocalDev.TryGetValue(Service.BicFi.ToUpper(), out this.sellTemplateId))
                        this.sellTemplateId = null;
                }
                else
                {
                    if (!buyTemplateIdsSandbox.TryGetValue(Service.BicFi.ToUpper(), out this.buyTemplateId))
                        this.buyTemplateId = null;

                    if (!sellTemplateIdsSandbox.TryGetValue(Service.BicFi.ToUpper(), out this.sellTemplateId))
                        this.sellTemplateId = null;
                }
            }
        }

        #region IServiceProvider

        /// <summary>
        /// ID of service
        /// </summary>
        public string Id => this.id;

        /// <summary>
        /// Name of service
        /// </summary>
        public string Name => this.service.Name;

        /// <summary>
        /// Icon URL
        /// </summary>
        public string IconUrl => this.service.LogoUrl;

        /// <summary>
        /// Width of icon, in pixels.
        /// </summary>
        public int IconWidth => 181;

        /// <summary>
        /// Height of icon, in pixels
        /// </summary>
        public int IconHeight => 150;

        #endregion

        #region IProcessingSupport<CaseInsensitiveString>

        /// <summary>
        /// How well a currency is supported
        /// </summary>
        /// <param name="Currency">Currency</param>
        /// <returns>Support</returns>
        public Grade Supports(CaseInsensitiveString Currency)
        {
            string Expected;

            switch (this.country.LowerCase)
            {
                case "se":
                    Expected = "sek";
                    break;

                case "no":
                    Expected = "nok";
                    break;

                case "dk":
                    Expected = "dkk";
                    break;

                case "fi":
                case "de":
                    Expected = "eur";
                    break;

                case "uk":
                    Expected = "gbp";
                    break;

                default:
                    return Grade.NotAtAll;

            }

            if (Currency.LowerCase == Expected)
                return Grade.Excellent;

            switch (Currency.LowerCase)
            {
                case "sek":
                case "dkk":
                case "nok":
                case "eur":
                case "gbp":
                    return Grade.Ok;

                default:
                    return Grade.NotAtAll;
            }
        }

        #endregion

        #region IBuyEDalerService

        /// <summary>
        /// Contract ID of Template, for buying e-Daler
        /// </summary>
        public string BuyEDalerTemplateContractId => this.buyTemplateId ?? string.Empty;

        ///// <summary>
        ///// Reference to service provider
        ///// </summary>
        //public IBuyEDalerServiceProvider BuyEDalerServiceProvider => this.provider;

        /// <summary>
        /// If the service provider can be used to process a request to buy eDaler
        /// of a certain amount, for a given account.
        /// </summary>
        /// <param name="AccountName">Account Name</param>
        /// <returns>If service provider can be used.</returns>
        public Task<bool> CanBuyEDaler(CaseInsensitiveString AccountName)
        {
            if (this.buyTemplateId is null)
                return Task.FromResult(false);

            return this.IsConfigured();
        }

        private async Task<bool> IsConfigured()
        {
            ServiceConfiguration Configuration = await ServiceConfiguration.GetCurrent();
            return Configuration.IsWellDefined;
        }

        /// <summary>
        /// Processes payment for buying eDaler.
        ///  <param name="ContractID">Tab ID</param>
        /// <param name="TabId">Tab ID</param>
		/// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
        /// <returns>Result of operation.</returns>
        public async Task<PaymentResult> BuyEDaler(string ContractID, string BankAccount, string PersonalNumber, string TabId, bool RequestFromMobilePhone, string RemoteEndpoint)
        {
            IPAddress.TryParse(RemoteEndpoint, out IPAddress ClientIpAddress);

            Log.Informational("PaymentLinkBuyEDaler started");

            ServiceConfiguration Configuration = await ServiceConfiguration.GetCurrent();
            if (!Configuration.IsWellDefined)
            {
                await DisplayUserMessage(TabId, "Service not configured properly.");
                return new PaymentResult("Service not configured properly.");
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
                return new PaymentResult("Unable to LoginToUserAgent");
            }

            if (!Token.IsValid())
            {
                Log.Informational("Parameters for token are not valid.");
                return new PaymentResult("Parameters for token are not valid");
            }

            AuthorizationFlow Flow = Configuration.AuthorizationFlow;

            Log.Informational("CreateClient started");
            OpenPaymentsPlatformClient Client = PayoutServiceProvider.CreateClient(Configuration, this.mode, ServicePurpose.Private);    // TODO: Contracts for corporate accounts (when using corporate IDs).

            if (Client is null)
            {
                return new PaymentResult("Service not configured properly.");
            }
            Log.Informational("CreateClient completed");
            try
            {
                string PersonalID = GetPersonalID(PersonalNumber);

                OperationInformation Operation = new OperationInformation(
                    ClientIpAddress,
                    typeof(PayoutServiceProvider).Assembly.FullName,
                    Flow,
                    PersonalID,
                    null,
                    this.service.BicFi);

                PaymentProduct Product;

                if (Configuration.NeuronBankAccountIban.Substring(0, 2) == BankAccount.Substring(0, 2))
                {
                    Product = PaymentProduct.domestic;
                }
                else if (Token.Currency.ToUpper() == "EUR")
                {
                    Product = PaymentProduct.sepa_credit_transfers;
                }
                else
                {
                    Product = PaymentProduct.international;
                }

                Log.Informational("CreatePaymentInitiation started");

                PaymentInitiationReference PaymentInitiationReference = await Client.CreatePaymentInitiation(
                    Product, Token.Value, Token.Currency, BankAccount, Token.Currency,
                    Configuration.NeuronBankAccountIban, Token.Currency,
                    Configuration.NeuronBankAccountName, "Vaulter", Operation);

                Log.Informational("CreatePaymentInitiation completed");

                Log.Informational("StartPaymentInitiationAuthorization started");
                AuthorizationInformation AuthorizationStatus = await Client.StartPaymentInitiationAuthorization(
                    Product, PaymentInitiationReference.PaymentId, Operation,
                    "", "");
                Log.Informational("StartPaymentInitiationAuthorization completed");

                Log.Informational("GetAuthenticationMethod started");
                AuthenticationMethod AuthenticationMethod = null;

                Log.Informational("TabID: " + TabId ?? "-" + "requestFromMobilePhone: " + RequestFromMobilePhone);

                if (!string.IsNullOrEmpty(TabId))
                {
                    if (RequestFromMobilePhone)
                    {
                        AuthenticationMethod = AuthorizationStatus.GetAuthenticationMethod("mbid_same_device")
                            ?? AuthorizationStatus.GetAuthenticationMethod("mbid");
                    }
                    else
                    {
                        AuthenticationMethod = AuthorizationStatus.GetAuthenticationMethod("mbid_animated_qr_token")
                            ?? AuthorizationStatus.GetAuthenticationMethod("mbid_animated_qr_image")
                            ?? AuthorizationStatus.GetAuthenticationMethod("mbid")
                            ?? AuthorizationStatus.GetAuthenticationMethod("mbid_same_device");
                    }
                }
                Log.Informational("GetAuthenticationMethod completed");
                Log.Informational("Method" + AuthenticationMethod.Name.ToString() + "TabID" + TabId + "requestFromMobilePhone" + RequestFromMobilePhone);

                Log.Informational("PutPaymentInitiationUserData started");
                PaymentServiceUserDataResponse PsuDataResponse = await Client.PutPaymentInitiationUserData(
                    Product, PaymentInitiationReference.PaymentId,
                    AuthorizationStatus.AuthorizationID, AuthenticationMethod.MethodId, Operation);
                Log.Informational("PutPaymentInitiationUserData completed");


                if (!(PsuDataResponse.ChallengeData is null) && !string.IsNullOrEmpty(TabId))
                {
                    await ClientEvents.PushEvent(new string[] { TabId }, "ShowQRCode",
                    JSON.Encode(new Dictionary<string, object>()
                    {
                                { "BankIdUrl", PsuDataResponse.ChallengeData.BankIdURL},
                                { "MobileAppUrl",  GetMobileAppUrl(null, PsuDataResponse.ChallengeData.AutoStartToken)},
                                { "AutoStartToken", PsuDataResponse.ChallengeData.AutoStartToken},
                                { "ImageUrl",PsuDataResponse.ChallengeData.ImageUrl },
                                { "fromMobileDevice", RequestFromMobilePhone },
                                { "title", "Authorize recipient" },
                                { "message", "Scan the following QR-code with your Bank-ID app, or click on it if your Bank-ID is installed on your computer." },
                    }, false), true);
                }

                Log.Informational(PsuDataResponse.Status.ToString());

                TppMessage[] ErrorMessages = PsuDataResponse.Messages;
                AuthorizationStatusValue AuthorizationStatusValue = PsuDataResponse.Status;
                DateTime Start = DateTime.Now;
                bool PaymentAuthorizationStarted = AuthorizationStatusValue == AuthorizationStatusValue.started ||
                        AuthorizationStatusValue == AuthorizationStatusValue.authenticationStarted;
                bool CreditorAuthorizationStarted = AuthorizationStatusValue == AuthorizationStatusValue.authoriseCreditorAccountStarted;

                while (AuthorizationStatusValue != AuthorizationStatusValue.finalised &&
                    AuthorizationStatusValue != AuthorizationStatusValue.failed &&
                    DateTime.Now.Subtract(Start).TotalMinutes < Configuration.TimeoutMinutes)
                {
                    await Task.Delay(Configuration.PollingIntervalSeconds * 1000);
                    Log.Informational("AuthorizationStatusValue:" + AuthorizationStatusValue);
                    AuthorizationStatus P2 = await Client.GetPaymentInitiationAuthorizationStatus(
                        Product, PaymentInitiationReference.PaymentId, AuthorizationStatus.AuthorizationID, Operation);
                    AuthorizationStatusValue = P2.Status;
                    ErrorMessages = P2.Messages;

                    if (!string.IsNullOrEmpty(P2.ChallengeData?.BankIdURL))
                    {
                        switch (AuthorizationStatusValue)
                        {
                            case AuthorizationStatusValue.started:
                                Log.Informational("AuthorizationStatusValue.started");
                                break;
                            case AuthorizationStatusValue.authenticationStarted:

                                Log.Informational("AuthorizationStatusValue.authenticationStarted");
                                if (!PaymentAuthorizationStarted)
                                {
                                    PaymentAuthorizationStarted = true;

                                    // ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                    // await ClientUrlCallback(this, e);
                                }
                                break;

                            case AuthorizationStatusValue.authoriseCreditorAccountStarted:

                                Log.Informational("AuthorizationStatusValue.authoriseCreditorAccountStarted");
                                if (!CreditorAuthorizationStarted)
                                {
                                    CreditorAuthorizationStarted = true;

                                    //ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                    //await ClientUrlCallback(this, e);
                                }
                                break;
                        }
                    }
                }

                if (!(ErrorMessages is null) && ErrorMessages.Length > 0)
                {
                    await DisplayUserMessage(TabId, ErrorMessages[0].Text);
                    return new PaymentResult(ErrorMessages[0].Text);
                }


                PaymentTransactionStatus Status = await Client.GetPaymentInitiationStatus(Product, PaymentInitiationReference.PaymentId, Operation);
                Log.Informational("PaymentTransactionStatus: " + Status);
                if (!(Status.Messages is null) && Status.Messages.Length > 0 &&
                    (Status.Status == PaymentStatus.RJCT ||
                    Status.Status == PaymentStatus.CANC))
                {
                    StringBuilder Msg = new StringBuilder();

                    foreach (TppMessage TppMsg in Status.Messages)
                        Msg.AppendLine(TppMsg.Text);

                    string s = Msg.ToString().Trim();

                    if (!string.IsNullOrEmpty(s))
                    {
                        await DisplayUserMessage(TabId, s);
                        return new PaymentResult(s);
                    }

                }

                Log.Informational("Status.Status: " + Status.Status);
                switch (Status.Status)
                {
                    case PaymentStatus.RJCT:
                        await DisplayUserMessage(TabId, "Payment was rejected.");
                        return new PaymentResult("Payment was rejected.");

                    case PaymentStatus.CANC:
                        await DisplayUserMessage(TabId, "Payment was cancelled.");
                        return new PaymentResult("Payment was cancelled.");
                }

                Log.Informational("AuthorizationStatusValue: " + AuthorizationStatusValue);
                switch (AuthorizationStatusValue)
                {
                    case AuthorizationStatusValue.finalised:
                        break;

                    case AuthorizationStatusValue.failed:
                        await DisplayUserMessage(TabId, "Payment failed. (" + AuthorizationStatusValue.ToString() + ")");
                        return new PaymentResult("Payment failed. (" + AuthorizationStatusValue.ToString() + ")");

                    default:
                        await DisplayUserMessage(TabId, "Transaction took too long to complete.");
                        return new PaymentResult("Transaction took too long to complete.");
                }

                await DisplayUserMessage(TabId, "Your payment is complete! Thank you for using Vaulter! \n A payment confirmation is now sent to your email address.", true);

                await UpdateContractWithTransactionStatusAsync(Token, Jwt);

                return new PaymentResult(Token.Value, Token.Currency);
            }
            catch (Exception ex)
            {
                await DisplayUserMessage(TabId, ex.Message);
                return new PaymentResult(ex.Message);
            }
            finally
            {
                PayoutServiceProvider.Dispose(Client, this.mode);
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
                    }, false), true, "User", "Admin.Payments.Paiwise.OpenPaymentsPlatform");
        }

        private static string CheckJidHostedByServer(IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            out CaseInsensitiveString Account)
        {
            Account = null;

            if (!IdentityProperties.TryGetValue("JID", out CaseInsensitiveString JID))
                return "JID not encoded into identity.";

            int i = JID.IndexOf('@');
            if (i < 0)
                return "Invalid JID encoded into identity.";

            Account = JID.Substring(0, i);
            CaseInsensitiveString Domain = JID.Substring(i + 1);
            bool IsServerDomain = Domain == Gateway.Domain;

            if (!IsServerDomain)
            {
                foreach (CaseInsensitiveString AlternativeDomain in Gateway.AlternativeDomains)
                {
                    if (AlternativeDomain == Domain)
                    {
                        IsServerDomain = true;
                        break;
                    }
                }

                if (!IsServerDomain)
                    return "JID not registered on this server.";
            }

            return null;
        }

        private static string GetPersonalID(CaseInsensitiveString PersonalNumber)
        {
            return PersonalNumber?.Value?.
                Replace("-", string.Empty).
                Replace(".", string.Empty).
                Replace(" ", string.Empty);
        }

        private static async Task<KeyValuePair<IPAddress, PaymentResult>> GetRemoteEndpoint(CaseInsensitiveString Account)
        {
            IEnumerable<GenericObject> LoginRecords = await Database.Find<GenericObject>(
                "BrokerAccountLogins", 0, 1,
                new FilterFieldEqualTo("UserName", Account));

            string RemoteEndpoint = null;

            foreach (GenericObject LoginRecord in LoginRecords)
            {
                if (LoginRecord.TryGetFieldValue("RemoteEndpoint", out object Obj))
                {
                    RemoteEndpoint = Obj?.ToString();
                    break;
                }
            }

            if (string.IsNullOrEmpty(RemoteEndpoint))
                return new KeyValuePair<IPAddress, PaymentResult>(null, new PaymentResult("Client IP address was not found. Required to process payment."));

            int i = RemoteEndpoint.LastIndexOf(':');
            if (i > 0)
                RemoteEndpoint = RemoteEndpoint.Substring(0, i);

            if (!IPAddress.TryParse(RemoteEndpoint, out IPAddress ClientIpAddress))
                return new KeyValuePair<IPAddress, PaymentResult>(null, new PaymentResult("Client not connected via IP network. Required to process payment."));

            return new KeyValuePair<IPAddress, PaymentResult>(ClientIpAddress, null);
        }

        /// <summary>
        /// Gets available payment options for buying eDaler.
        /// </summary>
        /// <param name="IdentityProperties">Properties engraved into the legal identity that will performm the request.</param>
        /// <param name="SuccessUrl">Optional Success URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="FailureUrl">Optional Failure URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="CancelUrl">Optional Cancel URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="ClientUrlCallback">Method to call if the payment service
        /// requests an URL to be displayed on the client.</param>
		/// <param name="SessionId">Session ID</param>
		/// <param name="TabId">Tab ID</param>
		/// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
		/// or web/desktop/other (false).</param>
        /// <returns>Array of dictionaries, each dictionary representing a set of parameters that can be selected in the
        /// contract to sign.</returns>

        /// <summary>
        /// Gets an URL that can be used to start the BankID app on a desptop.
        /// </summary>
        /// <param name="RedirectUrl">URL to redirect to.</param>
        /// <returns>URL for starting a BankID app on a desktop.</returns>
        public string GetMobileAppUrl(string RedirectUrl, string AutoStartToken)
        {
            StringBuilder sb = new StringBuilder();

            sb.Append("bankid://?autostarttoken=");
            sb.Append(System.Web.HttpUtility.UrlEncode(AutoStartToken));
            sb.Append("&redirect=");

            if (!string.IsNullOrEmpty(RedirectUrl))
                sb.Append(System.Web.HttpUtility.UrlEncode(RedirectUrl));
            else
                sb.Append("null");

            return sb.ToString();
        }


        /// <summary>
        /// Gets available payment options for buying eDaler.
        /// </summary>
        /// <param name="IdentityProperties">Properties engraved into the legal identity that will performm the request.</param>
        /// <param name="SuccessUrl">Optional Success URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="FailureUrl">Optional Failure URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="CancelUrl">Optional Cancel URL the service provider can open on the client from a client web page, if getting options has succeeded.</param>
        /// <param name="TabId">Tab ID</param>
        /// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
        /// <param name="RemoteEndpoint">Client IP adress
        /// <returns>Result of operation.</returns>
        public async Task<IDictionary<CaseInsensitiveString, object>[]> GetPaymentOptionsForBuyingEDaler(
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            string SuccessUrl, string FailureUrl, string CancelUrl, string TabId, bool RequestFromMobilePhone, string RemoteEndpoint)
        {

            IPAddress.TryParse(RemoteEndpoint, out IPAddress ClientIpAddress);

            ServiceConfiguration Configuration = await ServiceConfiguration.GetCurrent();
            if (!Configuration.IsWellDefined)
                return new IDictionary<CaseInsensitiveString, object>[0];

            AuthorizationFlow Flow = Configuration.AuthorizationFlow;

            string Message = CheckJidHostedByServer(IdentityProperties, out CaseInsensitiveString Account);
            if (!string.IsNullOrEmpty(Message))
                return new IDictionary<CaseInsensitiveString, object>[0];

            if (!(IdentityProperties.TryGetValue("PNR", out CaseInsensitiveString PersonalNumber)))
                return new IDictionary<CaseInsensitiveString, object>[0];

            Log.Informational("Account" + Account + "PersonalNumber" + PersonalNumber);


            OpenPaymentsPlatformClient Client = PayoutServiceProvider.CreateClient(Configuration, this.mode,
                ServicePurpose.Private);    // TODO: Contracts for corporate accounts (when using corporate IDs).

            if (Client is null)
                return new IDictionary<CaseInsensitiveString, object>[0];


            Log.Informational("Client created ");
            try
            {
                string PersonalID = GetPersonalID(PersonalNumber);

                OperationInformation Operation = new OperationInformation(
                    ClientIpAddress,
                    typeof(PayoutServiceProvider).Assembly.FullName,
                    Flow,
                    PersonalID,
                    null,
                    this.service.BicFi);

                ConsentStatus Consent = await Client.CreateConsent(string.Empty, true, false, false,
                    DateTime.Today.AddDays(1), 1, false, Operation);

                Log.Informational("Consent created ");

                AuthorizationInformation Status = await Client.StartConsentAuthorization(Consent.ConsentID, Operation);

                AuthenticationMethod Method = null;


                if (!string.IsNullOrEmpty(TabId))
                    if (RequestFromMobilePhone)
                    {
                        Method = Status.GetAuthenticationMethod("mbid_same_device")
                            ?? Status.GetAuthenticationMethod("mbid");
                    }
                    else
                    {
                        Method = Status.GetAuthenticationMethod("mbid_animated_qr_token")
                              ?? Status.GetAuthenticationMethod("mbid_animated_qr_image")
                              ?? Status.GetAuthenticationMethod("mbid")
                              ?? Status.GetAuthenticationMethod("mbid_same_device");


                    }
                Log.Informational("Method" + Method.Name.ToString() + "TabID" + TabId + "requestFromMobilePhone" + RequestFromMobilePhone);

                if (Method is null)
                    return new IDictionary<CaseInsensitiveString, object>[0];

                PaymentServiceUserDataResponse PsuDataResponse = await Client.PutConsentUserData(Consent.ConsentID,
                    Status.AuthorizationID, Method.MethodId, Operation);

                if (PsuDataResponse is null)
                    return new IDictionary<CaseInsensitiveString, object>[0];

                if (!(PsuDataResponse.ChallengeData is null) && !string.IsNullOrEmpty(TabId))
                {
                    await ClientEvents.PushEvent(new string[] { TabId }, "ShowQRCode",
                   JSON.Encode(new Dictionary<string, object>()
                   {
                                { "BankIdUrl", PsuDataResponse.ChallengeData.BankIdURL},
                                { "MobileAppUrl",  GetMobileAppUrl(null, PsuDataResponse.ChallengeData.AutoStartToken)},
                                { "AutoStartToken", PsuDataResponse.ChallengeData.AutoStartToken},
                                { "ImageUrl",PsuDataResponse.ChallengeData.ImageUrl },
                                { "fromMobileDevice", RequestFromMobilePhone },
                                { "title", "Authorize recipient" },
                                { "message", "Scan the following QR-code with your Bank-ID app, or click on it if your Bank-ID is installed on your computer." },
                   }, false), true);
                }

                Log.Informational(PsuDataResponse.Status.ToString());
                TppMessage[] ErrorMessages = PsuDataResponse.Messages;
                AuthorizationStatusValue AuthorizationStatusValue = PsuDataResponse.Status;
                DateTime Start = DateTime.Now;
                bool PaymentAuthorizationStarted = AuthorizationStatusValue == AuthorizationStatusValue.started ||
                        AuthorizationStatusValue == AuthorizationStatusValue.authenticationStarted;
                bool CreditorAuthorizationStarted = AuthorizationStatusValue == AuthorizationStatusValue.authoriseCreditorAccountStarted;
                Log.Informational("0 " + AuthorizationStatusValue.ToString());
                int counter = 0;
                while (AuthorizationStatusValue != AuthorizationStatusValue.finalised &&
                    AuthorizationStatusValue != AuthorizationStatusValue.failed &&
                    DateTime.Now.Subtract(Start).TotalMinutes < Configuration.TimeoutMinutes)
                {
                    counter++;
                    Log.Informational(counter.ToString() + AuthorizationStatusValue.ToString());
                    await Task.Delay(Configuration.PollingIntervalSeconds);

                    AuthorizationStatus P2 = await Client.GetConsentAuthorizationStatus(Consent.ConsentID, Status.AuthorizationID, Operation);

                    AuthorizationStatusValue = P2.Status;

                    Log.Informational(counter.ToString() + P2.Status.ToString());
                    ErrorMessages = P2.Messages;

                    Log.Informational(counter.ToString() + P2.Messages.ToString());
                    switch (AuthorizationStatusValue)
                    {
                        case AuthorizationStatusValue.started:
                        case AuthorizationStatusValue.authenticationStarted:
                            Log.Informational("authenticationStarted");

                            if (!PaymentAuthorizationStarted)
                            {

                                PaymentAuthorizationStarted = true;

                                //ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                //await ClientUrlCallback(this, e);
                            }
                            break;

                        case AuthorizationStatusValue.authoriseCreditorAccountStarted:
                            Log.Informational("authoriseCreditorAccountStarted");

                            if (!CreditorAuthorizationStarted)

                            {
                                CreditorAuthorizationStarted = true;

                                //ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                //await ClientUrlCallback(this, e);
                            }
                            break;
                    }
                }


                ConsentStatusValue ConsentStatusValue = await Client.GetConsentStatus(Consent.ConsentID, Operation);
                switch (ConsentStatusValue)
                {
                    case ConsentStatusValue.rejected:
                        Log.Informational("Consent was rejected.");
                        break;

                    case ConsentStatusValue.revokedByPsu:
                        Log.Informational("Consent was revoked.");
                        break;

                    case ConsentStatusValue.expired:
                        Log.Informational("Consent has expired.");
                        break;

                    case ConsentStatusValue.terminatedByTpp:
                        Log.Informational("Consent was terminated.");
                        break;

                    case ConsentStatusValue.valid:
                        Log.Informational("Consent is valid.");
                        break;

                    default:
                        Log.Informational("Consent was not valid.");
                        break;
                }

                Log.Informational("Consent was :" + ConsentStatusValue.ToString());

                if (!(ErrorMessages is null) && ErrorMessages.Length > 0)
                    throw new Exception(ErrorMessages[0].Text);

                AccountInformation[] Accounts = await Client.GetAccounts(Consent.ConsentID, Operation, true);
                List<IDictionary<CaseInsensitiveString, object>> Result = new List<IDictionary<CaseInsensitiveString, object>>();

                foreach (AccountInformation Account2 in Accounts)
                {
                    Log.Informational(Account2.Iban + "" + Account2.Name);
                    Result.Add(new Dictionary<CaseInsensitiveString, object>()
                    {
                        { "Account", Account2.Iban },
                        { "ResourceId", Account2.ResourceID },
                        { "Iban", Account2.Iban },
                        { "Bban", Account2.Bban },
                        { "Bic", Account2.Bic },
                        { "Balance", Account2.Balance},
                        { "Currency", Account2.Currency },
                        { "CashAccountType", Account2.CashAccountType },
                        { "Name", Account2.Name},
                        { "OwnerName", Account2.OwnerName },
                        { "Product", Account2.Product},
                        { "Status", Account2.Status },
                        { "Usage", Account2.Usage },
                });
                }

                await ClientEvents.PushEvent(new string[] { TabId }, "ShowAccountInfo",
                       JSON.Encode(new Dictionary<string, object>()
                       {
                                { "AccountInfo", Result.ToArray()},
                                { "message", "Account information the following QR-code with your Bank-ID app, or click on it if your Bank-ID is installed on your computer." },
                       }, false), true);

                return Result.ToArray();
            }
            finally
            {
                PayoutServiceProvider.Dispose(Client, this.mode);
            }
        }


        #endregion

        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
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

        private async Task UpdateContractWithTransactionStatusAsync(Token Token, string JwtToken)
        {
            try
            {
                string fullPaymentUri = await CreateFullPaymentUri(Token.OwnerJid, Token.Value, Token.Currency, 364, "nfeat:" + Token.TokenId);
                Log.Informational("FullPaymentUri: " + fullPaymentUri);

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
            catch (Exception ex)
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
            catch (Exception ex)
            {
                Log.Informational("GetToken " + ex.Message);
            }
            return null;
        }

        private async Task<string> GetSigniture(string PaymentUri, string Jwt)
        {
            try
            {
                string LegalId = "2c512516-50bf-9921-6c14-7b67c40fb9a0@legal.lab.neuron.vaulter.rs";
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


                if (ResultSignature is Dictionary<string, object> Response)
                {
                    if (Response.TryGetValue("Signature", out object ObjSignature) && ObjSignature is string Signature)
                        return Signature;
                }
            }
            catch (Exception ex)
            {
                Log.Informational("GetSigniture errorMessage: " + ex.Message);
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

        /// <summary>
        /// If the service provider can be used to process a request to sell eDaler
        /// of a certain amount, for a given account.
        /// </summary>
        /// <param name="AccountName">Account Name</param>
        /// <returns>If service provider can be used.</returns>
        public Task<bool> CanSellEDaler(CaseInsensitiveString AccountName)
        {
            if (string.IsNullOrEmpty(this.sellTemplateId))
                return Task.FromResult(false);

            return this.IsConfigured();
        }
    }
}

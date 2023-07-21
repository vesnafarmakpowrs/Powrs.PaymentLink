﻿using Paiwise;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using TAG.Networking.OpenPaymentsPlatform;
using TAG.Payments.OpenPaymentsPlatform;
using Waher.Content;
using Waher.Content.Html.Elements;
using Waher.Content.Markdown;
using Waher.Events;
using Waher.IoTGateway;
using Waher.Persistence;
using Waher.Persistence.Filters;
using Waher.Persistence.Serialization;
using Waher.Runtime.Inventory;
using Waher.Script;

namespace POWRS.Payout
{
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
        /// </summary>
        /// <param name="ContractParameters">Parameters available in the
        /// contract authorizing the payment.</param>
        /// <param name="IdentityProperties">Properties engraved into the
        /// legal identity signing the payment request.</param>
        /// <param name="Amount">Amount to be paid.</param>
        /// <param name="Currency">Currency</param>
        /// <param name="SuccessUrl">Optional Success URL the service provider can open on the client from a client web page, if payment has succeeded.</param>
        /// <param name="FailureUrl">Optional Failure URL the service provider can open on the client from a client web page, if payment has succeeded.</param>
        /// <param name="CancelUrl">Optional Cancel URL the service provider can open on the client from a client web page, if payment has succeeded.</param>
        /// <param name="ClientUrlCallback">Method to call if the payment service
        /// requests an URL to be displayed on the client.</param>
        /// <param name="State">State object to pass on the callback method.</param>
        /// <returns>Result of operation.</returns>
        public async Task<PaymentResult> BuyEDaler(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            decimal Amount, string Currency, string SuccessUrl, string FailureUrl, string CancelUrl, ClientUrlEventHandler ClientUrlCallback, object State)
        {
            ServiceConfiguration Configuration = await ServiceConfiguration.GetCurrent();
            if (!Configuration.IsWellDefined)
                return new PaymentResult("Service not configured properly.");

            AuthorizationFlow Flow = Configuration.AuthorizationFlow;

            if (string.IsNullOrEmpty(this.buyTemplateId) || Flow == AuthorizationFlow.Redirect)
            {
                ContractParameters["Amount"] = Amount;
                ContractParameters["Currency"] = Currency;
            }

            string Message = this.ValidateParameters(ContractParameters, IdentityProperties,
                Amount, Currency, out CaseInsensitiveString PersonalNumber,
                out string BankAccount, out string TextMessage);

            if (!string.IsNullOrEmpty(Message))
                return new PaymentResult(Message);

            Message = CheckJidHostedByServer(IdentityProperties, out CaseInsensitiveString Account);
            if (!string.IsNullOrEmpty(Message))
                return new PaymentResult(Message);

            OpenPaymentsPlatformClient Client = PayoutServiceProvider.CreateClient(Configuration, this.mode,
                ServicePurpose.Private);    // TODO: Contracts for corporate accounts (when using corporate IDs).

            if (Client is null)
                return new PaymentResult("Service not configured properly.");

            try
            {
                string PersonalID = GetPersonalID(PersonalNumber);

                KeyValuePair<IPAddress, PaymentResult> P = await GetRemoteEndpoint(Account);
                if (!(P.Value is null))
                    return P.Value;

                IPAddress ClientIpAddress = P.Key;

                OperationInformation Operation = new OperationInformation(
                    ClientIpAddress,
                    typeof(PayoutServiceProvider).Assembly.FullName,
                    Flow,
                    PersonalID,
                    null,
                    this.service.BicFi);

                PaymentProduct Product;

                if (Configuration.NeuronBankAccountIban.Substring(0, 2) == BankAccount.Substring(0, 2))
                    Product = PaymentProduct.domestic;
                else if (Currency.ToUpper() == "EUR")
                    Product = PaymentProduct.sepa_credit_transfers;
                else
                    Product = PaymentProduct.international;

                PaymentInitiationReference PaymentInitiationReference = await Client.CreatePaymentInitiation(
                    Product, Amount, Currency, BankAccount, Currency,
                    Configuration.NeuronBankAccountIban, Currency,
                    Configuration.NeuronBankAccountName, TextMessage, Operation);

                AuthorizationInformation AuthorizationStatus = await Client.StartPaymentInitiationAuthorization(
                    Product, PaymentInitiationReference.PaymentId, Operation,
                    SuccessUrl, FailureUrl);

                AuthenticationMethod AuthenticationMethod = AuthorizationStatus.GetAuthenticationMethod("mbid_same_device")
                    ?? AuthorizationStatus.GetAuthenticationMethod("mbid");

                if (AuthenticationMethod is null)
                    return new PaymentResult("Unable to find a Mobile Bank ID authorization method for the operation.");

                PaymentServiceUserDataResponse PsuDataResponse = await Client.PutPaymentInitiationUserData(
                    Product, PaymentInitiationReference.PaymentId,
                    AuthorizationStatus.AuthorizationID, AuthenticationMethod.MethodId, Operation);

                if (!(ClientUrlCallback is null))
                {
                    if (!string.IsNullOrEmpty(PsuDataResponse.ChallengeData?.BankIdURL))
                    {
                        await ClientUrlCallback(this, new ClientUrlEventArgs(
                            PsuDataResponse.ChallengeData.BankIdURL, State));
                    }
                    else if (!string.IsNullOrEmpty(PsuDataResponse.Links.ScaOAuth))
                    {
                        string Url = Client.GetClientWebUrl(PsuDataResponse.Links.ScaOAuth,
                            "https://lab.tagroot.io/ReturnFromPayment.md", SuccessUrl);

                        await ClientUrlCallback(this, new ClientUrlEventArgs(Url, State));
                    }
                }

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

                    AuthorizationStatus P2 = await Client.GetPaymentInitiationAuthorizationStatus(
                        Product, PaymentInitiationReference.PaymentId, AuthorizationStatus.AuthorizationID, Operation);
                    AuthorizationStatusValue = P2.Status;
                    ErrorMessages = P2.Messages;

                    if (!string.IsNullOrEmpty(P2.ChallengeData?.BankIdURL) && !(ClientUrlCallback is null))
                    {
                        switch (AuthorizationStatusValue)
                        {
                            case AuthorizationStatusValue.started:
                            case AuthorizationStatusValue.authenticationStarted:
                                if (!PaymentAuthorizationStarted)
                                {
                                    PaymentAuthorizationStarted = true;

                                    ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                    await ClientUrlCallback(this, e);
                                }
                                break;

                            case AuthorizationStatusValue.authoriseCreditorAccountStarted:
                                if (!CreditorAuthorizationStarted)
                                {
                                    CreditorAuthorizationStarted = true;

                                    ClientUrlEventArgs e = new ClientUrlEventArgs(P2.ChallengeData.BankIdURL, State);
                                    await ClientUrlCallback(this, e);
                                }
                                break;
                        }
                    }
                }

                if (!(ErrorMessages is null) && ErrorMessages.Length > 0)
                    return new PaymentResult(ErrorMessages[0].Text);

                PaymentTransactionStatus Status = await Client.GetPaymentInitiationStatus(Product, PaymentInitiationReference.PaymentId, Operation);

                if (!(Status.Messages is null) && Status.Messages.Length > 0 &&
                    (Status.Status == PaymentStatus.RJCT ||
                    Status.Status == PaymentStatus.CANC))
                {
                    StringBuilder Msg = new StringBuilder();

                    foreach (TppMessage TppMsg in Status.Messages)
                        Msg.AppendLine(TppMsg.Text);

                    string s = Msg.ToString().Trim();

                    if (!string.IsNullOrEmpty(s))
                        return new PaymentResult(s);
                }

                switch (Status.Status)
                {
                    case PaymentStatus.RJCT:
                        return new PaymentResult("Payment was rejected.");

                    case PaymentStatus.CANC:
                        return new PaymentResult("Payment was cancelled.");
                }

                switch (AuthorizationStatusValue)
                {
                    case AuthorizationStatusValue.finalised:
                        break;

                    case AuthorizationStatusValue.failed:
                        return new PaymentResult("Payment failed. (" + AuthorizationStatusValue.ToString() + ")");

                    default:
                        return new PaymentResult("Transaction took too long to complete.");
                }

                return new PaymentResult(Amount, Currency);
            }
            catch (Exception ex)
            {
                return new PaymentResult(ex.Message);
            }
            finally
            {
                PayoutServiceProvider.Dispose(Client, this.mode);
            }
        }

        /// <summary>
        /// Processes payment for buying eDaler.
        /// </summary>
        /// <param name="ContractParameters">Parameters available in the
        /// contract authorizing the payment.</param>
        /// <param name="IdentityProperties">Properties engraved into the
        /// legal identity signing the payment request.</param>
        /// <param name="SuccessUrl">Optional Success URL the service provider can open on the client from a client web page, if payment has succeeded.</param>
        /// <param name="FailureUrl">Optional Failure URL the service provider can open on the client from a client web page, if payment has failed.</param>
        /// <param name="TabId">Tab ID</param>
		/// <param name="RequestFromMobilePhone">If request originates from mobile phone. (true)
        /// <returns>Result of operation.</returns>
        public async Task<PaymentResult> BuyEDaler(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            string SuccessUrl, string FailureUrl, string TabId, bool RequestFromMobilePhone, string RemoteEndpoint)
        {

            IPAddress.TryParse(RemoteEndpoint, out IPAddress ClientIpAddress);

            Log.Informational("PaymentLinkBuyEDaler started");

            ServiceConfiguration Configuration = await ServiceConfiguration.GetCurrent();
            if (!Configuration.IsWellDefined)
            {
                await DisplayUserMessage(TabId, "Service not configured properly.");
                return new PaymentResult("Service not configured properly.");
            }

            AuthorizationFlow Flow = Configuration.AuthorizationFlow;

            Log.Informational("ValidateParameters started");

            string Currency = ContractParameters["Currency"].ToString();
            decimal Amount = Expression.ToDecimal(ContractParameters["Amount"]);

            string Message = this.ValidateParameters(ContractParameters, IdentityProperties,
               Amount, Currency, out CaseInsensitiveString PersonalNumber,
                out string BankAccount, out string TextMessage);

            Log.Informational("ValidateParameters completed");

            Log.Informational(Message);
            if (!string.IsNullOrEmpty(Message))
            {
                Log.Informational(Message);
                await DisplayUserMessage(TabId, Message);
                return new PaymentResult(Message);
            }

            Log.Informational("CreateClient started");
            OpenPaymentsPlatformClient Client = PayoutServiceProvider.CreateClient(Configuration, this.mode,
                ServicePurpose.Private);    // TODO: Contracts for corporate accounts (when using corporate IDs).

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
                    Product = PaymentProduct.domestic;
                else if (Currency.ToUpper() == "EUR")
                    Product = PaymentProduct.sepa_credit_transfers;
                else
                    Product = PaymentProduct.international;
                Log.Informational("CreatePaymentInitiation started");

                PaymentInitiationReference PaymentInitiationReference = await Client.CreatePaymentInitiation(
                    Product, Amount, Currency, BankAccount, Currency,
                    Configuration.NeuronBankAccountIban, Currency,
                    Configuration.NeuronBankAccountName, TextMessage, Operation);

                Log.Informational("CreatePaymentInitiation completed");

                Log.Informational("StartPaymentInitiationAuthorization started");
                AuthorizationInformation AuthorizationStatus = await Client.StartPaymentInitiationAuthorization(
                    Product, PaymentInitiationReference.PaymentId, Operation,
                    SuccessUrl, FailureUrl);
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
                return new PaymentResult(Amount, Currency);
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

        private string ValidateParameters(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            decimal Amount, string Currency, out CaseInsensitiveString PersonalNumber,
            out string BankAccount, out string TextMessage)
        {
            PersonalNumber = null;
            TextMessage = string.Empty;
            BankAccount = string.Empty;

            if (!ContractParameters.TryGetValue("Amount", out object Obj))
                return "Amount not available in contract.";

            if (!(Obj is decimal ContractAmount))
            {
                try
                {
                    ContractAmount = Expression.ToDecimal(Obj);
                }
                catch (Exception)
                {
                    return "Amount in contract not of the correct type. Value: " + Expression.ToString(Obj) + ", Type: " + Obj?.GetType().FullName;
                }
            }

            if (ContractAmount != Amount)
                return "Amount in contract does not match amount in call.";

            if (!ContractParameters.TryGetValue("Currency", out Obj))
                return "Currency not available in contract.";

            if (!(Obj is string ContractCurrency))
                return "Currency in contract not of the correct type. Value: " + Expression.ToString(Obj) + ", Type: " + Obj?.GetType().FullName;

            if (ContractCurrency != Currency)
                return "Currency in contract does not match currency in call.";

            if (!ContractParameters.TryGetValue("Account", out Obj))
                return "Account not available in contract.";

            if (!(Obj is string ContractAccount))
                return "Account in contract not of the correct type. Value: " + Expression.ToString(Obj) + ", Type: " + Obj?.GetType().FullName;

            if (ContractAccount.Length <= 2)
                return "Invalid bank account.";

            BankAccount = ContractAccount;

            if (!(IdentityProperties.TryGetValue("PNR", out PersonalNumber)))
                return "Personal number missing in identity.";

            if (ContractParameters.TryGetValue("Message", out Obj))
            {
                if (!(Obj is string s))
                    return "Message not a string. Value: " + Expression.ToString(Obj) + ", Type: " + Obj?.GetType().FullName;

                s = s.Trim();
                if (s.Length > 10)
                    return "Message cannot be longer than 10 characters.";

                TextMessage = s;
            }

            return null;
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

        private string ValidateParameters(IDictionary<CaseInsensitiveString, object> ContractParameters,
            IDictionary<CaseInsensitiveString, CaseInsensitiveString> IdentityProperties,
            decimal Amount, string Currency, out CaseInsensitiveString PersonalNumber,
            out string BankAccount, out string AccountName, out string TextMessage)
        {
            AccountName = null;
            string Msg = this.ValidateParameters(ContractParameters, IdentityProperties, Amount, Currency, out PersonalNumber,
                out BankAccount, out TextMessage);

            if (!string.IsNullOrEmpty(Msg))
                return Msg;

            if (!ContractParameters.TryGetValue("AccountName", out object Obj))
                return "Account Name not available in contract.";

            AccountName = Obj?.ToString() ?? string.Empty;

            return null;
        }

    }
}

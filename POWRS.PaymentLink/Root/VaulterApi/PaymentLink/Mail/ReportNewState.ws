remoteEndpoint:= Request.RemoteEndPoint.Split(':', null)[0];
blocked:= select Blocked from RemoteEndpoints where Endpoint = remoteEndpoint;

try
(
        if(blocked != null && blocked == true) then 
        (
         Sleep(30000);
         NotFound("");
        );

        if !exists(Posted) then BadRequest("No payload.");
        r:= Request.DecodeData();

        if(!exists(r.Status) || !exists(r.ContractId) || !exists(r.CallBackUrl) || !exists(r.TokenId)) then
        (
          BadRequest("Payload does not conform to specification.");
        );

        if(System.String.IsNullOrEmpty(r.Status) || System.String.IsNullOrEmpty(r.ContractId)) then 
        (
         BadRequest("Payload does not conform to specification.");
        );

        SendCallBackOnStatusList := {"PaymentNotPerformed", "PaymentCompleted"};

        success:= false;

        if(!System.String.IsNullOrEmpty(r.CallBackUrl) && (r.Status in SendCallBackOnStatusList)) then
        (
          try
            (
 	            Log.Informational("Sending state update request to: " + r.CallBackUrl + " State: " + r.Status, null);
 	            POST(r.CallBackUrl,
                             {
	                       "status": r.Status
                              },
		              {
	                       "Accept" : "application/json"
                              });
 	            success:= true;
 	            Log.Informational("Sending state update request finished to: " + r.CallBackUrl + " State: " + r.Status, null);
            )
            catch 
            (
                  Log.Informational("Failed sending state update request to: " + r.CallBackUrl,null);
            );  
        );

        CountryCode := "RS";
        if (exists(r.CountryCode) and  !System.String.IsNullOrEmpty(r.CountryCode)) then
        (
           CountryCode := r.CountryCode;
        );

        if (exists(r.SendEmail) and  !System.String.IsNullOrEmpty(r.SendEmail)) then
        ( 
           contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= r.ContractId;

           if (contract == null) then 
           (
	            Error("Contract is missing");
           );

           NeuroFeatureToken:= select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = r.TokenId;
           ShortId := NeuroFeatureToken.ShortId;
           ContractParams:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object);
          
           variables:= NeuroFeatureToken.GetCurrentStateVariables();

           foreach variable in variables.VariableValues DO
           (
                ContractParams.Add(variable.Name,variable.Value);
           );
   
           ContractParams.Add("Created",contract.Created.ToShortDateString());
           ContractParams.Add("ShortId",ShortId);
           ContractParams.Add("ContractId",r.ContractId.ToString());
           
           foreach Parameter in contract.Parameters do 
           (
                Parameter.ObjectValue != null && !exists(ContractParams[Parameter.Name]) ? ContractParams.Add(Parameter.Name, Parameter.ObjectValue);
           );

           dictAmountToPay:= 0;
           if(!ContractParams.TryGetValue("AmountToPay", dictAmountToPay)) then 
           (
                Error("Amount not available in contract");
           );

           VatAmount:= dictAmountToPay * 0.2;
           PreVatPrice:= dictAmountToPay - VatAmount;

           ContractParams.Add("PreVatPrice", PreVatPrice);
           ContractParams.Add("VatAmount", VatAmount);

           Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
           IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString, System.Object);
           IdentityProperties.Add("AgentName", Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
           IdentityProperties.Add("ORGNAME", Identity.ORGNAME);
           IdentityProperties.Add("ORGNR", Identity.ORGNR);
           IdentityProperties.Add("ORGADDR", Identity.ORGADDR);
           IdentityProperties.Add("CountryCode", CountryCode);
           IdentityProperties.Add("Domain", Gateway.Domain);
           
           PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
           htmlTemplateRoot := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + CountryCode + "\\";

           htmlTemplatePath:= htmlTemplateRoot + r.Status + ".html";

           if (!File.Exists(htmlTemplatePath)) then 
           (
            Error("Template path does not exist   " + htmlTemplatePath);
           );

           html:= System.IO.File.ReadAllText(htmlTemplatePath);
  
           FormatedHtml := POWRS.PaymentLink.RS.DealInfo.GetHtmlDealInfo(ContractParams, IdentityProperties,html);
   
           Base64Attachment := null;
           FileName := null;
          
           Log.Informational("Sending email for " + r.Status  ,null);
           ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
           Config := ConfigClass.Instance;
           POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, ContractParams["BuyerEmail"].ToString(), "Vaulter", FormatedHtml, Base64Attachment, FileName);
   
        );

        {    	
            "Status" : r.Status,
            "Success": success
        }

)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);

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

        contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= r.ContractId;

        if (contract == null) then 
        (
           Error("Contract is missing");
        );
        NeuroFeatureToken:= select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = r.TokenId;

        if(NeuroFeatureToken == null) then 
        (
            Error("Token is missing");
        );

        SendCallBackOnStatusList := {"PaymentNotPerformed", "PaymentCompleted"};

        callbackSuccess:= false;
        if(!System.String.IsNullOrEmpty(r.CallBackUrl) && (r.Status in SendCallBackOnStatusList)) then
        (
          try
            (
 	            POST(r.CallBackUrl,
                             {
	                       "status": r.Status
                              },
		              {
	                       "Accept" : "application/json"
                              });

 	            callbackSuccess:= true;
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
	       Parameters:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object); 
           if(exists(r.PayspotOrderId) and !System.String.IsNullOrWhiteSpace(r.PayspotOrderId)) then 
           (
		
                payspotPayment:= select top 1 * from POWRS.Networking.PaySpot.Data.PayspotPayment where OrderId = r.PayspotOrderId;
                if(payspotPayment == null) then 
                (
                    Error("Unable to find payment with an OrderId: " + r.PayspotOrderId);
                );

                properties:= properties(payspotPayment);
                foreach prop in properties.Values do 
                (
                  Parameters[prop[0]]:= prop[1];
                );
           );          
                 
           variables:= NeuroFeatureToken.GetCurrentStateVariables();

           foreach variable in variables.VariableValues DO
           (
                Parameters[variable.Name]:= variable.Value;
           );
   
           Parameters["Created"]:= contract.Created.ToShortDateString();
           Parameters["ShortId"]:= NeuroFeatureToken.ShortId;
           Parameters["ContractId"]:= r.ContractId.ToString();
           
           foreach Parameter in contract.Parameters do 
           (
                Parameter.ObjectValue != null && !exists(Parameters[Parameter.Name]) ? Parameters[Parameter.Name]:=  Parameter.ObjectValue;
           );

           sellerContactInfo:= select top 1 * from POWRS.PaymentLink.OrganizationContactInfo where Account = contract.Account;           
           sellerContactInfoPropertyValues:= properties(sellerContactInfo).Values;

           foreach property in sellerContactInfoPropertyValues do 
           (
                Parameters["SellerContact" + property[0]]:= property[1];
           );

           Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
           IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString, System.Object);
           
           foreach prop in Identity.Properties do 
           (
                IdentityProperties[prop.Name]:= prop.Value;
           );

           IdentityProperties.Add("AgentName", Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
           IdentityProperties.Add("CountryCode", CountryCode);
           IdentityProperties.Add("Domain", Gateway.Domain);
           
           PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
           htmlTemplatePath := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + CountryCode + "\\" + r.Status + ".html";
           
           if (Status == "PaymentCompleted" && Parameters["PayspotGroupId"] != null)
            htmlTemplatePath := Replace(htmlTemplatePath,"PaymentCompleted","PaymentCompletedIPS"); 

           if (!File.Exists(htmlTemplatePath)) then 
           (
             htmlTemplatePath := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + "EN" + "\\" + r.Status + ".html";
             if(!File.Exists(htmlTemplatePath)) then 
             (
                Error("Template path does not exist   " + htmlTemplatePath);
             );             
           );

           html:= System.IO.File.ReadAllText(htmlTemplatePath);
  
           FormatedHtml := POWRS.PaymentLink.RS.DealInfo.GetHtmlDealInfo(Parameters, IdentityProperties,html);
   
           Base64Attachment := null;
           FileName := null;
          
           Log.Informational("Sending email for " + r.Status  ,null);
           ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
           Config := ConfigClass.Instance;
           POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, Parameters["BuyerEmail"].ToString(), "Vaulter", FormatedHtml, Base64Attachment, FileName);
        );

        {    	
            "Status" : r.Status,
            "success": callbackSuccess
        }

)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);

({
    "userName":Required(Str(PUserName) like "[\\p{L}\\s]{2,20}"),
    "password":Required(Str(PPassword) like [.{15,}]),
    "repeatedPassword":Required(Str(PRepeatedPassword) like [.{15,}]),
    "email" : Required(Str(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}")
}:=Posted) ??? BadRequest(Exception.Message);

try
(
    Code:= 0;
    if (!exists(Code:= Global.VerifyingNumbers[PEmail]) or Code >= 0) then 
    (
        Error("Email must be verified in order to create account");
    );

    Global.VerifyingNumbers.Remove(PEmail);

    if(PPassword != PRepeatedPassword) then
    (
        Error("Passwords does not match.");
    );

    if(!System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PUserName)) then 
    (
        Error("Account with " + PUserName + " already exists");
    );

    apiKey:= GetSetting("POWRS.PaymentLink.ApiKey", "");
    apiKeySecret:= GetSetting("POWRS.PaymentLink.ApiKeySecret", "");

    if(System.String.IsNullOrWhiteSpace(apiKey) or System.String.IsNullOrWhiteSpace(apiKeySecret)) then 
    (
        Error("Keys are missing");
    );

    Nonce:= Base64Encode(RandomBytes(32));
    S:= PUserName + ":" + Gateway.Domain + ":" + PEmail + ":" + PPassword + ":" + apiKey + ":" + Nonce;
    Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(apiKeySecret)));

    NewAccount:= POST(neuronDomain + "/Agent/Account/Create",
                 {
                    "apiKey": apiKey,
                    "eMail": PEmail,
	                "nonce": Nonce,
	                "password": PPassword,
                    "seconds": 1800,
                    "signature": Signature,
                    "userName": PUserName
                  },
		   {"Accept" : "application/json"}, {"Host": neuronDomain});

    enabled:= Update BrokerAccounts set Enabled = true where UserName = PUserName;

    {
        "userName": PUserName,
        "jwt": NewAccount.jwt
    }
)
catch
(
    Log.Error("Unable to create user: " + Exception.Message, null);
    BadRequest(Exception.Message);
)
finally
(
    Destroy(Nonce);
    Destroy(S);
    Destroy(Signature);
);
Title: Vaulter API v1
Description: This document contains information about the Vaulter API (v1)
Author:  POWRS DOO
Date: 2023-06-16
Master: \Master.md
Copyright: \Copyright.md

Vaulter API (v1)
==================

![Table of Contents](ToC)

Introduction
--------------

Vaulter publishes this API for external actors who wish to integrate with Vaulter, and make their
online items available in the Vaulter App. The following sections describe each API resource, one
at a time.

### Access to API

The Vaulter API is accessed via HTTPS.


### Authentication
Client needs `JWT` Token in order to access all the resources.
Token must be sent in **Authorization** header in next format: **"Bearer exampleTokenRetrieved"**.
To get an access token, client must login with provided credentials. Token is valid next 30 minutes.
Token refresh must be initiated manually and not before token expiration since it is possible to system block account and throw `Too Many Requests` exception.

### Return Codes

Following is a list of common HTTP response codes used by the API:

| Code | Name               | Description |
|:-----|:-------------------|:------------|
| 200  | OK                 | Request has been processed successfully. |
| 400  | Bad Request        | The request, including its payload, does not conform to the specification. |
| 401  | Unauthorized       | Unauthenticated access to a protected resource has been done. Perform WWW-Authentication to access the resource. |
| 403  | Forbidden          | Client is not authorized to access the resource. |
| 404  | Not Found          | Client has tried to access a resource that does not exist. |
| 405  | Method Not Allowed | Client has attempted to access a resource using an HTTP Method that is not supported, for instance using `GET` on a resource that expects `POST`. |
| 406  | Not Acceptable     | Client has requested information in a format that is not accepted by the API. |
| 429  | Too Many Requests  | Client has issued too many failed authentication attempts. |

### Methods

Access to the API resources are done using `POST` if nothing else is explicitly written.

### Payloads

Payloads will be JSON, both in requests and in responses. This means the following headers must be present
in all requests:

Headers that must be included in every header so the server knows how to encode and decode data:
### Mandatory headers
```
Content-Type: application/json
Accept: application/json
```

#### Mandatory Authorization Headers ( Except Login )

````
Authorization: Bearer ...
````

### Agent Api Key Login

This login is meant to be used in approved external systems for integration with Vaulter api. Api key and secret can be generated using Paylink portal or with api.

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/Agent/Paylink/Login")}}`
Method:  POST

JSON
-------

Request

:	```json
:	{
:		"ApiKey":Required(Str(ApiKey)),
:		"ApiSecret":Required(Str(ApiSecret)),
:		"Duration":Optional(Str(ApiSecret)),
:	}
:	```

Response (if successful)

:	```json
:	{
.		"jwt":Required(Str(PJwt)),
.		"expires":Required(DateTime(PExpires))
:	}
:   ```

### Generate Agent api key

Api to generate Api key and secret, that could be used to gain access to resources.

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/Agent/Paylink/GenerateApiKey")}}`
Method:  POST

JSON
-------

Request

:	```json
:	{
        "CanBeOverriden": Optional(CanBeOverriden) (Default: true)
:	}
:	```

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `CanBeOverriden`        | Optional bool which tells if user can manually revoke or regenerate api key without contacting support. |

Response (if successful)

:	```json
:	{
.		"ApiKey":Required(Str(ApiKey)),
.		"ApiSecret":Required(DateTime(ApiSecret)),
.		"Created":Required(DateTime(Created)),
.		"CanBeOverriden":Required(DateTime(CanBeOverriden)),
.		"IsBlocked":Required(DateTime(IsBlocked)),
:	}
:   ```

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `ApiKey`        | Generated api key for account. |
| `ApiSecret`        | ApiSecret for given ApiKey. Store safely, could not be recovered if lost. Api key must be regenerated. |
| `CanBeOverriden`        | If api key could be regenerated. |
| `IsBlocked`        | Is api key blocked. |

### Get Generated Api Key

Retrieves generated agent api key for the account.

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/Agent/Paylink/GetApiKey")}}`
Method:  POST

JSON
-------

Request

:	```json
:	{
:	}
:	```

Response (if successful)

:	```json
:	{
.		"ApiKey":Required(Str(ApiKey)),
.		"ApiSecret":Required(DateTime(ApiSecret)),
.		"Created":Required(DateTime(Created)),
.		"CanBeOverriden":Required(DateTime(CanBeOverriden)),
.		"IsBlocked":Required(DateTime(IsBlocked)),
:	}
:   ```

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `ApiKey`        | Generated api key for account. |
| `ApiSecret`        | ApiSecret for given ApiKey. Store safely, could not be recovered if lost. Api key must be regenerated. |
| `CanBeOverriden`        | If api key could be regenerated. |
| `IsBlocked`        | Is api key blocked. |

### Login (Test purposes) do not use in production

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/Agent/Account/Login")}}`

Method:  POST

Read  **Authentication section** first.
Call this resource to Login into the system using username and password provided by system administrators. 

JSON
-------

Request

:	```json
:	{
:		"userName":Required(Str(PUserName)),
:		"nonce":Required(Str(PNonce)),
        "seconds" Required(Int(PSeconds)),
:		"signature":Required(Str(PSignature))
:	}
:	```

Response (if successful)

:	```json
:	{
.		"jwt":Required(Str(PJwt)),
.		"expires":Required(DateTime(PExpires)),
        "isApproved":Required(Bool)
:	}
:

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `userName`        | Username of the user that should login into system. |
| `nonce`           | A unique random string, at least 32 characters long, with sufficient entropy to not be reused again.|
| `signature` 	    | Cryptographic signature of request. |
| `seconds` 	    | Duration of token in seconds |


Calculating Signature
------------------------

The signature in `PSignature` is calculated as follows.

1. Concatenate the strings `PUserName ":" Host ":" PNonce` and call it `s`, where `Host` is the host/domain name of the server. It is taken from
the HTTP `Host` request header, so it must be the same as is used in the URL of the
request.

2. UTF-8 encode the *password* of the account, and call it `Key`.

3. UTF-8 encode the string `s`, and call it `Data`.

4. Calculate the HMAC-SHA256 signature using `Key` and `Data`, and call it `H`.

5. Base64-encode `H`. The result is the signature of the request.

Javascript Library
---------------------

Use the following method in the [Javascript Library](GenerateSigniture.js) to calculate Signature.

### CreatePasswordResetRequest 

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/CreatePasswordResetRequest.ws")}}`

Method: `POST`

Call this resource to request password reset. This will send verification code to email registered with account.

**Request**

````
{
   "userName":Required(String(PUserName) like "^[\\p{L}\\p{N}]{8,20}$")
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `userName`        | Account for password reset. |

**Response**

````
{
   
}
````

### ResetPassword 

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/ResetPassword.ws")}}`
Method: `POST`

Call this resource to reset password after `CreatePasswordResetRequest` is called.

**Request**

````
{
    "code":Required(String(PCode)),
    "password":Required(String(PPassword)),
	"userName": Required(String(PUserName))
}

````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `code`        | Verification code sent to account email. |
| `password`        | New password for the account (If user has live session password will not be updated right away.) |
| `userName`        | Username for which password reset is initiated. |

**Response**

````
{
   
}

````

### Get Service providers 

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/Payout/API/GetBuyEdalerServiceProviders.ws")}}`
Method: `POST`

Call this resource to read all service providers which buyer can use to pay for given contract.

**Request**

````
{
   "ContractId": Required(Str(PContractId))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `ContractId`        | Id of the contract for which providers should be retrieved. |

**Response Example**

````
{
	 "ServiceProviders": [
        {
            "Name": "Mock Buy eDaler",
            "Id": "VaulterBuyEdaler2",
            "IconUrl": "https://VaulterBuyEdaler2.png",
            "BuyEDalerServiceProvider.Id": "Test",
            "BuyEDalerTemplateContractId": "815164cf097c@legal.lab.neuron.vaulter.rs",
            "QRCode": true
        },
        {
            "Name": "Mock Buy eDaler",
            "Id": "VaulterBuyEdaler2",
            "IconUrl": "https://VaulterBuyEdaler2.png",
            "BuyEDalerServiceProvider.Id": "Test",
            "BuyEDalerTemplateContractId": "815164cf097c@legal.lab.neuron.vaulter.rs",
            "QRCode": true
        }
    ]	 
}
````

### Create Item

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/CreateItem.ws")}}`  
Method: `POST`


Call this resource to register a new Item in Vaulter. JSON in the following format is expected in the call.

**Request**

````
{
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Integer(PPrice)),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)),
    "deliveryDate":Required(DateTime(PDeliveryDate)),
    "paymentDeadline":Required(DateTime(PPaymentDeadline)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerAddress": Required(Str(PBuyerAddress)) ,
    "buyerCity": Optional(Str(PBuyerCity)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber),
    "callbackUrl":Optional(String(PCallbackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "successUrl":Optional(String(PSuccessUrl)),
    "errorUrl":Optional(String(PErrorUrl))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `orderNum`        | ID of item in the caller's system. |
| `title`           | Displayable name of item. |
| `price`           | Price of the item. |
| `currency`        | Currency used by the price. Must be a 3-upper-case-letter currency symbol. |
| `description`     | Displayable description of item. |
| `deliveryDate`    | Delivery Date of item. dd/MM/YYYY |
| `paymentDeadline`    | Payment deadline of item. dd/MM/YYYY. Untill link is valid. |
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPhoneNumber`| Buyer phone number to send notification. |
| `buyerAddress`    | Buyer billing address. |
| `buyerCity`       | Buyer Billing city. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |
| `webPageUrl` | Web page of selling item|
| `successUrl` | Optional Web page where user will be redirected when payment is successfull. Must be valid public accessable web page. |
| `errorUrl` |  Optional Web page where user will be redirected when payment failed. Must be valid public accessable web page.|

**Response**

````
{
	 "Link": "Represents payment link generated for the created item.",
	 "EscrowFee": "Calculated fee that will be added on the item price.",
	 "Currency": "Represents currency which will be used by buyer to pay"	 
}
````

### Create Item IPS

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/CreateItemIPS.ws")}}`  
Method: `POST`


Call this resource to register a new Item in Vaulter for IPS ecommerce payments. JSON in the following format is expected in the call.

**Request**

````
{
   "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency)),
    "description":Required(String(PDescription)),
    "paymentDeadline": Required(String(PPaymentDeadline)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)),
    "buyerAddress": Required(Str(PBuyerAddress)) ,
    "buyerCity": Optional(Str(PBuyerCity)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
	"isMobile":Required(Bool(PIsMobile)),
	"isCompany":Optional(Bool(PIsCompany))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `orderNum`        | ID of item in the caller's system. |
| `title`           | Displayable name of item. |
| `price`           | Price of the item. |
| `currency`        | Currency used by the price. Must be a 3-upper-case-letter currency symbol. |
| `description`     | Displayable description of item. |
| `paymentDeadline`    | Payment deadline of item. dd/MM/YYYY. Untill link is valid. |
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPhoneNumber`| Buyer phone number to send notification. |
| `buyerAddress`    | Buyer billing address. |
| `buyerCity`       | Buyer Billing city. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |
| `webPageUrl`      | Web page of selling item|
| `isMobile`        | If request is coming from mobile or web|
| `isCompany`       | Client is company or person |

**Response**

````
{
	 "Link": "Represents payment link generated for the created item.",
     "TokenId" : "Represents token of the created contract",
	 "EscrowFee": "Calculated fee that will be added on the item price.",
     "BuyerEmail": "Represents Buyer Email",
	 "BuyerPhoneNumber": "Represents Buyer Phone Number",
	 "Currency": "Represents currency which will be used by buyer to pay"	
}
````

### Create Item e-commerce

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/CreateItemEComm.ws")}}`  
Method: `POST`


Call this resource to register a new Item in Vaulter for IPS/Cards ecommerce payments. JSON in the following format is expected in the call.

**Request**

````
{
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency)),
    "description":Required(String(PDescription)),
    "paymentDeadline": Required(String(PPaymentDeadline)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)),
    "buyerAddress": Required(Str(PBuyerAddress)) ,
    "buyerCity": Optional(Str(PBuyerCity)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `orderNum`        | ID of item in the caller's system. |
| `title`           | Displayable name of item. |
| `price`           | Price of the item. |
| `currency`        | Currency used by the price. Must be a 3-upper-case-letter currency symbol. |
| `description`     | Displayable description of item. |
| `paymentDeadline`    | Payment deadline of item. dd/MM/YYYY. Untill link is valid. |
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPhoneNumber`| Buyer phone number to send notification. |
| `buyerAddress`    | Buyer billing address. |
| `buyerCity`       | Buyer Billing city. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |
| `webPageUrl`      | Web page of selling item|

**Response**

````
{
	 "Link": "Represents payment link generated for the created item.",
     "TokenId" : "Represents token of the created contract",
	 "EscrowFee": "Calculated fee that will be added on the item price.",
     "BuyerEmail": "Represents Buyer Email",
	 "BuyerPhoneNumber": "Represents Buyer Phone Number",
	 "Currency": "Represents currency which will be used by buyer to pay"	
}
````

### Initiate Refund

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/InitiateRefund.ws")}}`  
Method: `POST`

Call this resource to perform a void of transaction related to the payment link. JSON in the following format is expected in the call.

**Request**

````
{
    "tokenId": Required(String(PTokenId))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `tokenId`      | Token Id. |

**Response**

````
{
 200 OK 
 {
   "canceled" : true | false
 }
 403 Forbidden
 {
	   // Token not valid.
 }
 400 Bad Request
 {
 }
}
````

### Invalidate contract

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/InvalidateContract.ws")}}`  
Method: `POST`

Call this resource to invalidate contract and link for payment, so buyer will not be able to pay. 
Make sure that buyer is not in the middle of payment, in case of successfull payment, payment will not be registered in contract.

**Request**

````
{
    "tokenId": Required(String(PTokenId))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `tokenId`      | Token Id. |

**Response**

````
{
 200 OK 
 {
   "invalidated" : true | false
 }
 403 Forbidden
 {
	   // Token not valid.
 }
 400 Bad Request
 {
 }
}
````


### Get Contracts

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/GetContracts.ws")}}`  
Method: `POST`

Call this resource to  fetch items created by the owner of the `JWT Token` from the header section of the request.
If token is not provided, or token is invalid, `Bad request` will be thrown, Also if token is expired, or something is wrong with logged party, `Forbidden` will be thrown.

**Request**

````
{
    "DateFrom": Optional(Str(PDateFrom)) format [dd/MM/yyyy],
    "DateTo": Optional(Str(PdateTo)) format [dd/MM/yyyy]
    "TokenId": Optional(Str(PTokenId))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `DateFrom`        | Optional parameter. If not provided, the default value is DateTime.Now minus 1 month  |
| `DateTo`          | Optional parameter. If not provided, the default value is DateTime.Now plus 1 day     |
| `TokenId`         | Optional parameter. If provided, then record with the specified token will be returned  |

**Response**

````
{
 "Creator": (String),
 "TokenId": (String),
 "State":  (String),
 "Created": (Decimal)(Date in miliseconds),
 "CanCancel": (Boolean),
 "IsActive": (Boolean),
 "Paylink": (String),
 "Variables": (Array)
	  [
		  {
			   "Name": "VariableName",
			   "Value": "VariableValue"
		  },
		  {
			   "Name": "VariableName2",
			   "Value": "VariableValue2"
		  },
	  ]
}
````

### Get Legal Identity Info

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/GetLegalIdentityInfo.ws")}}`  
Method: `POST`

Call this resource to  fetch items created by the owner of the `JWT Token` from the header section of the request.
If token is not provided, or token is invalid, `Bad request` will be thrown, Also if token is expired, or something is wrong with logged party, `Forbidden` will be thrown.

**Request**

````
{
}
````

There is no need of properties to be send in a request


**Response**

````
{
    Properties: 
    [
        "FIRST": (String),
        "MIDDLE": (String),
        "LAST":  (String),
        "PNR": (String),
        "COUNTRY": (String),
        "ADDR" : (String),
        "ADDR2" : (String),
        "ZIP" : (String),
        "AREA" : (String),
        "CITY" : (String),
        "REGION" : (String),
        "JID": (String),
        "AGENT" : (String),
        "ORGNAME" : (String),
        "ORGDEPT" : (String),
        "ORGROLE" : (String),
        "ORGCOUNTRY" : (String),
        "ORGNR" : (String),
        "ORGADDR" : (String),
        "ORGADDR2" : (String),
        "ORGZIP" : (String),
        "ORGAREA" : (String),
        "ORGCITY" : (String),
        "ORGREGION" : (String),
        "ORGCOUNTRY" : (String),
        "ORGACTIVITY" : (String),
        "ORGACTIVITYNUM" : (String),
        "ORGTAXNUM" : (String)
    ],
        "HasApplied": (bool),
        "IsSubAccount": (bool)
}
````

### Verify Token
---------------------------

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Auth/VerifyToken.ws")}}`  
Method: `POST`

Read **Authorization section**.

**Request**

````
{
	 // Empty request body
}
````

**Response**

````
200 OK
	{
		 "authorized": true,
         "isApproved": bool,
         "role": "User",
         "contactInformationsPopulated": bool,
         "goToOnBoarding": bool
	}
403 Forbidden
	{
		 // This can mean that token is not valid, user not approved or blocked.
		 // Must try to login again, if 200 OK is not returned, 
		 // User is probably blocked or not permitted.
	}
400 Bad Request
	{
		 //This means that token is not presented, not valid or broken.
	}
````

### Bank Identifier Code

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Bank/GetBic.ws")}}`
Method: `POST`

Call this resource to fetch Open payment service providers for given bankAccount. ***(Only works for sweden)***

**Request**

````
{
   "bankAccount":Required(String(PBankAccount))"
}
````

| Name              | Description |
|:------------------|:------------|
| `bankAccount`      | Valid bank account in Swedish IBAN format. (SE\\d{22})|

**Response**


````
{
	 "bic": (String) "Bank identifier code", 
	 "serviceProviderId": (String) "Id of Open payment provider",
     "eDalerServiceProviderId": (String) "Edaler service provider",
     "serviceProviderType": (String) "Type of Open payment provider"
}
````


### Send Contact Us Email 

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Mail/SendContactUsEmail.ws")}}`  
Method: `POST`

Call this resource to send contact us email.

**Request**

````
{
  "userEmail":Required(String(PUserEmail)),
  "body":Required(String(PBody))
}
````

| Name              | Description |
|:------------------|:------------|
| `userEmail`       | Email from the user which should be used when Powers want to contact. |
| `body`            | Email body that should be send to Powrs info email. |

### Send Verification Email code 

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/SendVerificationEmail.ws")}}`  
Method: `POST`

Call this resource to send email with verification code.

**Request**

````
{
  "email":Required(String(PUserEmail)),
  "countryCode":Required(String(PCountryCode))
}
````

| Name              | Description |
|:------------------|:------------|
| `email`       | Email from the user which should be verified. |
| `countryCode` | Country code will be user for email body text language body. |

**Response**



### Verify Email with code

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/VerifyEmail.ws")}}`  
Method: `POST`

Call this resource to verify email with code.

**Request**

````
{
   "email":Required(String(PEmail)),
   "code":Required(String(PCode))
}
````

| Name              | Description |
|:------------------|:------------|
| `email`       | Email from the user which should be verified. |
| `code`        | Code that user get in email . |

**Response**


````
{
	 "Message": (String) 
}
````

### Create account

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/CreateAccount.ws")}}`  
Method: `POST`

Call this resource to create account with previously verified email. "newSubUser" and "role" should be empty when it is REGISTRATION, but should be filled when it is ADD USER by other logged user. When is creation of new sub user then Bearer token must be passed.

**Request**

````
{
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "repeatedPassword":Required(Str(PRepeatedPassword)),
    "email" : Required(Str(PEmail)), 
	"newSubUser": Optional(Boolean(PNewSubUser)),
    "role": Optional(Int(PUserRole))
}
````

| Name              | Description |
|:------------------|:------------|
| `userName`       | Username for the user, must contains only letters and numbers |
| `password`        | Password for the user |
| `repeatedPassword`        | Repeated Password for the user |
| `email`        | Previously verified email with which user will be created |
| `newSubUser`  | Boolean. True if logged user create new sub user|
| `role`        | INT Role for new user|

**Response**


````
{
	 "userName": (String),
     "jwt": (String),
     "isApproved": (bool)
} 
````

### Deactivate User

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/DeactivateUser.ws")}}`  
Method: `POST`

Call this resource to deactivate user.

**Request**

````
{
  "subUserName":String()
}
````

| Name              | Description |
|:------------------|:------------|
| `subUserName`       | User name from user that you want to deactivare |

**Response**

````
{
	 "Ok" 
}
````

### Get Users

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/GetUsers.ws")}}`  
Method: `POST`

Return the list of users

**Request**

````
{
	 // Empty request body
}
````

**Response**

````
{
    "UserName": (String),
	"First": (String),
	"Last": (String),
	"Email": (String),
	"Role": (String),
	"State": (Int)
} 
````

| Name              | Description |
|:------------------|:------------|
| `UserName`       | Username of the user |
| `First`        | Users first name |
| `Last`        | Users last name |
| `Email`        | Users email |
| `Role`  | Users role. Can be 'Client' or 'User'|
| `State`        | Users state. '1' - Active, '0' - Not active, '-1' - Disabled |

### Role for sub user

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/RoleForSubUser.ws")}}`  
Method: `POST`

Call this end point to a get list of available roles for new user, depending on logged user (jwt).

**Request**

````
{
	 // Empty request body
}
````


**Response**


````
{
	 Dictionary key value pair
} 
````

### Apply for legal Id

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/ApplyForLegalId.ws")}}`  
Method: `POST`

Call this resource to apply for legal identity.

**Request**

````
{
    "FIRST" : Required(Str(PFirstName) like "[\\p{L}\\s]{2,30}"),
    "LAST" : Required(Str(PLastName) like "[\\p{L}\\s]{2,30}"),
    "PNR" : Required(Str(PPersonalNumber) like  "^\\d{13}$"),
    "COUNTRY" : Required(Str(PCountryCode) like "[A-Z]{2}"),
    "ORGNAME": Required(Str(POrgName) like "^[\\p{L}\\s]{2,100}$"),
    "ORGNR": Required(Str(POrgNumber)) like "\\d{8,10}$",
    "ORGCITY": Required(Str(POrgCity) like "\\p{L}{2,50}$"),
    "ORGCOUNTRY": Required(Str(POrgCountry) like "\\p{L}{2,50}$"),
    "ORGADDR": Required(Str(POrgAddress) like "^[\\p{L}\\p{N}\\s]{3,100}$") ,
    "ORGADDR2": Required(Str(POrgAddress2) like "^[\\p{L}\\p{N}\\s]{3,100}$"),
    "ORGBANKNUM": Required(Str(POrgBankNum) like "^(?!.*--)[\\d-]{1,25}$"),
    "ORGDEPT": Required(Str(POrgDept) like "\\p{L}{2,50}$"),
    "ORGROLE": Required(Str(POrgRole) like "\\p{L}{2,50}$"),
    "ORGACTIVITY":  Required(Str(POrgActivity) like "\\p{L}{2,50}$"),
    "ORGACTIVITYNUM":  Required(Str(POrgActivityNumber) like "\\d{4,5}$"),
    "ORGTAXNUM":  Required(Str(POrgTaxNumber) like "\\d{8,10}$")
}
````

| Name              | Description |
|:------------------|:------------|
| `FIRST`       | First Name for the user. |
| `LAST`        | Last Name for the user.|
| `PNR`  | Personal Number for the user |
| `COUNTRY`         | Country for the user.|
| `ORGNAME`         | Organization name  |
| `ORGNR`       | Organization number |
| `ORGCITY`         | Organization city |
| `ORGCOUNTRY`      | Organization country |
| `ORGADDR`         | Organization address |
| `ORGADDR2`        | Organization address 2 |
| `ORGBANKNUM`      | Organization bank number |
| `ORGDEPT`         | Organization department |
| `ORGROLE`         | Organization role |
| `ORGACTIVITY`         | Organization Activity |
| `ORGACTIVITYNUM`         | Activity number |
| `ORGTAXNUM`         | Tax number |

**Response**


````
{
	 "userName": (String),
     "jwt": (String),
     "isApproved": (bool)
} 
````


### Apply for sub legal Id

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/ApplyForSubLegalId.ws")}}`  
Method: `POST`

Call this resource to apply for sub legal identity. Other properties will be taken from creator user.

**Request**

````
{
    "FIRST" : Required(Str(PFirstName)),
    "LAST" : Required(Str(PLastName)),
    "PNR" : Required(Str(PPersonalNumber)),
    "COUNTRY" : Required(Str(PCountryCode))
}
````

| Name              | Description |
|:------------------|:------------|
| `FIRST`       | First Name for the user. |
| `LAST`        | Last Name for the user.|
| `PNR`  | Personal Number for the user |
| `COUNTRY`         | Country for the user.|

**Response**


````
{
	 "userName": (String),
     "jwt": (String),
     "isApproved": (bool)
} 
````

### Update contact info

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/ContactInfo.ws")}}`  
Method: `POST`

Call this resource insert or update contact info

**Request**

````
{
    "PhoneNumber": Required(Str(POrgPhoneNumber) like "^[+]?[0-9]{6,15}$"),
    "WebAddress": Required(Str(POrgWebAddress) like "^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$"),
    "Email": Required(Str(POrgEmailAddress) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "TermsAndConditions": Required(Str(POrgTermsAndConditions) like "^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$")
}
````

| Name              | Description |
|:------------------|:------------|
| `PhoneNumber`       | Phone number to contact company. |
| `WebAddress`        | Web presentation.|
| `Email`  | Support email address to send inquiry to company |
| `TermsAndConditions`  | Terms and conditions for company |

**Response**


````
{	 
} 
````

### Get contact info

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/GetContactInfo.ws")}}`  
Method: `POST`

Retrieves contact information for organizaion.

**Request**

````
{   
}
````

**Response**

| Name              | Description |
|:------------------|:------------|
| `Account `       | Phone number to contact company. |
| `WebAddress`        | Web presentation.|
| `Email `  | Support email address to send inquiry to company |
| `PhoneNumber `  | Phone number to contact company |
| `TermsAndConditions `  | Terms and conditions url for company |

### SavePayoutSchedule

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/Scheduler/SavePayoutSchedule.ws")}}`  
Method: `POST`

Call this resource insert or update payout scheduler informations.

**Request**

````
{
    "Mode": Required(Str(Mode),
    "Day": Required(Int(Day)
}
````

| Name              | Description |
|:------------------|:------------|
| `Mode`        | Mode for scheduler. EveryDay, EveryWeek, EveryMonth. Default (EveryDay) |
| `Day`  | Integer representation of day. For Mode: Weekly: (1-5), Monthly: (1-31). |

**Response**


````
{
    "Message": String
},
BadRequest,
Forbidden
````

### GetPayoutSchedule

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/Scheduler/GetPayoutSchedule.ws")}}`  
Method: `POST`

Call this resource to retrieve update payout scheduler informations.

**Request**

````
{
}
````

**Response**


````
{
    "Mode": Daily|Weekly|Monthly",
    "Day": Int,
    "CanModify": Boolean (Can user modify for his company. Must be admin.)
}
````



### Generate Transactions Report

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Reports/GenerateTransactionsReport.ws")}}`
Method: `POST`

Retrieves base64string of PDF file with successful transactions information.

**Request**

````
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "paymentType": Optional(String(PPaymentType)),  -> IPS|CARDS
    "cardBrands":Optional(String(PCardBrands)),     -> VISA|DINA|MASTERCARD|MAESTRO
    "filterType": Optional(String(PFitlerType))  ->  Report|Payout.  Report: Filter over DateCompleted. Payout: Filter over PayoutDate
````

Creates pdf report for successful transaction for given criteria.

**Response**

| Name              | Description |
|:------------------|:------------|
| `PDF `        |  Base64 encoded file in pdf |
| `Name`        | File name |


### Successful Transactions

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Reports/SuccessfulTransactions.ws")}}`
Method: `POST`

Retrieves Successful Transactions information.

**Request**

````
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "paymentType": Optional(String(PPaymentType)),  -> IPS|CARDS
    "cardBrands":Optional(String(PCardBrands)),     -> VISA|DINA|MASTERCARD|MAESTRO
    "filterType": Optional(String(PFitlerType))  ->  Report|Payout.  Report: Filter over DateCompleted. Payout: Filter over PayoutDate
````

**Response**

| Name              | Description |
|:------------------|:------------|
| `TokenId `        | Token Id . |
| `RemoteId`        | Remote Id|
| `Amount`          | Amount |
| `Currency`        | Currency brand |
| `PaymentType`     | Payment Type (Card or IPS) |
| `CardBrand`       | Brand of card ( VISA,MASTERCARD,DINA, MAESTRO) |


OnBoarding
---------------------

### Get onboarding data

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/GetOnboardingData.ws")}}`  
Method: `POST`

Call this resource to get onboarding data that user already saved.

Token is required. Request body is empty.

*** NOTE: ** Nullable DateTime fields will have substitute string value sith 'Str' sufix. E.g.: 'DateOfBirth' -> 'DateOfBirthStr'


**Request**

````
{
}
````


**Response**

````
{
    "GeneralCompanyInformation": {
        "FullName": "Powrs doo",
        "ShortName": "Powrs",
        "CompanyAddress": "",
        "CompanyCity": "",
        "OrganizationNumber": "10012148",
        "TaxNumber": "112890694",
        "ActivityNumber": "",
        "OtherCompanyActivities": "",
        "BankName": "",
        "BankAccountNumber": "",
        "StampUsage": true,
        "TaxLiability": false,
        "OnboardingPurpose": "Other",
        "PlatformUsage": "UsingVaulterPaylinkService",
        "CompanyWebsite": "",
        "CompanyWebshop": "",
        "LegalRepresentatives": [
            {
                "FullName": "Mirko Kruščić",
                "DateOfBirth": 581032800,
                "DocumentType": "IDCard",
                "DocumentNumber": "",
                "DateOfIssue": 1704063600,
                "PlaceOfIssue": "",
                "StatementOfOfficialDocument": "",
                "IdCard": "LegalRepresentative_1_IdCard_Mirko Kruščić.pdf",
                "IsPoliticallyExposedPerson": false,
                "DateOfBirthStr": "31/05/1988",
                "DateOfIssueStr": "01/01/2024",
                "IssuerName": "",
                "PlaceOfBirth": "Ivanjica",
                "AddressOfResidence": "Zaplanjska 82",
                "CityOfResidence": "Voždovac",
                "PersonalNumber": "3105988792648"
            }
        ],
        "Created": 1716377168,
        "CanEdit": true,
        "UserName": "AgentPLG"
    },
    "CompanyStructure": {
        "CountriesOfBusiness": [
            "Serbia",
            "Croatia",
            "Montenegro"
        ],
        "NameOfTheForeignExchangeAndIDNumber": "",
        "PercentageOfForeignUsers": 10,
        "OffShoreFoundationInOwnerStructure": false,
        "OwnerStructure": "Company",
        "Owners": [
            {
                "FullName": "Mirko Kruščić",
                "PersonalNumber": "3105988792648",
                "DateOfBirth": 581032800,
                "PlaceOfBirth": "Ivanjica",
                "AddressOfResidence": "Zaplanjska 82",
                "CityOfResidence": "Beograd",
                "IsPoliticallyExposedPerson": true,
                "DocumentType": "IDCard",
                "DocumentNumber": "009876248",
                "IssueDate": 1580425200,
                "IssuerName": "PU Za Grad Beograd",
                "DocumentIssuancePlace": "Beograd",
                "Citizenship": "Serbian",
                "OwningPercentage": 25,
                "Role": "Developer",
                "StatementOfOfficialDocument": "Owner_1_Politicall_Mirko Kruščić.pdf",
                "IdCard": "Owner_1_IdCard_Mirko Kruščić.pdf",
                "DateOfBirthStr": "31/05/1988",
                "IssueDateStr": "31/01/2020",
                "CityOfResidence": "Voždovac"
            }
        ],
        "UserName": "AgentPLG"
    },
    "BusinessData": {
        "BusinessModel": "My business model",
        "RetailersNumber": 0,
        "ExpectedMonthlyTurnover": 0,
        "ExpectedYearlyTurnover": 0,
        "ThreeMonthAccountTurnover": 0,
        "CardPaymentPercentage": 0,
        "AverageTransactionAmount": 0,
        "AverageDailyTurnover": 0,
        "CheapestProductAmount": 0,
        "MostExpensiveProductAmount": 0,
        "SellingGoodsWithDelayedDelivery": false,
        "PeriodFromPaymentToDeliveryInDays": 0,
        "ComplaintsPerMonth": 0,
        "ComplaintsPerYear": 0,
        "MethodOfDeliveringGoodsToCustomers": "",
        "DescriptionOfTheGoodsToBeSoldOnline": "",
        "EComerceContactFullName": "Mirko Kruščić",
        "EComerceResponsiblePersonPhone": "066414623",
        "EComerceContactEmail": "mirko.kruscic@powrs.se",
        "IPSOnly": false,
        "UserName": "AgentPLG"
    },
    "LegalDocuments": {
        "BusinessCooperationRequest": "",
        "ContractWithVaulter": "",
        "ContractWithEMI": "",
        "PromissoryNote": "",
        "RequestForPromissoryNotesRegistration": "",
        "CardOfDepositedSignatures": "",
        "UserName": "mirkokrule41"
    }
}
````

### Save onboarding data

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/SaveOnboardingData.ws")}}`  
Method: `POST`

Call this resource save data for onboarding.

**Request**

````
{
   "GeneralCompanyInformation":
   {
        "FullName": "Powrs doo",                -> Mandatory for 'save'
        "ShortName": "Powrs",                   -> Mandatory for 'save'
        "OrganizationNumber": "21761818",       -> Mandatory for 'save'
        "CompanyAddress": "",
        "CompanyCity": "",
        "TaxNumber": "112890694",
        "ActivityNumber": "",
        "OtherCompanyActivities": "",
        "StampUsage": true,
        "BankName": "",
        "BankAccountNumber": "",
        "TaxLiability": true|false,
        "CompanyWebsite": "",
        "CompanyWebshop": "",
        "LegalRepresentatives":[                        ->If nothing populated then send empty array []
            {
                "FullName": "Mirko Kruščić",            -> Mandatory for 'save' if files uploading
                "PersonalNumber": "",
                "DateOfBirth": "25/04/2024",            -> Format: dd/MM/yyyy. If user don't select date, send empty string
                "PlaceOfBirth" : "",
                "AddressOfResidence": "",
                "CityOfResidence": "",
                "IsPoliticallyExposedPerson": true|false,    -> If this is 'true' then 'StatementOfOfficialDocument' can't be null or white space
				"StatementOfOfficialDocumentIsNewUpload": true|false,   -> if it is new file upload then 'true', else 'false'
                "StatementOfOfficialDocument": "",      -> if it is new file uplad then base 64 string, else string from API
				"IdCardIsNewUpload": true|false,            -> if it is new file upload then 'true', else 'false'
                "IdCard": "",                           -> if it is new file uplad then base 64 string, else string from API
                "DocumentType": "IDCard",               -> Can be string: 'IDCard' or 'Passport'
                "PlaceOfIssue": "",
                "IssuerName": "",
                "DateOfIssue": "25/04/2024",            -> Format: dd/MM/yyyy. If user don't select date, send empty string
                "DocumentNumber": ""
            }
        ]
   },
   "CompanyStructure":{
        "CountriesOfBusiness": "Serbia,Croatia,Montenegro", -> string with ',' delimiter and no spaces between
        "NameOfTheForeignExchangeAndIDNumber": "",
        "OffShoreFoundationInOwnerStructure": true|false,    
        "PercentageOfForeignUsers": 0,                  
        "OwnerStructure": "Person",                     -> Can be string: 'Person', 'Company' or 'PersonAndCompany'
        "Owners":[                                      -> If nothing populated then send empty array []
            {
                "FullName": "Mirko Kruščić",            -> Mandatory for 'save' if files uploading
                "PersonalNumber": "",
                "DateOfBirth": "25/04/2024",            -> Format: dd/MM/yyyy. If user don't select date, send empty string
                "PlaceOfBirth": "",
                "AddressOfResidence": "",
                "CityOfResidence": "",
                "IsPoliticallyExposedPerson": true|false,    -> If this is 'true' then 'StatementOfOfficialDocument' can't be null or white space
				"StatementOfOfficialDocumentIsNewUpload": false,       -> if it is new file upload then 'true', else 'false'
                "StatementOfOfficialDocument": "",      -> if it is new file uplad then base 64 string, else string from API
                "OwningPercentage": 25.1,
                "Role": "",
                "DocumentType": "IDCard",               -> Can be string: 'IDCard' or 'Passport'
                "DocumentNumber": "",
                "IssueDate": "25/04/2024",              -> Format: dd/MM/yyyy. If user don't select date, send empty string
                "IssuerName": "",
                "DocumentIssuancePlace": "",
                "Citizenship": "",
				"IdCardIsNewUpload": true|false,            -> if it is new file upload then 'true', else 'false'
                "IdCard": ""                            -> if it is new file uplad then base 64 string, else string from API
            }
        ]
   },
   "BusinessData":{
        "BusinessModel": "My business model",
        "RetailersNumber": 0,
        "ExpectedMonthlyTurnover": 0,
        "ExpectedYearlyTurnover": 0,
        "ThreeMonthAccountTurnover": 0,
        "CardPaymentPercentage": 0,
        "AverageTransactionAmount": 0,
        "AverageDailyTurnover": 0,
        "CheapestProductAmount": 0,
        "MostExpensiveProductAmount": 0,
        "SellingGoodsWithDelayedDelivery": true|false,
        "PeriodFromPaymentToDeliveryInDays": 0,
        "ComplaintsPerMonth": 0,
        "ComplaintsPerYear": 0,
        "MethodOfDeliveringGoodsToCustomers": "",
        "DescriptionOfTheGoodsToBeSoldOnline": "",
        "EComerceContactFullName": "",
        "EComerceResponsiblePersonPhone": "",
        "EComerceContactEmail": "",
        "IPSOnly": true|false
   },
   "LegalDocuments": {
        "ContractWithEMIIsNewUpload": true|false,       -> if it is new file upload then 'true', else 'false'
        "ContractWithEMI": "",                      -> if it is new file uplad then base 64 string, else string from API
        "ContractWithVaulterIsNewUpload": true|false,   -> if it is new file upload then 'true', else 'false'
        "ContractWithVaulter": "",                  -> if it is new file uplad then base 64 string, else string from API
        "PromissoryNoteIsNewUpload": true|false,        -> if it is new file upload then 'true', else 'false'
        "PromissoryNote": "",                       -> if it is new file uplad then base 64 string, else string from API
        "BusinessCooperationRequestIsNewUpload": true|false,    -> if it is new file upload then 'true', else 'false'
        "BusinessCooperationRequest": "",                    -> if it is new file uplad then base 64 string, else string from API
        "RequestForPromissoryNotesRegistrationIsNewUpload": true|false,
        "RequestForPromissoryNotesRegistration": "",
        "CardOfDepositedSignaturesIsNewUpload": true|false,
        "CardOfDepositedSignatures": "",
   }
}
````


**Response**


````
{
    "success": true
}
````

### Submit onboarding data

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/SubmitOnboardingData.ws")}}`  
Method: `POST`

Call this resource to submit onboarding.

**Request**

````
{
}
````


**Response**


````
{
    "success": true
}
````


### Download uploaded onboarding file
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/DownloadFile.ws")}}`  
Method: `POST`

Call this resource to download file that is previously uploaded on server.

**Request**

````
{
    "FileName": string
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `FileName`        | File name retrived from endpoint GetOnboardingData. |

**Response**

````
{
    "File": base 64 ecoded string
}
````

| Name              | Description |
|:------------------|:------------|
| `File `        |  Base64 encoded file |


### Download template file
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/DownloadTemplateFile.ws")}}`  
Method: `POST`

Call this resource to download template PDF file.

**Request**

````
{
	"FileType": string,
	"IsEmptyFile":  boolean,
    "PersonPositionInCompany": string,
	"PersonIndex": int
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
|`FileType`| Type of template file. This value can be one of strings: "ContractWithVaulter", "ContractWithEMI", "StatementOfOfficialDocument", "BusinessCooperationRequest", "PromissoryNote" . |
|`IsEmptyFile`| **`True`**: return template file with no onboarding data populated. **`False`**: return template file populated with onboarding data |
|`PersonPositionInCompany`| Uses with **FileType = StatementOfOfficialDocument**. For other types send empty string. Person position in company: Can be string "LegalRepresentative" or "Owner" |
|`PersonIndex`| Uses with **FileType = StatementOfOfficialDocument**. For other types send 0. Person position in array of LegalRepresentative or Owners, starting from 0 |

**Response**

````
{
    "Name": "File name.pdf",
    "File": "JVBERi0xLjUNJeLjz9MNCjIwIDAgb2JqDTw8L0xpbmVhcml6 ..."
}
````

| Name              | Description |
|:------------------|:------------|
|`Name`|  File name |
|`File`|  Base64 encoded file |


### Get upload file max size
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Onboarding/GetFileMaxSize.ws")}}`  
Method: `POST`

Call this resource to download upload file max size.

**Request**

````
{
}
````

**Response**

````
{
    "fileMaxSize": 25
}
````

| Name              | Description |
|:------------------|:------------|
|`fileMaxSize`|  File max size in MB. Type: int. |


Fee Calculator
---------------------

### FeeCalculator - LogIn
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/FeeCalculator/Auth/LoginFeeCalculator.ws")}}`  
Method: `POST`

Call this resource to log in, to get JWT. Payload is same as `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Auth/Login.ws")}}`  in PLG.

LogIn is restricted to users: **`Emir`**, **`Robert`** and **`AgentPLG`**


### FeeCalculator - SaveData
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/FeeCalculator/Data/SaveFeeCalculatorData.ws")}}`  
Method: `POST`

Call this resource to save data for fee calculator.

**Request**

````
{
	"CompanyName": "Powrs doo",
	"OrganizationNumber": "1234567890",
	"ContactPerson": "",
	"ContactEmail": "",
	"CurrentData":{
		"TotalRevenue": 0,
		"AverageAmount": 0.0,
		"TotalTransactions": 0,
		"CardTransactionPercentage": 0.0,
		"CardFee": 0.0,
		"TotalCardTransactions": 0,
		"TotalCardCost": 0.0
	},
	"CardData":{
		"ShowGroup": true,
		"TransactionPercentage": 0.0,
		"NumberOfTransactions": 0,
		"AverageAmount": 0.0,
		"Fee": 0.0,
		"Cost": 0.0,
		"Saved": 0.0
	},
	"A2AData":{
		"ShowGroup": false,
		"TransactionPercentage": 0.0,
		"NumberOfTransactions": 0,
		"AverageAmount": 0.0,
		"Fee": 0.0,
		"Cost": 0.0,
		"Saved": 0.0		
	},
	"HoldingServiceData":{
		"ShowGroup": false,
		"TransactionPercentage": 0.0,
		"NumberOfTransactions": 0,
		"Fee": 0.0,
		"Cost": 0.0,
		"CostPay": "Buyer",     "Buyer|Seller"
		"KickBackPerTransaction": 0.0,
		"IncomeSummary": 0.0
	},
	"TotalSaved": 0.0,
	"KickBack_Discount": 0.0,
	"Currency": "eur"
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
|`Variable tiyps`   | Variables with value **`0.0`** is decimal, **`0`** is integet, string are in **`""`**, boolean are just **`true`** or **`false`** |
|`Mandatory fields` | **`CompanyName, OrganizationNumber, ContactPerson, ContactEmail`** |


**Response**


````
{
    "success": true
}
````


### FeeCalculator - GetData
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/FeeCalculator/Data/GetFeeCalculatorData.ws")}}`  
Method: `POST`

Call this resource to save data for fee calculator.

**Request**

````
{
	"ObjectId": "2e33a3f7-e26c-3664-200c-25b5b4d492fd"
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
|`ObjectId`   | If this is populated then endpoint returns specific object, else endpoint will return all data saved by user, according JWT |


**Response**

````
{
    "success": true
}
````



### FeeCalculator - Contact support
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/FeeCalculator/Mail/SendMailContactUs.ws")}}`  
Method: `POST`

Call this resource to send mail to support. Before calling this method **data must be saved**, because other details will be populated from db.

**Request**

````
{
	"message": "My test message",
	"organizationNumber": "0123456789"
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
|`message`          | Property type is string, users message to be send to customer support |
|`organizationNumber`   | Property type is string, customer number for getting some necessary data from db |


**Response**

````
{
    "success": true
}
````



### FeeCalculator - Download PDF / Send PDF to email (SHARE)
URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/FeeCalculator/Reports/GenerateFormPDF.ws")}}`  
Method: `POST`

Call this resource to download PDF report or send mail to customer. Before calling this method **data must be saved**, because other details will be populated from db.

**Request**

````
{
    "t_calc_Header": Required(Str(Pt_calc_Header)),
	"t_calc_Now_Title": Required(Str(Pt_calc_Now_Title)),
	"t_calc_Forecast_Title": Required(Str(Pt_calc_Forecast_Title)),
	
	"t_calc_CurrentData_TotalRevenue": Required(Str(Pt_calc_CurrentData_TotalRevenue)),
	"t_calc_CurrentData_AvgAmountPerTrn": Required(Str(Pt_calc_CurrentData_AvgAmountPerTrn)),
	"t_calc_CurrentData_TotalTrn": Required(Str(Pt_calc_CurrentData_TotalTrn)),
	"t_calc_CurrentData_CardTrnPercentage": Required(Str(Pt_calc_CurrentData_CardTrnPercentage)),
	"t_calc_CurrentData_CardFee": Required(Str(Pt_calc_CurrentData_CardFee)),
	"t_calc_CurrentData_TotalCardPercentage_lbl": Required(Str(Pt_calc_CurrentData_TotalCardPercentage_lbl)),
	"t_calc_CurrentData_TotalCardCost_lbl": Required(Str(Pt_calc_CurrentData_TotalCardCost_lbl)),
	
	"t_calc_Card_Title": Required(Str(Pt_calc_Card_Title)),
    "t_calc_Card_TrnPercentage": Required(Str(Pt_calc_Card_TrnPercentage)),
    "t_calc_Card_NumberOfTrn": Required(Str(Pt_calc_Card_NumberOfTrn)),
    "t_calc_Card_AvgAmountPerTrn": Required(Str(Pt_calc_Card_AvgAmountPerTrn)),
    "t_calc_Card_VaulterFee": Required(Str(Pt_calc_Card_VaulterFee)),
    "t_calc_Card_VaulterCost_lbl": Required(Str(Pt_calc_Card_VaulterCost_lbl)),
    "t_calc_Card_Saved_lbl": Required(Str(Pt_calc_Card_Saved_lbl)),
	
	"t_calc_A2A_Title": Required(Str(Pt_calc_A2A_Title)),
    "t_calc_A2A_TrnPercentage": Required(Str(Pt_calc_A2A_TrnPercentage)),
    "t_calc_A2A_NumberOfTrn": Required(Str(Pt_calc_A2A_NumberOfTrn)),
    "t_calc_A2A_AvgAmountPerTrn": Required(Str(Pt_calc_A2A_AvgAmountPerTrn)),
    "t_calc_A2A_VaulterFee": Required(Str(Pt_calc_A2A_VaulterFee)),
    "t_calc_A2A_VaulterCost_lbl": Required(Str(Pt_calc_A2A_VaulterCost_lbl)),
    "t_calc_A2A_Saved_lbl": Required(Str(Pt_calc_A2A_Saved_lbl)),
	
	"t_calc_Holding_Title": Required(Str(Pt_calc_Holding_Title)),
    "t_calc_Holding_TrnPercentage": Required(Str(Pt_calc_Holding_TrnPercentage)),
    "t_calc_Holding_NumberOfTrn": Required(Str(Pt_calc_Holding_NumberOfTrn)),
    "t_calc_Holding_HoldingFee": Required(Str(Pt_calc_Holding_HoldingFee)),
    "t_calc_Holding_VaulterCost_lbl": Required(Str(Pt_calc_Holding_VaulterCost)),
    "t_calc_Holding_WhoWillPayCost_Title": Required(Str(Pt_calc_Holding_WhoWillPayCost_Title)),
    "t_calc_Holding_Buyer_lbl": Required(Str(Pt_calc_Holding_Buyer_lbl)),
    "t_calc_Holding_Seller_lbl": Required(Str(Pt_calc_Holding_Seller_lbl)),
    "t_calc_Holding_KickBackDiscount_Title": Required(Str(Pt_calc_Holding_KickBackDiscount_Title)),
    "t_calc_Holding_KickBackPerTrn": Required(Str(Pt_calc_Holding_KickBackPerTrn)),
    "t_calc_Holding_IncomeSummary_lbl": Required(Str(Pt_calc_Holding_IncomeSummary_lbl)),
	
	"t_calc_Summary_Title": Required(Str(Pt_calc_Summary_Title)),
	"t_calc_Saved_lbl": Required(Str(Pt_calc_Saved_lbl)),
	"t_calc_KickBackDiscount_lbl": Required(Str(Pt_calc_KickBackDiscount_lbl)),
	
	"t_calc_Note": Required(Str(Pt_calc_Note)),
		
	"t_calc_tblHeaderTotalTrn": Required(Str(Pt_calc_tblHeaderTotalTrn)),
	"t_calc_tblData_CardTrn": Required(Str(Pt_calc_tblData_CardTrn)),
	"t_calc_tblData_A2ATrn": Required(Str(Pt_calc_tblData_A2ATrn)),
	"t_calc_tblHeaderHolding": Required(Str(Pt_calc_tblHeaderHolding)),
	"t_calc_tblData_HoldingTrn": Required(Str(Pt_calc_tblData_HoldingTrn)),
    	
	"organizationNumber": Required(Str(PorganizationNumber)),
	"sendToEmail": Required(Bool(PsendToEmail)),
	"email": Optional(Str(Pemail))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
|`t_ ...`          | Property type is string, it is translations for labels in PDF that will be created |
|`sendToEmail / email`   | If the property `sendToEmail` is **`true`** then property `email` must be populated and an email will be send to provided email with PDF in attach |


**Response**

If `sendToEmail` = **`true`** then response will be:

````
{
    "success": true
}
````

If `sendToEmail` = **`false`** then response will be:

````
{
    "Name": "NewFile.pdf",
    "PDF": "file bytes array"
}
````
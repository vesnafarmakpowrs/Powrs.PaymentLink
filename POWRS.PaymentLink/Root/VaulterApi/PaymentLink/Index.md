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
    "deliveryTime":Optional(String(PDeliveryTime)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber),
    "callbackUrl":Optional(String(PCallbackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "supportedPaymentMethods": Optional(String(PSupportedPaymentMethods))
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
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPhoneNumber`| Buyer phone number to send notification. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |
| `webPageUrl` | Web page of selling item|
|`supportedPaymentMethods`| List of Supported Payment methods joined with ";" in single string. |

**Response**

````
{
	 "Link": "Represents payment link generated for the created item.",
	 "EscrowFee": "Calculated fee that will be added on the item price.",
	 "Currency": "Represents currency which will be used by buyer to pay"	 
}
````


### Cancel Item

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Contract/CancelItem.ws")}}`  
Method: `POST`

Call this resource to cancel an Item in Vaulter. JSON in the following format is expected in the call.

**Request**

````
{
    "contractId": Required(String(contractId)),
    "refundAmount" : Optional(int(PRefundAmount))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `contractId`      | Contract Id. This id is returned as a response of sellItem |
| `refundAmount`      | If payment is aleady done from the buyer side, how much to refunt to buyer. Rest of it will be released to seller's bank account. Could not be more than |

**Response**

````
{
 200 OK 
 {
   "canceled" : true
 }
 403 Forbidden
 {
	   // Token not valid.
 }
 400 Bad Request
 {
	 // Amount not valid or contract not valid.
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
}
````

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
         "isApproved": Bool,
         "role": "User",
         "contactInformationsPopulated": Bool
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

### Generate Transactions Report
````
    "from":Required(String(PDateFrom)),
	"to":Required(String(PDateTo)),
	"ips":Required(String(PPaymentType)),
	"cardBrands":Optional(String(PCardBrand))
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
    "DateFrom":Required(String(PDateFrom)),
	"DateTo":Required(String(PDateTo)),
	"PaymentType":Optional(String(PPaymentType)),
	"CardBrand":Optional(String(PCardBrand))
````

**Response**

| Name              | Description |
|:------------------|:------------|
| `TokenId `        | Token Id . |
| `RemoteId`        | Remote Id|
| `Amount`          | Amount |
| `Currency`        | Card brand |
| `PaymentType`     | Payment Type (Card or IPS) |
| `CardBrand`       | Card brand |

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
                "DateOfIssueStr": "01/01/2024"
            }
        ],
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
                "IssueDateStr": "31/01/2020"
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
        "UserName": "AgentPLG"
    },
    "LegalDocuments": {
        "BusinessCooperationRequest": null,
        "ContractWithVaulter": "ContractWithVaulter.pdf",
        "ContractWithEMI": "ContractWithEMI.pdf",
        "PromissoryNote": "PromissoryNote.pdf",
        "PoliticalStatement": "PoliticalStatement.pdf",
        "UserName": "AgentPLG"
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
        "TaxLiability": false,
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
                "IsPoliticallyExposedPerson": false,    -> If this is 'true' then 'StatementOfOfficialDocument' can't be null or white space
				"StatementOfOfficialDocumentIsNewUpload": false,   -> if it is new file upload then 'true', else 'false'
                "StatementOfOfficialDocument": "",      -> if it is new file uplad then base 64 string, else string from API
				"IdCardIsNewUpload": false,            -> if it is new file upload then 'true', else 'false'
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
        "OffShoreFoundationInOwnerStructure": false,    
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
                "IsPoliticallyExposedPerson": false,    -> If this is 'true' then 'StatementOfOfficialDocument' can't be null or white space
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
				"IdCardIsNewUpload": false,            -> if it is new file upload then 'true', else 'false'
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
        "SellingGoodsWithDelayedDelivery": false,
        "PeriodFromPaymentToDeliveryInDays": 0,
        "ComplaintsPerMonth": 0,
        "ComplaintsPerYear": 0
   },
   "LegalDocuments": {
        "ContractWithEMIIsNewUpload": false,       -> if it is new file upload then 'true', else 'false'
        "ContractWithEMI": "",                      -> if it is new file uplad then base 64 string, else string from API
        "ContractWithVaulterIsNewUpload": false,   -> if it is new file upload then 'true', else 'false'
        "ContractWithVaulter": "",                  -> if it is new file uplad then base 64 string, else string from API
        "PromissoryNoteIsNewUpload": false,        -> if it is new file upload then 'true', else 'false'
        "PromissoryNote": "",                       -> if it is new file uplad then base 64 string, else string from API
        "PoliticalStatementIsNewUpload": false,    -> if it is new file upload then 'true', else 'false'
        "PoliticalStatement": ""                    -> if it is new file uplad then base 64 string, else string from API
   }
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
|`IsEmptyFile`| `True`: return template file with no onboarding data populated. `False`: return template file populated with onboarding data |
|`PersonPositionInCompany`| Person position in company:. Can be string "LegalRepresentative" or "Owner" |
|`PersonIndex`| Person position in array of LegalRepresentative or Owners, starting from 0 |

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

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

### Login

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Auth/Login.ws")}}`

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
    "sellerBankAccount":Required(String(PClientBankAccount)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPersonalNum":Optional(String(PBuyerPersonalNum)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber),
    "callbackUrl":Optional(String(PCallbackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "allowedServiceProviders": Optional(String(PAllowedServiceProviders))
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
| `deliveryDate`    | Delivery Date of item. MM//dd/YYY |
| `sellerBankAccount`| Sellers bank account. |
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPersonalNum`| Buyer personal number. Mandatory only for sweden and direct bank transfer |
| `buyerPhoneNumber`| Buyer phone number to send notification. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |
| `webPageUrl` | Web page of selling item|
|`allowedServiceProviders`| List of ServiceProvider id's joined with ";" in single string. (BuyEdalerServiceProvider.Id)|

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
}
````

**Response**

````
{
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

### Get Account Info

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Account/GetAccountInfo.ws")}}`  
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
         "isApproved": Bool
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


````
{
	 "Success": (Bool) 
}
````

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
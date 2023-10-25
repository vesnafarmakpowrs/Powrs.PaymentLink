
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

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/Login.ws")}}`

Method:  POST

Read  **Authentication section** first.
Call this resource to Login into the system using username and password provided by system administrators. 

**Request**

````
{
   "userName":Required,
   "password":Required
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `userName`        | Username of the user that should login into system. |
| `password`        | Password required to login into the system.|

**Response**

```
{
 "jwt": Represents created token.
 "validUntil": Time in miliseconds when token should expire. (30 minutes).
}
```

### Create Item

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/CreateItem.ws")}}`  
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
    "buyerPersonalNum":Required(String(PBuyerPersonalNum)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallbackUrl))
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
| `buyerPersonalNum`| Buyer personal number. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |

**Response**

````
{
	 "Link": "Represents payment link generated for the created item.",
	 "EscrowFee": "Calculated fee that will be added on the item price.".
	 "Currency": "Represents currency which will be used by buyer to pay"	 
}
````


### Cancel Item

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/CancelItem.ws")}}`  
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

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/GetContracts.ws")}}`  
Method: `POST`

Call this resource to  fetch items created by the owner of the `JWT Token` from the header section of the request.
If token is not provided, or token is invalid, `Bad request` will be thrown, Also if token is expired, or something is wrong with logged party, `Forbidden` will be thrown.

**Request**

````
{
  "skip":Required(Int(PSkip)),
  "take":Required(Int(PTake))
}
````

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `skip`      | How many items should be skipped when fetching data. ( Used for pagination. ) If none, use 0. |
| `take`      | How many items should be retrieved when fetching data. If all records, use -1.|

**Response**

````
{
 "TokenId": (String),
 "State":  (String),
 "Created": (Decimal)(Date in miliseconds),
 "CanCancel": (Boolean),
 "IsActive": (Boolean),
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

### Verify Token
---------------------------

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/VerifyToken.ws")}}`  
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
		 "authorized": true
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

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/GetBic.ws")}}`  
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


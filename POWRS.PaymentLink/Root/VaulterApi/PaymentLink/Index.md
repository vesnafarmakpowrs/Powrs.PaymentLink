Title: Vaulter API v1
Description: This document contains information about the Vaulter API (v1)
Author: Vesna Farmak
Date: 2023-06-16
Master: \Master.md
Copyright: \Copyright.md

============================================================================

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

### Encryption

Unecnrypted requests will be rejected. Minimum cipher strength used in TLS layer is 128 bits of security.

### Authentication

Clients of the API will be authenticated using the `WWW-Authentication` mechanism `BASIC`. Each client
needs to [request an acccount](/Feedback.md), to get credentials to integrate with the API.

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
| 418  | I'm a teapot       | Client is a teapot. This is not permitted. |
| 429  | Too Many Requests  | Client has issued too many failed authentication attempts. |

### Methods

Access to the API resources are done using `POST` if nothing else is explicitly written.

### Payloads

Payloads will be JSON, both in requests and in responses. This means the following headers must be present
in all requests:

```
Content-Type: application/json
Accept: application/json
```

#### Descriptive short-hand JSON syntax

When showing JSON structure format in the sections below, a short-hand format explaining the structure
will be used. It should not be confused with real JSON that is being communicated to and from the API.
The basic structure is normal JSON Object-ex-nihilo format. Simplified datatypes will be 
noted as `string`, `integer`, `boolean`, etc. The Datatype may be in composition with `Required(...)`
and `Optional(...)` to denote the corresponding property is required or optional accordingly. If
validation rules apply, they will be included in the description, using one or two comparison operators,
such as `integer>=10`, or `20<integer<100`. Embedded vectors are denoted using `[]`. Embedded objects
are themselves also described as JSON objects.

SellIItem.ws
--------------

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/SellItem.ws")}}`  
Method: `POST`

Call this resource to register a new Item in Vaulter. JSON in the following format is expected in the call.

```
{
    "userName": Required(String(PUserName)),
    "password": Required(String(PPassword)),
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Integer(PPrice)),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)),
    "paymentDeadline":Required(DateTime(PPaymentDeadline)),
    "deliveryDate":Required(DateTime(PDeliveryDate)),
    "sellerBankAccount":Required(String(PClientBankAccount)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPersonalNum":Required(String(PBuyerPersonalNum)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallbackUrl))
}
```

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `userName`        | Client User Name on Vaulter neuron. |
| `password`        | Client Password on Vaulter Neuron. |
| `keyId`           | Client Key Id on Vaulter neuron. |
| `keyPassword`     | Client Key Password on Vaulter Neuron. |
| `orderNum`        | ID of item in the caller's system. |
| `title`           | Displayable name of item. |
| `price`           | Price of the item. |
| `currency`        | Currency used by the price. Must be a 3-upper-case-letter currency symbol. |
| `description`     | Displayable description of item. |
| `paymentDeadline` | Payment deadline of item. |
| `deliveryDate`    | Delivery Date of item. |
| `sellerBankAccount`| Sellers bank account. |
| `buyerFirstName`  | Buyer First name. |
| `buyerLastName`   | Buyer Last name. |
| `buyerEmail`      | Buyer email. |
| `buyerPersonalNum`| Buyer personal number. |
| `buyerCountryCode`| Buyer country code. |
| `callbackUrl`     | URL in caller's system, which Vaulter can call when updates about the item is available. |


CancelItem.ws
--------------

URL: `{{Waher.IoTGateway.Gateway.GetUrl("/VaulterApi/PaymentLink/CancelItem.ws")}}`  
Method: `POST`

Call this resource to cancel an Item in Vaulter. JSON in the following format is expected in the call.

```
{
    "userName": Required(String(userName)),
    "password": Required(String(password)),
    "contractId": Required(String(contractId))
}
```

Description of properties:

| Name              | Description |
|:------------------|:------------|
| `userName`        | Same username used to register an item in our system |
| `password`        | Same password used to register an item in our system |
| `contractId`      | Contract Id. This id is returned as a response of sellItem |

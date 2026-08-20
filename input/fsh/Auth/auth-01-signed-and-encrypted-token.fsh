Instance: auth-01-signed-and-encrypted-token
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-01-signed-and-encrypted-token)
* name = "Auth_01_signed_and_encrypted_token"
* title = "AUTH-01 - A signed and encrypted token is accepted"
* description = "The happy flow. A correctly formed token, signed and then encrypted as security.md prescribes, must be accepted."

* insert serverAimed
* insert variableToken(auth-01-token)
* variable[=].description = "T1: valid, signed and encrypted for the test patient."
* insert variableCorrelationId

* test[+].id = "01"
* test[=].name = "AUTH-01"
* test[=].description = "A signed and encrypted token is accepted"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-01-token)
* insert assertsRequestAccepted

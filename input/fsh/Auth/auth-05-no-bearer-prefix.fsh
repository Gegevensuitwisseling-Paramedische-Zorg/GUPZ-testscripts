Instance: auth-05-no-bearer-prefix
InstanceOf: TestScript
Usage: #definition
* insert metadata(auth-05-no-bearer-prefix)
* name = "Auth_05_no_bearer_prefix"
* title = "AUTH-05 - A token sent without the Bearer prefix is refused"
* description = "security.md prescribes the form Authorization: Bearer <token>. The same token without that prefix must not be accepted."

* insert serverAimed
* insert variableToken(auth-05-token)
* variable[=].description = "T1: valid, signed and encrypted. This case sends it without the Bearer prefix."

* test[+].id = "05"
* test[=].name = "AUTH-05"
* test[=].description = "A token sent without the Bearer prefix is refused"
* insert operationSearchDocumentReference
* insert headersWithoutBearerPrefix(auth-05-token)
* insert assertsRequestRefused

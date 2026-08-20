Instance: auth-07-expired-token
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-07-expired-token)
* name = "Auth_07_expired_token"
* title = "AUTH-07 - An expired token is refused"
* description = "security.md has the platform refuse a request once the expiration time has passed."

* insert serverAimed
* insert variableToken(auth-07-token)
* variable[=].description = "T5: exp in the past, otherwise valid."

* test[+].id = "07"
* test[=].name = "AUTH-07"
* test[=].description = "An expired token is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-07-token)
* insert assertsRequestRefused

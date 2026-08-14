Instance: auth-09-broken-signature
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-09-broken-signature)
* name = "Auth_09_broken_signature"
* title = "AUTH-09 - A token with an invalid signature is refused"
* description = "security.md has the platform validate the signature with the public signing key of the calling system. Which algorithm applies is open, see open-GUPZ issue #67."

* insert serverAimed
* insert variableToken
* variable[=].description = "T7: signature broken, for example signed with a different key."
* insert variableCorrelationId

* test[+].id = "09"
* test[=].name = "AUTH-09"
* test[=].description = "A token with an invalid signature is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken
* insert assertsRequestRefused

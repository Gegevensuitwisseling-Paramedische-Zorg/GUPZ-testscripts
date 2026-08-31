Instance: auth-08-unknown-issuer
InstanceOf: TestScript
Usage: #definition
* insert metadata(auth-08-unknown-issuer)
* name = "Auth_08_unknown_issuer"
* title = "AUTH-08 - A token from an unknown issuer is refused"
* description = "security.md has the platform validate the issuer. Which issuers are trusted and how that trust is established is open, see open-GUPZ issue #27."

* insert serverAimed
* insert variableToken(auth-08-token)
* variable[=].description = "T6: unknown or untrusted iss, otherwise valid."

* test[+].id = "08"
* test[=].name = "AUTH-08"
* test[=].description = "A token from an unknown issuer is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-08-token)
* insert assertsTokenRefused

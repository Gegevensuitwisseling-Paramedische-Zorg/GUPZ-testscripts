Instance: auth-09-broken-signature
InstanceOf: TestScript
Usage: #definition
* insert metadata(auth-09-broken-signature)
* name = "Auth_09_broken_signature"
* title = "AUTH-09 - A token with an invalid signature is refused"
* description = "security.md has the platform validate the signature with the public signing key of the calling system. The algorithm is RS256, settled in open-GUPZ issue #67 and corrected in the specification on 17 August 2026."

* insert serverAimed
* insert variableToken(auth-09-token)
* variable[=].description = "T7: signature broken, for example signed with a different key."

* test[+].id = "09"
* test[=].name = "AUTH-09"
* test[=].description = "A token with an invalid signature is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-09-token)
* insert assertsTokenRefused(true, false)

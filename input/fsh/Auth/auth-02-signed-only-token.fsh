Instance: auth-02-signed-only-token
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-02-signed-only-token)
* name = "Auth_02_signed_only_token"
* title = "AUTH-02 - A signed but not encrypted token is accepted in connectathon mode"
* description = "One of the three token variants agreed for the connectathon of 22 September 2026. Deviates from security.md, which prescribes sign then encrypt, so this case only applies to a platform running in connectathon mode."

* insert serverAimed
* insert variableToken(auth-02-token)
* variable[=].description = "T2: valid, signed, not encrypted."

* test[+].id = "02"
* test[=].name = "AUTH-02"
* test[=].description = "A signed but not encrypted token is accepted in connectathon mode"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-02-token)
* insert assertsRequestAccepted

Instance: auth-03-plain-token
InstanceOf: TestScript
Usage: #definition
* insert metadata(auth-03-plain-token)
* name = "Auth_03_plain_token"
* title = "AUTH-03 - A plain token is accepted in connectathon mode"
* description = "The second connectathon variant: the prescribed content, but neither signed nor encrypted. Note that what plain means exactly has not been agreed; an unsigned JWT per RFC 7519 is a JWS with alg none and an empty signature, which is not the same as a bare base64 payload."

* insert serverAimed
* insert variableToken(auth-03-token)
* variable[=].description = "T3: valid content, neither signed nor encrypted."

* test[+].id = "03"
* test[=].name = "AUTH-03"
* test[=].description = "A plain token is accepted in connectathon mode"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-03-token)
* insert assertsRequestAccepted

Instance: auth-10-wrong-encryption-key
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-10-wrong-encryption-key)
* name = "Auth_10_wrong_encryption_key"
* title = "AUTH-10 - A token encrypted with the wrong key is refused"
* description = "A token the platform cannot decrypt with its private encryption key must be refused. The JWE profile itself is incomplete, see open-GUPZ issue #68."

* insert serverAimed
* insert variableToken
* variable[=].description = "T8: encrypted with a public key that is not the platform's."
* insert variableCorrelationId

* test[+].id = "10"
* test[=].name = "AUTH-10"
* test[=].description = "A token encrypted with the wrong key is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken
* insert assertsRequestRefused

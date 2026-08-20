Instance: auth-10-wrong-encryption-key
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-10-wrong-encryption-key)
* name = "Auth_10_wrong_encryption_key"
* title = "AUTH-10 - A token encrypted with the wrong key is refused"
* description = "A token the platform cannot decrypt with its private encryption key must be refused. Since open-GUPZ issue #68 the JWE profile is fixed: alg RSA-OAEP, enc A256CBC-HS512, cty JWT."

* insert serverAimed
* insert variableToken(auth-10-token)
* variable[=].description = "T8: encrypted with a public key that is not the platform's."
* insert variableCorrelationId

* test[+].id = "10"
* test[=].name = "AUTH-10"
* test[=].description = "A token encrypted with the wrong key is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-10-token)
* insert assertsRequestRefused

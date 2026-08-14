Instance: auth-11-other-patient
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-11-other-patient)
* name = "Auth_11_other_patient"
* title = "AUTH-11 - A request for another patient than the token is refused"
* description = "Tests whether the platform ties the request to the patient claim in the token. Not required by the specification today; raised as open-GUPZ issue #73. Both asserts are warning only until that is decided, so this case reports behaviour without being able to fail a platform."

* insert serverAimed
* insert variableToken
* variable[=].description = "T9: valid, but patient is a different person than the one this request asks for."
* insert variableCorrelationId

* test[+].id = "11"
* test[=].name = "AUTH-11"
* test[=].description = "A request for another patient than the token is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken
* insert assertsRequestRefusedAdvisory

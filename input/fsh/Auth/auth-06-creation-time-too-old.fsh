Instance: auth-06-creation-time-too-old
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-06-creation-time-too-old)
* name = "Auth_06_creation_time_too_old"
* title = "AUTH-06 - A token created more than fifteen minutes ago is refused"
* description = "security.md has the platform refuse a request when the creation time is more than fifteen minutes in the past. What exactly is measured is open, see open-GUPZ issue #69."

* insert serverAimed
* insert variableToken
* variable[=].description = "T4: iat more than fifteen minutes in the past, otherwise valid."
* insert variableCorrelationId

* test[+].id = "06"
* test[=].name = "AUTH-06"
* test[=].description = "A token created more than fifteen minutes ago is refused"
* insert operationSearchDocumentReference
* insert headersWithBearerToken
* insert assertsRequestRefused

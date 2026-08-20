Instance: auth-04-no-authorization-header
InstanceOf: TestScript
Usage: #definition
* insert metadataGupz(auth-04-no-authorization-header)
* name = "Auth_04_no_authorization_header"
* title = "AUTH-04 - A request without an Authorization header is refused"
* description = "security.md requires the token on every call. A request without one must not be answered with data."

* insert serverAimed

* test[+].id = "04"
* test[=].name = "AUTH-04"
* test[=].description = "A request without an Authorization header is refused"
* insert operationSearchDocumentReference
* insert assertsRequestRefused

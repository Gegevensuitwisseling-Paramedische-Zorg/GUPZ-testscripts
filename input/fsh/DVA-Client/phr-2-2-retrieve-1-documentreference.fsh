// Generated from medmij-pdfa-phr-2-2-retrieve-1-documentreference.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: phr-2-2-retrieve-1-documentreference-meta
* insert metadataNictiz(phr-2-2-retrieve-1-documentreference)
* name = "Phr_2_2_retrieve_1_documentreference"
* title = "Scenario 2.2 - Retrieve one DocumentReference resource"
* description = "Scenario 2.2 - Retrieve one DocumentReference resource of XXX-Schulte based on a retrieved reference in a DocumentManifest resource (scenario 2.1)."

RuleSet: phr-2-2-retrieve-1-documentreference-body
* insert clientAimed

* test[+].id = "scenario2-2-retrieve-1-documentreference"
* test[=].name = "Scenario 2.2"
* test[=].description = "Read DocumentReference resource."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test PHR client to read DocumentReference resource."
* test[=].action[=].operation.params = "/pdfa-documentreference4"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer aae7b5aa-d796-4fba-b4d3-852d9043ee66"
* test[=].action[+].assert
  * description = "Confirm that HTTP header Authorization contains the patient token Bearer aae7b5aa-d796-4fba-b4d3-852d9043ee66"
  * direction = #request
  * headerField = "Authorization"
  * stopTestOnFail = false
  * value = "Bearer aae7b5aa-d796-4fba-b4d3-852d9043ee66"
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that query parameter 'patient=' was not present to avoid BSNs in the URL."
  * direction = #request
  * operator = #notContains
  * requestURL = "patient="
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that query parameter 'subject=' was not present to avoid BSNs in the URL."
  * direction = #request
  * operator = #notContains
  * requestURL = "subject="
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the operation was successful"
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Make sure that the server of the test simulator returns the requested DocumentReference resource."
  * direction = #response
  * resource = "DocumentReference"
  * stopTestOnFail = false
  * warningOnly = false

Instance: phr-2-2-retrieve-1-documentreference
InstanceOf: TestScript
Usage: #definition
* insert phr-2-2-retrieve-1-documentreference-meta
* insert phr-2-2-retrieve-1-documentreference-body


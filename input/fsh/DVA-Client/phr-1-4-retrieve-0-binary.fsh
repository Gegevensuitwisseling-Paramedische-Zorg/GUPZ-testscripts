// Generated from medmij-pdfa-phr-1-4-retrieve-0-binary.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: phr-1-4-retrieve-0-binary-meta
* insert metadata(phr-1-4-retrieve-0-binary)
* name = "Phr_1_4_retrieve_0_binary"
* title = "Scenario 1.4 - Retrieve zero Binary resources"
* description = "Scenario 1.4 - Retrieve Binary resource of XXX-Baltus that has a wrong id from retrieved DocumentReference-3."

RuleSet: phr-1-4-retrieve-0-binary-body
* insert clientAimed

* test[+].id = "scenario1-4-retrieve-0-binary"
* test[=].name = "Scenario 1.4"
* test[=].description = "Read Binary resource."
* insert allowExtraRequests
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test PHR client to read Binary resource."
* test[=].action[=].operation.params = "/foutieve-en-onbekend-id"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert assertsIncomingBearerToken
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
  * description = "Confirm that the returned HTTP status is 404 (Not Found) or 410 (Gone)."
  * direction = #response
  * operator = #in
  * responseCode = "404,410"
  * stopTestOnFail = true
  * warningOnly = false

Instance: phr-1-4-retrieve-0-binary
InstanceOf: TestScript
Usage: #definition
* insert phr-1-4-retrieve-0-binary-meta
* insert phr-1-4-retrieve-0-binary-body


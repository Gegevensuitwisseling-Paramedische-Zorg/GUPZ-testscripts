// Generated from medmij-pdfa-phr-1-3-retrieve-2-binary.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: phr-1-3-retrieve-2-binary-meta
* insert metadata(phr-1-3-retrieve-2-binary)
* name = "Phr_1_3_retrieve_2_binary"
* title = "Scenario 1.3 - Retrieve two times one Binary resource"
* description = "Scenario 1.3 - Retrieve Binary resources of XXX-Baltus."

RuleSet: phr-1-3-retrieve-2-binary-body
* insert clientAimed
* fixture[+].id = "binary1-fixture"
* fixture[=].autocreate = false
* fixture[=].autodelete = false
* fixture[=].resource.reference = "../_reference/resources/medmij-pdfa-Binary-kwalificatie1.xml"
* fixture[+].id = "binary2-fixture"
* fixture[=].autocreate = false
* fixture[=].autodelete = false
* fixture[=].resource.reference = "../_reference/resources/medmij-pdfa-Binary-kwalificatie2.xml"
* variable[+].name = "binary1-id"
* variable[=].expression = "Binary.id"
* variable[=].sourceId = "binary1-fixture"
* variable[+].name = "binary2-id"
* variable[=].expression = "Binary.id"
* variable[=].sourceId = "binary2-fixture"

* test[+].id = "scenario1-3-retrieve-binary-1"
* test[=].name = "Scenario 1.3 - Binary 1"
* test[=].description = "Read Binary resource."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test PHR client to read Binary resource."
* test[=].action[=].operation.params = "/${binary1-id}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
* test[=].action[+].assert
  * description = "Confirm that HTTP header Authorization contains the patient token Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
  * direction = #request
  * headerField = "Authorization"
  * stopTestOnFail = false
  * value = "Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
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

* test[+].id = "scenario1-3-retrieve-binary-2"
* test[=].name = "Scenario 1.3 - Binary 2"
* test[=].description = "Read Binary resource"
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test PHR client to read Binary resource."
* test[=].action[=].operation.params = "/${binary2-id}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
* test[=].action[+].assert
  * description = "Confirm that HTTP header Authorization contains the patient token Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
  * direction = #request
  * headerField = "Authorization"
  * stopTestOnFail = false
  * value = "Bearer f92b6141-55db-46d5-a3ae-874b69907d22"
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

Instance: phr-1-3-retrieve-2-binary
InstanceOf: TestScript
Usage: #definition
* insert phr-1-3-retrieve-2-binary-meta
* insert phr-1-3-retrieve-2-binary-body


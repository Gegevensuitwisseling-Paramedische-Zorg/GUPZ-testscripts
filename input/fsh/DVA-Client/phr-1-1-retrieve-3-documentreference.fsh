// Generated from medmij-pdfa-phr-1-1-retrieve-3-documentreference.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: phr-1-1-retrieve-3-documentreference-meta
* insert metadataNictiz(phr-1-1-retrieve-3-documentreference)
* name = "Phr_1_1_retrieve_3_documentreference"
* title = "Scenario 1.1 - Retrieve three DocumentReference resources"
* description = "Scenario 1.1 - Retrieve three DocumentReference resources of XXX-Baltus."

RuleSet: phr-1-1-retrieve-3-documentreference-body
* insert clientAimed

* test[+].id = "scenario1-1-retrieve-3-documentreference"
* test[=].name = "Scenario 1.1"
* test[=].description = "Query all current DocumentReference resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test PHR client to retrieve DocumentReference resources."
* test[=].action[=].operation.params = "?status=current"
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
  * description = "Make sure that the server of the test simulator gives a success response."
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the server of the test simulator returns a Bundle."
  * direction = #response
  * resource = "Bundle"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the response Bundle contains 3 DocumentReference resource(s)."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() = 3"
  * stopTestOnFail = false
  * warningOnly = false

Instance: phr-1-1-retrieve-3-documentreference
InstanceOf: TestScript
Usage: #definition
* insert phr-1-1-retrieve-3-documentreference-meta
* insert phr-1-1-retrieve-3-documentreference-body


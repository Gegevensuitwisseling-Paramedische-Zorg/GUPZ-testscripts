// Generated from medmij-pdfa-phr-1-2-retrieve-0-documentreference.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: phr-1-2-retrieve-0-documentreference-meta
* insert metadata(phr-1-2-retrieve-0-documentreference)
* name = "Phr_1_2_retrieve_0_documentreference"
* title = "Scenario 1.2 - Retrieve zero DocumentReference resources"
* description = "Scenario 1.2 - Retrieve DocumentReference resources of XXX-Baltus that are indexed/created in the period from T-730 to T-365."

RuleSet: phr-1-2-retrieve-0-documentreference-body
* insert clientAimed
* variable[+].name = "T"
* variable[=].defaultValue = "${CURRENTDATE}"
* variable[=].description = "Date that data and queries are expected to be relative to."

* test[+].id = "scenario1-2-retrieve-0-documentreference"
* test[=].name = "Scenario 1.2"
* test[=].description = "Query all current DocumentReference resources of XXX-Baltus that are indexed/created in the period from T-730 to T-365."
* insert allowExtraRequests
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test PHR client to retrieve DocumentReference resources."
* test[=].action[=].operation.params = "?status=current&indexed=ge${DATE, T, D, -730}&indexed=le${DATE, T, D, -365}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeaderToken(121c15f1-f352-485e-979e-04a131bc6238)
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
  * description = "Confirm that the response Bundle contains 0 DocumentReference resource(s)."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() = 0"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned searchset Bundle contains 0 entries or an OperationOutcome."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(OperationOutcome).not()).count() = 0"
  * stopTestOnFail = false
  * warningOnly = false

Instance: phr-1-2-retrieve-0-documentreference
InstanceOf: TestScript
Usage: #definition
* insert phr-1-2-retrieve-0-documentreference-meta
* insert phr-1-2-retrieve-0-documentreference-body


// Generated from medmij-pdfa-xis-1-2-serve-0-documentreference-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-1-2-serve-0-documentreference-NoManifest-meta(format, formatLabel)
* insert metadata(xis-1-2-serve-0-documentreference-NoManifest-{format})
* name = "Xis_1_2_serve_0_documentreference_NoManifest_{format}"
* title = "Scenario 1.2 - Serve zero DocumentReference resources - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.2 - Serve DocumentReference resources of XXX-Baltus that are indexed/created in the period from T-730 to T-365."

RuleSet: xis-1-2-serve-0-documentreference-NoManifest-body
* extension[+].url = "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-rule"
* extension[=].extension[+].url = "ruleId"
* extension[=].extension[=].valueId = "assert-response-queryParamsInSelfLink"
* extension[=].extension[+].url = "path"
* extension[=].extension[=].valueString = "../_reference/rules/assert_response_queryParamsInSelfLink.groovy"
* insert serverAimed
* insert profileToValidate(Bundle-profile, http://hl7.org/fhir/StructureDefinition/Bundle)
* insert variablePatientToken(XXX_Baltus)
* variable[+].name = "T"
* variable[=].defaultValue = "${CURRENTDATE}"
* variable[=].description = "Date that data and queries are expected to be relative to."

* test[+].id = "scenario1-2-serve-0-documentreference"
* test[=].name = "Scenario 1.2"
* test[=].description = "Serve all current DocumentReference resources of XXX-Baltus that are indexed/created in the period from T-730 to T-365."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentReference resources."
* test[=].action[=].operation.params = "?indexed=ge${DATE, T, D,-730}&indexed=le${DATE, T, D,-365}&status=current"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersBaltus
* test[=].action[+].assert
  * description = "Confirm that the operation was successful"
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* insert assertsBundleSearchsetCore
* test[=].action[+].assert
  * description = "Confirm that the response Bundle contains 0 DocumentReference resource(s)."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() = 0"
  * stopTestOnFail = false
  * warningOnly = false

Instance: xis-1-2-serve-0-documentreference-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-1-2-serve-0-documentreference-NoManifest-meta(json, JSON)
* insert xis-1-2-serve-0-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-1-2-serve-0-documentreference-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-1-2-serve-0-documentreference-NoManifest-meta(xml, XML)
* insert xis-1-2-serve-0-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #xml


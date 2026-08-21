// Generated from medmij-pdfa-xis-1-1-serve-2-documentreference-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-1-1-serve-2-documentreference-NoManifest-meta(format, formatLabel)
* insert metadata(xis-1-1-serve-2-documentreference-NoManifest-{format})
* name = "Xis_1_1_serve_2_documentreference_NoManifest_{format}"
* title = "Scenario 1.1 - Serve two DocumentReference resources - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.1 - Serve two DocumentReference resources of XXX-Baltus."

RuleSet: xis-1-1-serve-2-documentreference-NoManifest-body
* extension[+].url = "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-rule"
* extension[=].extension[+].url = "ruleId"
* extension[=].extension[=].valueId = "assert-response-queryParamsInSelfLink"
* extension[=].extension[+].url = "path"
* extension[=].extension[=].valueString = "../_reference/rules/assert_response_queryParamsInSelfLink.groovy"
* insert serverAimed
* insert profileToValidate(Bundle-profile, http://hl7.org/fhir/StructureDefinition/Bundle)
* insert variablePatientToken(XXX_Baltus)

* test[+].id = "scenario1-1-serve-2-documentreference"
* test[=].name = "Scenario 1.1"
* test[=].description = "Serve all current DocumentReference resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentReference resources."
* test[=].action[=].operation.params = "?status=current"
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
  * description = "Confirm that the response Bundle contains 2 DocumentReference resource(s)."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() = 2"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a DocumentReference with LOINC code 68688-1."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68688-1')).exists()"
  * stopTestOnFail = false
  * warningOnly = true
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a DocumentReference with LOINC code 34781-5."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '34781-5')).exists()"
  * stopTestOnFail = false
  * warningOnly = true
* test[=].action[+].assert
  * description = "Confirm that the returned DocumentReference does not have a similar masterIdentifier as the corresponding fixture."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code ='68688-1')).masterIdentifier.value"
  * operator = #notEquals
  * stopTestOnFail = false
  * value = "urn:oid:1.2.276.0.7230010.3.1.2.1787205428.3024.1522314975.220898"
  * warningOnly = true
* test[=].action[+].assert
  * description = "Confirm that the returned DocumentReference does not have a similar masterIdentifier as the corresponding fixture."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code ='34781-5')).masterIdentifier.value"
  * operator = #notEquals
  * stopTestOnFail = false
  * value = "urn:oid:1.2.276.0.7230010.3.1.2.1787205428.3024.1522314975.220899"
  * warningOnly = true

Instance: xis-1-1-serve-2-documentreference-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-1-1-serve-2-documentreference-NoManifest-meta(json, JSON)
* insert xis-1-1-serve-2-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-1-1-serve-2-documentreference-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-1-1-serve-2-documentreference-NoManifest-meta(xml, XML)
* insert xis-1-1-serve-2-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #xml


// Generated from medmij-pdfa-xis-1-4-serve-2-pdfa-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-1-4-serve-2-pdfa-NoManifest-meta(format, formatLabel)
* insert metadata(xis-1-4-serve-2-pdfa-NoManifest-{format})
* name = "Xis_1_4_serve_2_pdfa_NoManifest_{format}"
* title = "Scenario 1.4 - Serve two PDFA documents - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.4 - Serve two PDFA documents of XXX-Baltus through Binary resources. If PDFA documents are served via an HTTP get, scenario 2.5 should be executed instead."

RuleSet: xis-1-4-serve-2-pdfa-NoManifest-body
* extension[+].url = "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-rule"
* extension[=].extension[+].url = "ruleId"
* extension[=].extension[=].valueId = "assert-response-queryParamsInSelfLink"
* extension[=].extension[+].url = "path"
* extension[=].extension[=].valueString = "../_reference/rules/assert_response_queryParamsInSelfLink.groovy"
* insert serverAimed
* insert profileToValidate(Binary-profile, http://hl7.org/fhir/StructureDefinition/Binary)
* insert profileToValidate(Bundle-profile, http://hl7.org/fhir/StructureDefinition/Bundle)
* insert variablePatientToken(XXX_Baltus)
* variable[+].name = "pdfa1-url"
* variable[=].expression = "iif(Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url.startsWith('Binary/'), Bundle.link.where(relation='self').url.replaceMatches('DocumentReference[/?].*$','') + Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url, Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url)"
* variable[=].sourceId = "documentreference-search-response"
* variable[+].name = "pdfa2-url"
* variable[=].expression = "iif(Bundle.entry.select(resource as DocumentReference)[1].content[0].attachment.url.startsWith('Binary/'), Bundle.link.where(relation='self').url.replaceMatches('DocumentReference[/?].*$','') + Bundle.entry.select(resource as DocumentReference)[1].content[0].attachment.url, Bundle.entry.select(resource as DocumentReference)[1].content[0].attachment.url)"
* variable[=].sourceId = "documentreference-search-response"

* test[+].id = "scenario1-4-serve-documentreference"
* test[=].name = "Scenario 1.4"
* test[=].description = "Serve all current DocumentReference resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentReference resources."
* test[=].action[=].operation.params = "?status=current"
* test[=].action[=].operation.responseId = "documentreference-search-response"
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
  * description = "Confirm that the returned searchset Bundle contains at least 2 DocumentReference resources."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() >= 2"
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

* insert assertsDocumentByBinaryReference

* test[+].id = "scenario1-4-serve-pdfa-document-1"
* test[=].name = "Scenario 1.4 - Serve first PDFA document"
* test[=].description = "Serve first PDFA document through a Binary resource."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test XIS server to serve Binary resource."
* test[=].action[=].operation.url = "${pdfa1-url}"
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
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is Binary."
  * direction = #response
  * resource = "Binary"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Binary conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "Binary-profile"
  * warningOnly = false

* test[+].id = "scenario1-4-serve-pdfa-document-2"
* test[=].name = "Scenario 1.4 - Serve second PDFA document"
* test[=].description = "Serve second PDFA document through a Binary resource."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test XIS server to serve Binary resource."
* test[=].action[=].operation.url = "${pdfa2-url}"
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
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is Binary."
  * direction = #response
  * resource = "Binary"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Binary conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "Binary-profile"
  * warningOnly = false

Instance: xis-1-4-serve-2-pdfa-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-1-4-serve-2-pdfa-NoManifest-meta(json, JSON)
* insert xis-1-4-serve-2-pdfa-NoManifest-body
* test[0].action[0].operation.accept = #json
* test[1].action[0].operation.accept = #json
* test[2].action[0].operation.accept = #json

Instance: xis-1-4-serve-2-pdfa-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-1-4-serve-2-pdfa-NoManifest-meta(xml, XML)
* insert xis-1-4-serve-2-pdfa-NoManifest-body
* test[0].action[0].operation.accept = #xml
* test[1].action[0].operation.accept = #xml
* test[2].action[0].operation.accept = #xml


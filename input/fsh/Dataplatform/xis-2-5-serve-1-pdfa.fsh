// Generated from medmij-pdfa-xis-2-5-serve-1-pdfa-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-2-5-serve-1-pdfa-NoManifest-meta(format, formatLabel)
* insert metadata(xis-2-5-serve-1-pdfa-NoManifest-{format})
* name = "Xis_2_5_serve_1_pdfa_NoManifest_{format}"
* title = "Scenario 2.5 - Serve one PDFA document - target NoManifest - {formatLabel} Format"
* description = "Scenario 2.5 - Serve one PDFA document of XXX-Schulte via an HTTP get. If PDFA documents are served through Binary resources, scenario 1.4 should be executed instead."

RuleSet: xis-2-5-serve-1-pdfa-NoManifest-body
* extension[+].url = "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-rule"
* extension[=].extension[+].url = "ruleId"
* extension[=].extension[=].valueId = "assert-response-queryParamsInSelfLink"
* extension[=].extension[+].url = "path"
* extension[=].extension[=].valueString = "../_reference/rules/assert_response_queryParamsInSelfLink.groovy"
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert profileToValidate(Bundle-profile, http://hl7.org/fhir/StructureDefinition/Bundle)
* insert variablePatientToken(XXX_Schulte)
* variable[+].name = "pdfa-url"
* variable[=].expression = "iif(Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url.startsWith('Binary/'), Bundle.link.url.replaceMatches('DocumentReference[/?].*$','') + Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url, Bundle.entry.select(resource as DocumentReference)[0].content[0].attachment.url)"
* variable[=].sourceId = "documentreference-search-response"

* test[+].id = "scenario2-5-serve-1-documentreference"
* test[=].name = "Scenario 2.5 - Search DocumentReference"
* test[=].description = "Serve DocumentReference resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentReference resources."
* test[=].action[=].operation.params = "?status=current"
* test[=].action[=].operation.responseId = "documentreference-search-response"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersSchulte
* test[=].action[+].assert
  * description = "Confirm that the operation was successful"
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* insert assertsBundleSearchsetCore
* test[=].action[+].assert
  * description = "Confirm that the response Bundle contains 1 DocumentReference resource(s), or 2 if the server doesn't support the statuses defined in the test scenario and default to 'current'."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).count() in (1 | 2)"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that all the DocumentReference resources in the Bundle have the status 'current'. This check is needed to make sure that servers which don't support the statuses defined in the test scenario and default to 'current' actually only return results with this status."
  * direction = #response
  * expression = "Bundle.entry.where(resource.is(DocumentReference)).all(resource.status = 'current')"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a DocumentReference with LOINC code 68626-1."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68626-1')).exists()"
  * stopTestOnFail = false
  * warningOnly = true

* test[+].id = "scenario2-5-serve-pdfa-document"
* test[=].name = "Scenario 2.5 - Get PDFA"
* test[=].description = "Serve PDFA document via an HTTP get."
* test[=].action[+].operation.type = http://hl7.org/fhir/http-operations#get
* test[=].action[=].operation.description = "Test XIS server get operation for a document on a known location, using the fullURL."
* test[=].action[=].operation.url = "${pdfa-url}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersSchulte
* test[=].action[+].assert
  * description = "Confirm that the operation was successful"
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is a PDF."
  * direction = #response
  * headerField = "Content-Type"
  * stopTestOnFail = false
  * value = "application/pdf"
  * warningOnly = false

* test[+].id = "scenario2-5-serve-pdfa-document-control"
* test[=].name = "Scenario 2.5 - Get PDFA without authorization header"
* test[=].description = "Test XIS Server to have control over the reference obtained from the DocumentReference.content.attachment.url. This test resolves the fullURL without an authorization header. The request should fail to confirm that the XIS has control over the context. The expected response code is not 200 (OK) but should be e.g. 401, 403 or 404."
* test[=].action[+].operation.type = http://hl7.org/fhir/http-operations#get
* test[=].action[=].operation.description = "Test XIS server get operation for a document on a known location, using the fullURL."
* test[=].action[=].operation.url = "${pdfa-url}"
* test[=].action[=].operation.contentType = #none
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "MedMij-Request-ID"
* test[=].action[=].operation.requestHeader[=].value = "${UUID}"
* test[=].action[=].operation.requestHeader[+].field = "X-Correlation-ID"
* test[=].action[=].operation.requestHeader[=].value = "${X-Correlation-ID}"
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is not 200 (OK)."
  * direction = #response
  * operator = #notEquals
  * responseCode = "200"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Check if the returned HTTP status is 401 (Unauthorized), 403 (Forbidden) or 404 (Not Found). Assert is set to warning only because other HTTP failure codes may be expected as well."
  * direction = #response
  * operator = #in
  * responseCode = "401,403,404"
  * stopTestOnFail = true
  * warningOnly = true

Instance: xis-2-5-serve-1-pdfa-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-2-5-serve-1-pdfa-NoManifest-meta(json, JSON)
* insert xis-2-5-serve-1-pdfa-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-2-5-serve-1-pdfa-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-2-5-serve-1-pdfa-NoManifest-meta(xml, XML)
* insert xis-2-5-serve-1-pdfa-NoManifest-body
* test[0].action[0].operation.accept = #xml


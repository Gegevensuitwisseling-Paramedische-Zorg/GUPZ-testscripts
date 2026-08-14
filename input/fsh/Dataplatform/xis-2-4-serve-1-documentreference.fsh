// Generated from medmij-pdfa-xis-2-4-serve-1-documentreference-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-2-4-serve-1-documentreference-NoManifest-meta(format, formatLabel)
* insert metadataNictiz(xis-2-4-serve-1-documentreference-NoManifest-{format})
* name = "Xis_2_4_serve_1_documentreference_NoManifest_{format}"
* title = "Scenario 2.4 - Serve one DocumentReference resource by resolving reference from DocumentManifest - target NoManifest - {formatLabel} Format"
* description = "Scenario 2.4 - Serve one DocumentReference resource of XXX-Schulte by resolving a reference in a DocumentManifest resource (scenario 2.3)."

RuleSet: xis-2-4-serve-1-documentreference-NoManifest-body
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Schulte, Bearer aae7b5aa-d796-4fba-b4d3-852d9043ee66)
* variable[+].name = "T"
* variable[=].defaultValue = "${CURRENTDATE}"
* variable[=].description = "Date that data and queries are expected to be relative to."
* insert variableCorrelationId

* test[+].id = "scenario2-4-serve-1-documentmanifest"
* test[=].name = "Scenario 2.4 - DocumentManifest"
* test[=].description = "Handle unsupported request for DocumentManifest resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentManifest"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentManifest resources."
* test[=].action[=].operation.params = "?status=current&created=ge${DATE, T, D,-365}&created=le${DATE, T, D,-60}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersSchulte
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 404 (Not Found)."
  * direction = #response
  * operator = #equals
  * responseCode = "404"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is OperationOutcome."
  * direction = #response
  * resource = "OperationOutcome"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned OperationOutcome conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "OperationOutcome-profile"
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the OperationOutcome has .code set to not-supported."
  * direction = #response
  * expression = "OperationOutcome.issue.code = 'not-supported'"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the OperationOutcome has .severity set to fatal or error."
  * direction = #response
  * expression = "OperationOutcome.issue.severity = 'fatal' or OperationOutcome.issue.severity = 'error'"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Although not required, a human-readable description of the problem is strongly encouraged."
  * direction = #response
  * expression = "OperationOutcome.issue.diagnostics.exists() or OperationOutcome.issue.details.text.exists()"
  * stopTestOnFail = false
  * warningOnly = true

Instance: xis-2-4-serve-1-documentreference-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-2-4-serve-1-documentreference-NoManifest-meta(json, JSON)
* insert xis-2-4-serve-1-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-2-4-serve-1-documentreference-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-2-4-serve-1-documentreference-NoManifest-meta(xml, XML)
* insert xis-2-4-serve-1-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #xml


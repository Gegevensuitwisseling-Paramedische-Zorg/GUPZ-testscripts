// Generated from medmij-pdfa-xis-2-2-serve-2-documentmanifest-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-2-2-serve-2-documentmanifest-NoManifest-meta(format, formatLabel)
* insert metadata(xis-2-2-serve-2-documentmanifest-NoManifest-{format})
* name = "Xis_2_2_serve_2_documentmanifest_NoManifest_{format}"
* title = "Scenario 2.2 - Serve two DocumentManifest resources - target NoManifest - {formatLabel} Format"
* description = "Scenario 2.2 - Serve two DocumentManifest resources of XXX-Schulte."

RuleSet: xis-2-2-serve-2-documentmanifest-NoManifest-body
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Schulte)

* test[+].id = "scenario2-2-serve-2-documentmanifest"
* test[=].name = "Scenario 2.2"
* test[=].description = "Handle unsupported request for DocumentManifest resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentManifest"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentManifest resources."
* test[=].action[=].operation.params = "?status=current"
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

Instance: xis-2-2-serve-2-documentmanifest-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-2-2-serve-2-documentmanifest-NoManifest-meta(json, JSON)
* insert xis-2-2-serve-2-documentmanifest-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-2-2-serve-2-documentmanifest-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-2-2-serve-2-documentmanifest-NoManifest-meta(xml, XML)
* insert xis-2-2-serve-2-documentmanifest-NoManifest-body
* test[0].action[0].operation.accept = #xml


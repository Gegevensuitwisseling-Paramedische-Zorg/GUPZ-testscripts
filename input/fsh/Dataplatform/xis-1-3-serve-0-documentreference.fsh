// Generated from medmij-pdfa-xis-1-3-serve-0-documentreference-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-1-3-serve-0-documentreference-NoManifest-meta(format, formatLabel)
* insert metadataNictiz(xis-1-3-serve-0-documentreference-NoManifest-{format})
* name = "Xis_1_3_serve_0_documentreference_NoManifest_{format}"
* title = "Scenario 1.3 - Serve zero DocumentReference resources and one OperationOutcome resource - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.3 - Serve OperationOutome resource for a request with an incorrect search syntax."

RuleSet: xis-1-3-serve-0-documentreference-NoManifest-body
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Baltus, Bearer f92b6141-55db-46d5-a3ae-874b69907d22)
* insert variableCorrelationId

* test[+].id = "scenario1-3-serve-0-documentreference"
* test[=].name = "Scenario 1.3"
* test[=].description = "Serve OperationOutcome resource for the incorrect search request."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentReference resources."
* test[=].action[=].operation.params = "/$"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersBaltus
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 400 (Bad Request)."
  * direction = #response
  * operator = #equals
  * responseCode = "400"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is OperationOutcome."
  * direction = #response
  * resource = "OperationOutcome"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned OperationOutcome conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "OperationOutcome-profile"
  * warningOnly = false

Instance: xis-1-3-serve-0-documentreference-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-1-3-serve-0-documentreference-NoManifest-meta(json, JSON)
* insert xis-1-3-serve-0-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-1-3-serve-0-documentreference-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-1-3-serve-0-documentreference-NoManifest-meta(xml, XML)
* insert xis-1-3-serve-0-documentreference-NoManifest-body
* test[0].action[0].operation.accept = #xml


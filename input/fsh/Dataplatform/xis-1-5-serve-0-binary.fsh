// Generated from medmij-pdfa-xis-1-5-serve-0-binary-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-1-5-serve-0-binary-NoManifest-meta(format, formatLabel)
* insert metadata(xis-1-5-serve-0-binary-NoManifest-{format})
* name = "Xis_1_5_serve_0_binary_NoManifest_{format}"
* title = "Scenario 1.5 - Serve zero Binary resources and one OperationOutcome resource - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.5 - Serve OperationOutome resource for a request with an unknown id."

RuleSet: xis-1-5-serve-0-binary-NoManifest-body
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Baltus, Bearer f92b6141-55db-46d5-a3ae-874b69907d22)

* test[+].id = "scenario1-5-serve-0-binary"
* test[=].name = "Scenario 1.5"
* test[=].description = "Serve OperationOutcome resource because the id of the requested read should not exist at the XIS server."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#read
* test[=].action[=].operation.resource = "Binary"
* test[=].action[=].operation.description = "Test XIS server to serve Binary resource."
* test[=].action[=].operation.params = "/example-pdfa-binary3"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersBaltus
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 404 (Not Found) or 410 (Gone)."
  * direction = #response
  * operator = #in
  * responseCode = "404,410"
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

Instance: xis-1-5-serve-0-binary-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-1-5-serve-0-binary-NoManifest-meta(json, JSON)
* insert xis-1-5-serve-0-binary-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-1-5-serve-0-binary-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-1-5-serve-0-binary-NoManifest-meta(xml, XML)
* insert xis-1-5-serve-0-binary-NoManifest-body
* test[0].action[0].operation.accept = #xml


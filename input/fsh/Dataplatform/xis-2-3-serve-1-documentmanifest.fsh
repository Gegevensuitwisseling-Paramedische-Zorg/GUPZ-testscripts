// Generated from medmij-pdfa-xis-2-3-serve-1-documentmanifest-json.xml with scripts/nictiz-to-fsh.py
// and verified against the original with scripts/compare-testscript.py.

RuleSet: xis-2-3-serve-1-documentmanifest-NoManifest-meta(format, formatLabel)
* insert metadata(xis-2-3-serve-1-documentmanifest-NoManifest-{format})
* name = "Xis_2_3_serve_1_documentmanifest_NoManifest_{format}"
* title = "Scenario 2.3 - Serve one DocumentManifest resource - target NoManifest - {formatLabel} Format"
* description = "Scenario 2.3 - Serve one DocumentManifest resource of XXX-Schulte."

RuleSet: xis-2-3-serve-1-documentmanifest-NoManifest-body
* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Schulte)
* variable[+].name = "T"
* variable[=].defaultValue = "${CURRENTDATE}"
* variable[=].description = "Date that data and queries are expected to be relative to."

* test[+].id = "scenario2-3-serve-1-documentmanifest"
* test[=].name = "Scenario 2.3"
* test[=].description = "Handle unsupported request for DocumentManifest resources."
* test[=].action[+].operation.type = http://hl7.org/fhir/restful-interaction#search
* test[=].action[=].operation.resource = "DocumentManifest"
* test[=].action[=].operation.description = "Test XIS server to serve DocumentManifest resources."
* test[=].action[=].operation.params = "?status=current&created=ge${DATE, T, D,-365}&created=le${DATE, T, D,-60}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* insert requestHeadersSchulte
* insert assertsManifestNotSupported

Instance: xis-2-3-serve-1-documentmanifest-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert xis-2-3-serve-1-documentmanifest-NoManifest-meta(json, JSON)
* insert xis-2-3-serve-1-documentmanifest-NoManifest-body
* test[0].action[0].operation.accept = #json

Instance: xis-2-3-serve-1-documentmanifest-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert xis-2-3-serve-1-documentmanifest-NoManifest-meta(xml, XML)
* insert xis-2-3-serve-1-documentmanifest-NoManifest-body
* test[0].action[0].operation.accept = #xml


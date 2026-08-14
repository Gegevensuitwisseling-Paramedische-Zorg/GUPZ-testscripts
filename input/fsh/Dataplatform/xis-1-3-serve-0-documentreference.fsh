// Scenario 1.3 - a search with invalid syntax must be answered gracefully with
// an OperationOutcome and status 400.
//
// One source, two instances: the JSON and the XML variant differ only in id,
// url, name, title and operation.accept.

RuleSet: scenario1-3(format, formatLabel)
* insert metadataNictiz(xis-1-3-serve-0-documentreference-NoManifest-{format})
* name = "Xis_1_3_serve_0_documentreference_NoManifest_{format}"
* title = "Scenario 1.3 - Serve zero DocumentReference resources and one OperationOutcome resource - target NoManifest - {formatLabel} Format"
* description = "Scenario 1.3 - Serve OperationOutome resource for a request with an incorrect search syntax."

* insert serverAimed
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert variablePatientToken(XXX_Baltus, Bearer f92b6141-55db-46d5-a3ae-874b69907d22)
* insert variableCorrelationId

* test[+].id = "scenario1-3-serve-0-documentreference"
* test[=].name = "Scenario 1.3"
* test[=].description = "Serve OperationOutcome resource for the incorrect search request."

* insert operationSearch(DocumentReference, /$, {format})
* insert requestHeadersBaltus

* insert assertResponseCode(400, Bad Request)
* insert assertResponseResourceType(OperationOutcome)
* insert assertResponseConformsToProfile(OperationOutcome, OperationOutcome-profile)

Instance: xis-1-3-serve-0-documentreference-NoManifest-json
InstanceOf: TestScript
Usage: #definition
* insert scenario1-3(json, JSON)

Instance: xis-1-3-serve-0-documentreference-NoManifest-xml
InstanceOf: TestScript
Usage: #definition
* insert scenario1-3(xml, XML)

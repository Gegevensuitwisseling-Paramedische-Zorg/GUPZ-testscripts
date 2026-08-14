// Wie is het systeem onder test.
//
// serverAimed: het dataplatform is de server onder test, Conformancelab is de
// client. clientAimed is het spiegelbeeld, voor de DVA-Client scripts.

RuleSet: serverAimed
* origin.extension.url = $CL-ext-SUT
* origin.extension.valueBoolean = false
* origin.index = 1
* origin.profile = $origin-types#FHIR-Client
* destination.extension.url = $CL-ext-SUT
* destination.extension.valueBoolean = true
* destination.index = 1
* destination.profile = $destination-types#FHIR-Server

RuleSet: clientAimed
* origin.extension.url = $CL-ext-SUT
* origin.extension.valueBoolean = true
* origin.index = 1
* origin.profile = $origin-types#FHIR-Client
* destination.extension.url = $CL-ext-SUT
* destination.extension.valueBoolean = false
* destination.index = 1
* destination.profile = $destination-types#FHIR-Server

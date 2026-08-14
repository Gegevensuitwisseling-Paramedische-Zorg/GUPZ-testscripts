// Which side is the system under test.
//
// serverAimed: the data platform is the server under test and Conformancelab
// acts as the client. clientAimed is the mirror image, used by the DVA-Client
// scripts.
//
// Interoplab-CL-ext-SUT is on its way out. Interoplab will replace it with a
// profile on origin.profile and destination.profile. That specification does
// not exist yet and the extension keeps working in the meantime. These two
// RuleSets are the only place where the extension is written, so the migration
// is a change to this one file.

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

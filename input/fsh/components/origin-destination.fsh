// Which side is the system under test.
//
// serverAimed: the data platform is the server under test and Conformancelab
// acts as the client. clientAimed is the mirror image, used by the DVA
// scripts.
//
// A destination carries a title, which is the name Conformancelab shows at
// setup. The system under test is the side that does not carry a Conformancelab
// profile. Conformancelab-Client means Conformancelab initiates the operations,
// so the FHIR-Server opposite it is under test; Conformancelab-Server means
// Conformancelab answers them, so the FHIR-Client opposite it is under test.
//
// This replaces Interoplab-CL-ext-SUT, which the IG deprecated on 18 August
// 2026. The extension still works for backwards compatibility, and the imported
// scenario 2.5, which is kept as Nictiz wrote it, still uses it.

RuleSet: serverAimed
* origin.index = 1
* origin.profile = $CL-origin-profile#Conformancelab-Client
* destination.index = 1
* destination.profile = $destination-types#FHIR-Server
* destination.extension[+].url = $CL-destination-title
* destination.extension[=].valueString = "Data platform"

RuleSet: clientAimed
* origin.index = 1
* origin.profile = $origin-types#FHIR-Client
* destination.index = 1
* destination.profile = $CL-destination-profile#Conformancelab-Server
* destination.extension[+].url = $CL-destination-title
* destination.extension[=].valueString = "FHIR endpoint"

// A scenario that is answered from a WireMock stub addresses a different
// endpoint than ordinary FHIR traffic. `${STUB-ENDPOINT}` resolves to it, so
// Conformancelab hands the address out at setup and the caller does not have
// to work it out.
RuleSet: clientAimedStub
* origin.index = 1
* origin.profile = $origin-types#FHIR-Client
* destination.index = 1
* destination.profile = $CL-destination-profile#Conformancelab-Server
* destination.url = "${STUB-ENDPOINT}"
* destination.extension[+].url = $CL-destination-title
* destination.extension[=].valueString = "Stub endpoint"

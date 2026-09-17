// Can the DocumentManifest asserts be satisfied at all?
//
// Scenarios 2.2, 2.3 and 2.4 require the 404 with an OperationOutcome that
// `pdfa.md` prescribes (D-04). They have only ever been seen to fail: the FHIR
// server behind the tests supports DocumentManifest and answers 200. An assert
// that has never been satisfied may be impossible to satisfy, and a supplier who
// implemented it correctly would be the one to find out.
//
// So the same RuleSet those three insert is inserted here against a stub that
// answers exactly what the specification prescribes. Green means the asserts can
// be met. See D-31.

Instance: self-pdfa-01-manifest-refusal
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-pdfa-01-manifest-refusal)
* name = "Self_pdfa_01_manifest_refusal"
* title = "SELF-PDFA-01 - The DocumentManifest asserts pass on the prescribed refusal"
* description = "Serves the 404 with an OperationOutcome carrying code not-supported that pdfa.md prescribes for a request on DocumentManifest, and runs the asserts of scenarios 2.2, 2.3 and 2.4 against it."

* insert clientAimedStub
* insert profileToValidate(OperationOutcome-profile, http://hl7.org/fhir/StructureDefinition/OperationOutcome)
* insert stubFixture(manifest-not-supported, manifest-not-supported.stub)

* test[+].id = "self-pdfa-01"
* test[=].name = "SELF-PDFA-01"
* test[=].description = "Every assert has to pass, except the one on the profile. That one cannot run here: profile validation reads the payload from the proxy log and a stub never reaches the proxy. It is a warning for that reason."
* insert allowExtraRequests
* insert operationServeStub(manifest-not-supported)
* test[=].action[=].operation.description = "Answer with the refusal pdfa.md prescribes for DocumentManifest."
* insert assertsManifestNotSupported(true)

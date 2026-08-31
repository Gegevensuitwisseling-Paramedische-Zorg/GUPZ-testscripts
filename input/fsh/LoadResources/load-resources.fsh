// Written by hand rather than produced by scripts/nictiz-to-fsh.py. That
// generator assumes an origin, a destination and no copyright, none of which
// holds here, and it silently drops setup and teardown. Verified against the
// original with scripts/compare-testscript.py before the XML was removed.

Instance: resources-purgecreateupdate-xml
InstanceOf: TestScript
Usage: #definition
* insert metadata(resources-purgecreateupdate-xml)
* name = "Load_Test_Resources_Purge_Create_Update_XML"
* title = "Load the test resources onto a server"
* description = "Load test resources using the update (PUT) operation of the target FHIR server for use in testing. All resource ids are pre-defined. The target FHIR server is expected to support resource create via the update (PUT) operation for client assigned ids. This is provisioning, not a conformance test: a GUPZ data platform reads only, so this set is meant for a reference server used in a dry run. Trimmed to what the scenarios on both sides need: two patients, seven DocumentReference resources and four Binary resources. Left out are the five DocumentManifest fixtures, which no GUPZ scenario reads and which the specification does not support, and everything of XXX_Ellens, who appears in no scenario on either side. The documents of XXX_Schulte that are superseded or entered-in-error are kept on purpose: scenario 2.1 checks that only current documents come back, which needs something to filter out. The access tokens are fixed and resolve through Configuration/QualificationTokens.json."

// The four PDF documents, then the document references that point at them, then
// the two patients they belong to. Document reference 3 has a deliberately
// dangling Binary reference; the client aimed scenario 1.4 reads it and expects
// a 404, and scenario 1.1 counts on it being there.
* insert loadFixture(Binary, pdfa-binary1, medmij-pdfa-Binary-kwalificatie1.xml)
* insert loadFixture(Binary, pdfa-binary2, medmij-pdfa-Binary-kwalificatie2.xml)
* insert loadFixture(Binary, pdfa-binary3, medmij-pdfa-Binary-kwalificatie3.xml)
* insert loadFixture(Binary, pdfa-binary4, medmij-pdfa-Binary-kwalificatie4.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference1, medmij-pdfa-DocumentReference-kwalificatie1.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference2, medmij-pdfa-DocumentReference-kwalificatie2.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference3, medmij-pdfa-DocumentReference-kwalificatie3.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference4, medmij-pdfa-DocumentReference-kwalificatie4.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference5, medmij-pdfa-DocumentReference-kwalificatie5.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference6, medmij-pdfa-DocumentReference-kwalificatie6.xml)
* insert loadFixture(DocumentReference, pdfa-documentreference7, medmij-pdfa-DocumentReference-kwalificatie7.xml)
* insert loadFixture(Patient, example-pdfa-kwalificatie1, medmij-pdfa-Patient-kwalificatie1.xml)
* insert loadFixture(Patient, example-pdfa-kwalificatie2, medmij-pdfa-Patient-kwalificatie2.xml)

// Sixteen of the fixtures carry dates written relative to T, in the form
// ${DATE, T, D, -365}, so this variable is load bearing even though no
// expression in this script refers to it.
* variable[+].name = "T"
* variable[=].defaultValue = "${CURRENTDATE}"
* variable[=].description = "Date that data and queries are expected to be relative to."

* insert purgePatient(example-pdfa-kwalificatie1, 121c15f1-f352-485e-979e-04a131bc6238)
* insert purgePatient(example-pdfa-kwalificatie2, 79339c59-4908-4b0d-8b53-4520f9e4c7d5)

* test[+].id = "Step1-LoadTestResourceCreate"
* test[=].name = "Step1-LoadTestResourceCreate"
* test[=].description = "Load test resources using the update (PUT) operation of the target FHIR server for use in testing. All resource ids are pre-defined. The target FHIR server is expected to support resource create via the update (PUT) operation for client assigned ids."

// Patients first, then the documents that reference them.
* insert putFixture(Patient, example-pdfa-kwalificatie1, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(Patient, example-pdfa-kwalificatie2, 79339c59-4908-4b0d-8b53-4520f9e4c7d5)
* insert putFixture(Binary, pdfa-binary1, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(Binary, pdfa-binary2, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(Binary, pdfa-binary3, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(Binary, pdfa-binary4, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference1, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference2, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference3, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference4, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference5, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference6, 121c15f1-f352-485e-979e-04a131bc6238)
* insert putFixture(DocumentReference, pdfa-documentreference7, 121c15f1-f352-485e-979e-04a131bc6238)

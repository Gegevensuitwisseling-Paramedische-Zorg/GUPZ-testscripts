// Metadata die op elk TestScript hetzelfde is.
//
// LET OP: url, version, publisher en contact zijn in deze fase nog die van
// Nictiz, zodat de gegenereerde JSON een-op-een te vergelijken is met het
// origineel. Het vaststellen van de GUPZ-canonical en het eigen publisher- en
// contactgegeven is een aparte stap.

RuleSet: metadataNictiz(id)
* id = "{id}"
* url = "http://nictiz.nl/fhir/TestScript/{id}"
* version = "stu3-2.0-patchlevel 2026.30"
* status = #active
* publisher = "Nictiz"
* contact.name = "Nictiz"
* contact.telecom.system = #email
* contact.telecom.value = "kwalificatie@nictiz.nl"
* contact.telecom.use = #work

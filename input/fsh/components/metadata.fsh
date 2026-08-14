// Metadata that is identical on every TestScript.
//
// NOTE: url, version, publisher and contact still carry the Nictiz values, so
// that the generated JSON can be compared one to one against the original.
// Deciding on the GUPZ canonical and on our own publisher and contact details
// is a separate step.

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

// Metadata that is identical on every TestScript.
//
// The imported scripts carried Nictiz's url, version, publisher and contact, so
// that the generated JSON could be compared one to one against the original.
// That reason lapsed once the material started to deviate on purpose, and
// publishing somebody else's version number invites the reading that these are
// the Nictiz qualification scripts, which they are not. They now carry ours.
//
// The canonical is provisional. It comes from sushi-config.yaml, which SUSHI
// uses to derive the url of every Instance.

RuleSet: metadata(id)
* id = "{id}"
* version = "0.1.0"
* status = #active
* publisher = "GUPZ"
* contact.name = "GUPZ"
* contact.telecom.system = #url
* contact.telecom.value = "https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts"

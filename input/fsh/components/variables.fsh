// Variabelen die de operator bij de testopzet kan overschrijven.
//
// Het token is bewust een gewone variabele met een default en geen door
// Conformancelab gegenereerd token. Daarmee kan een vooraf aangeleverd,
// getekend GUPZ-token worden ingeplakt zonder dat de engine iets hoeft te
// ondertekenen.

RuleSet: variablePatientToken(patient, token)
* variable[+].name = "patient-token-{patient}"
* variable[=].defaultValue = "{token}"
* variable[=].description = "OAuth Token for patient '{patient}'"

RuleSet: variableCorrelationId
* variable[+].name = "X-Correlation-ID"
* variable[=].defaultValue = "${UUID}"
* variable[=].description = "X-Correlation-ID, by default a UUID following the MedMij Afsprakenstelsel. Does not have to be edited, see https://nictiz.atlassian.net/browse/MM-5132 for more information"

// Validatieprofiel waar een assert met validateProfileId naar verwijst. De
// canonical staat op het element zelf, het id is de sleutel voor de assert.
RuleSet: profileToValidate(profileId, canonical)
* profile[+] = "{canonical}"
* profile[=].id = "{profileId}"

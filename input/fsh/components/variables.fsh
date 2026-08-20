// Variables the operator can override when setting up a test run.
//
// The token is deliberately a plain variable with a default rather than a token
// minted by Conformancelab. That way a pre-signed GUPZ token can be pasted in
// without the engine having to sign anything.

RuleSet: variablePatientToken(patient, token)
* variable[+].name = "patient-token-{patient}"
* variable[=].defaultValue = "{token}"
* variable[=].description = "OAuth Token for patient '{patient}'"


// Validation profile that an assert refers to through validateProfileId. The
// canonical sits on the element itself, the id is the key used by the assert.
RuleSet: profileToValidate(profileId, canonical)
* profile[+] = "{canonical}"
* profile[=].id = "{profileId}"

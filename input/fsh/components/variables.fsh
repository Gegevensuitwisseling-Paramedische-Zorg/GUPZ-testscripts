// Variables the operator can override when setting up a test run.
//
// The token is a plain variable rather than a token minted by Conformancelab.
// The engine can sign a JWS but cannot produce the nested JWT that open-GUPZ
// prescribes, and it gives no control over the kid, so a pre-signed token is
// pasted in instead. The same choice is made in the auth Test Set; see
// components/auth.fsh.
//
// The variable carries no default. The imported scripts defaulted to a MedMij
// qualification token, an opaque OAuth token that only the Nictiz simulator
// recognises; a GUPZ data platform expects a JWS inside a JWE and rejects it.
// A wrong default is worse than none, because it runs and fails for a reason
// that has nothing to do with the platform.
//
// The name is repeated across scripts on purpose. Conformancelab spots a
// variable name used in more than one scenario and offers to fill it once for
// all of them, which is exactly what is wanted here: ten scenarios share the
// token of one patient. In the auth Test Set the names are unique for the
// opposite reason, because every case there needs a different token.

RuleSet: variablePatientToken(patient)
* variable[+].name = "patient-token-{patient}"
* variable[=].description = "GUPZ token for test patient '{patient}'. Paste the nested JWT issued for this patient; the script adds the Bearer prefix. A token used in a patient bound request is patient specific since open-GUPZ issue #73 closed on 18 August, so each test patient needs a token of their own."


// Validation profile that an assert refers to through validateProfileId. The
// canonical sits on the element itself, the id is the key used by the assert.
RuleSet: profileToValidate(profileId, canonical)
* profile[+] = "{canonical}"
* profile[=].id = "{profileId}"

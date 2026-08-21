// Request headers for the operations directed at the server under test.
//
// One RuleSet per test person rather than one parameterised RuleSet, because
// the values contain Conformancelab placeholders such as ${UUID}. SUSHI
// substitutes anything in braces inside a parameterised RuleSet, which would
// corrupt those placeholders.
//
// Only Authorization is sent. The imported scripts also carried
// MedMij-Request-ID and X-Correlation-ID, which the MedMij Afsprakenstelsel
// requires; the data platform sits outside that framework, so they are dropped.
// See scenario-selection.md.

// The Bearer prefix lives here and not in the variable, so the operator pastes
// the bare token. The imported scripts carried the prefix inside the default
// value, which made it easy to paste a token and end up with a header that has
// no scheme at all. Same construction as the auth Test Set.

RuleSet: requestHeadersBaltus
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer ${patient-token-XXX_Baltus}"

RuleSet: requestHeadersSchulte
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer ${patient-token-XXX_Schulte}"

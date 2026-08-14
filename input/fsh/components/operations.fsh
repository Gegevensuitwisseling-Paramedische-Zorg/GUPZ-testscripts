// Request headers for the operations directed at the server under test.
//
// One RuleSet per test person rather than one parameterised RuleSet, because
// the values contain Conformancelab placeholders such as ${UUID}. SUSHI
// substitutes anything in braces inside a parameterised RuleSet, which would
// corrupt those placeholders.
//
// Authorization, MedMij-Request-ID and X-Correlation-ID are what the MedMij
// Afsprakenstelsel requires on every resource request.

RuleSet: requestHeadersBaltus
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "${patient-token-XXX_Baltus}"
* test[=].action[=].operation.requestHeader[+].field = "MedMij-Request-ID"
* test[=].action[=].operation.requestHeader[=].value = "${UUID}"
* test[=].action[=].operation.requestHeader[+].field = "X-Correlation-ID"
* test[=].action[=].operation.requestHeader[=].value = "${X-Correlation-ID}"

RuleSet: requestHeadersSchulte
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "${patient-token-XXX_Schulte}"
* test[=].action[=].operation.requestHeader[+].field = "MedMij-Request-ID"
* test[=].action[=].operation.requestHeader[=].value = "${UUID}"
* test[=].action[=].operation.requestHeader[+].field = "X-Correlation-ID"
* test[=].action[=].operation.requestHeader[=].value = "${X-Correlation-ID}"

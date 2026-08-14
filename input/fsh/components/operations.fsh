// Operations directed at the server under test.
//
// The standard headers live in their own RuleSet without parameters, because
// their values contain Conformancelab placeholders such as ${UUID}. Those
// braces must not be touched by SUSHI parameter substitution.

RuleSet: operationSearch(resource, params, format)
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "{resource}"
* test[=].action[=].operation.description = "Test XIS server to serve {resource} resources."
* test[=].action[=].operation.accept = #{format}
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.params = "{params}"

// Authorization, MedMij-Request-ID and X-Correlation-ID, as the MedMij
// Afsprakenstelsel requires them on every resource request.
RuleSet: requestHeadersBaltus
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "${patient-token-XXX_Baltus}"
* test[=].action[=].operation.requestHeader[+].field = "MedMij-Request-ID"
* test[=].action[=].operation.requestHeader[=].value = "${UUID}"
* test[=].action[=].operation.requestHeader[+].field = "X-Correlation-ID"
* test[=].action[=].operation.requestHeader[=].value = "${X-Correlation-ID}"

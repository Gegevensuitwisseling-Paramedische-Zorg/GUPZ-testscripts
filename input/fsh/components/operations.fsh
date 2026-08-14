// Operaties richting de server onder test.
//
// De standaardheaders staan in een eigen RuleSet zonder parameters, omdat de
// waarden Conformancelab-placeholders als ${UUID} bevatten. Die accolades
// mogen niet door de parametersubstitutie van SUSHI worden aangeraakt.

RuleSet: operationSearch(resource, params, format)
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "{resource}"
* test[=].action[=].operation.description = "Test XIS server to serve {resource} resources."
* test[=].action[=].operation.accept = #{format}
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.params = "{params}"

// Authorization, MedMij-Request-ID en X-Correlation-ID zoals het MedMij
// Afsprakenstelsel ze op elk resource-request verlangt.
RuleSet: requestHeadersBaltus
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "${patient-token-XXX_Baltus}"
* test[=].action[=].operation.requestHeader[+].field = "MedMij-Request-ID"
* test[=].action[=].operation.requestHeader[=].value = "${UUID}"
* test[=].action[=].operation.requestHeader[+].field = "X-Correlation-ID"
* test[=].action[=].operation.requestHeader[=].value = "${X-Correlation-ID}"

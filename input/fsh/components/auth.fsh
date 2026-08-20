// Building blocks for the auth Test Set.
//
// Unlike the PDF/A scripts these are ours, not converted from Nictiz. They test
// what the data platform does with a token, never the token itself: the engine
// cannot decode a JWT, and for a server aimed test that is no loss.
//
// The token is a variable without a default. The operator pastes the token that
// belongs to the case; the variable description says which one. That keeps the
// scripts independent of how tokens are produced, and it is the only workable
// approach for a signed and encrypted token, which Conformancelab cannot make.
//
// These scripts set no url of their own, so SUSHI derives one from the
// canonical in sushi-config.yaml. That canonical is still a placeholder waiting
// on a GUPZ decision, so the url will change with it. Nothing depends on the
// value; Conformancelab identifies a script by its id.


// Every case declares its own variable name, prefixed with the case id. That is
// deliberate: Conformancelab spots a name that occurs in more than one scenario
// and offers to fill it once for all of them. For this set that shortcut is a
// trap, because each case needs a different token. Unique names remove the
// offer. X-Correlation-ID may stay shared, since a variable with a default is
// not offered.
RuleSet: variableToken(name)
* variable[+].name = "{name}"

// The request itself is incidental: a search that any conformant platform
// supports, so that the outcome says something about the token and not about
// the query. Kept identical to PDF/A scenario 1.1 on purpose.
RuleSet: operationSearchDocumentReference
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Search for current DocumentReference resources."
* test[=].action[=].operation.accept = #json
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.params = "?status=current"

RuleSet: headersWithBearerToken(name)
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer ${{name}}"

// The same token, but without the Bearer prefix the specification prescribes.
RuleSet: headersWithoutBearerPrefix(name)
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "${{name}}"


RuleSet: assertsRequestAccepted
* test[=].action[+].assert
  * description = "Confirm that the operation was successful."
  * direction = #response
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is Bundle."
  * direction = #response
  * resource = "Bundle"
  * stopTestOnFail = false
  * warningOnly = false

// Two layers, following the pattern Nictiz uses for the same problem in PDF/A
// scenario 2.5. The hard assert only states that the request did not succeed,
// which is all that can be asserted while open-GUPZ issue #70 leaves the
// response to a refused token unspecified. The second assert names the codes we
// expect and is warning only, so a platform that answers differently does not
// fail on an expectation that is not written down.
RuleSet: assertsRequestRefused
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is not 200 (OK)."
  * direction = #response
  * operator = #notEquals
  * responseCode = "200"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Check if the returned HTTP status is 401 (Unauthorized) or 403 (Forbidden). Assert is set to warning only because open-GUPZ issue #70 does not specify the response to a refused token, so other failure codes may be expected as well."
  * direction = #response
  * operator = #in
  * responseCode = "401,403"
  * stopTestOnFail = false
  * warningOnly = true

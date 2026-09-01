// Building blocks for the auth Test Set.
//
// Unlike the PDF/A scripts these are ours, not converted from Nictiz. They test
// what the data platform does with a token, never the token itself. For a
// server aimed test that is no loss: we made the token ourselves.
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

// security.md settles the shape of a refusal: a 401 with a WWW-Authenticate
// header carrying error="invalid_token", and an OperationOutcome with severity
// error and code login. All three hold whether or not the platform runs in the
// test mode that allows extra detail; that mode only widens error_description
// and diagnostics, which is why neither is asserted. See D-30.
//
// Every case in this set that presents a token the platform must reject is a
// token validation failure, which security.md answers with a 401. A 403 belongs
// to a valid token that asks beyond its scope, which this set does not cover.
// Two arguments, because the self test inserts the same three asserts. There they
// have to be able to warn instead of fail, so that a scenario built on a wrong
// answer can still end green on the judgement that the right assert reacted. A
// copy with inverted logic would have been simpler and would have stopped
// following this RuleSet the day the requirement changes. See D-31.
RuleSet: assertsTokenRefused(stop, soft)
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 401 (Unauthorized)."
  * direction = #response
  * operator = #equals
  * responseCode = "401"
  * stopTestOnFail = {stop}
  * warningOnly = {soft}
* test[=].action[+].assert
  * description = "Confirm that the WWW-Authenticate header names the error as invalid_token, as security.md prescribes."
  * direction = #response
  * headerField = "WWW-Authenticate"
  * operator = #contains
  * value = "error=\"invalid_token\""
  * stopTestOnFail = false
  * warningOnly = {soft}
* test[=].action[+].assert
  * description = "Confirm that the body is an OperationOutcome reporting an error with code login, as security.md prescribes."
  * direction = #response
  * expression = "OperationOutcome.issue.where(severity = 'error' and code = 'login').exists()"
  * stopTestOnFail = false
  * warningOnly = {soft}

// What the stub actually answered. Hard and automatic, and a different question
// from the one the asserts above ask: this states that the mutation really is a
// deviation, so a stub file that has drifted is caught without anyone reading a
// warning column. Only the self test uses these. See D-31.
RuleSet: assertStubStatus(code)
* test[=].action[+].assert
  * description = "Confirm that the stub answered with {code}, so that the case is built on the deviation it claims."
  * direction = #response
  * operator = #equals
  * responseCode = "{code}"
  * stopTestOnFail = true
  * warningOnly = false

RuleSet: assertStubHasNoChallenge
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-additional-operators
  * extension[=].valueCode = #notExists
  * description = "Confirm that the stub answered without a WWW-Authenticate header, so that the case is built on the deviation it claims."
  * direction = #response
  * headerField = "WWW-Authenticate"
  * stopTestOnFail = true
  * warningOnly = false

RuleSet: assertStubOutcomeCode(code)
* test[=].action[+].assert
  * description = "Confirm that the OperationOutcome from the stub carries code {code}, so that the case is built on the deviation it claims."
  * direction = #response
  * expression = "OperationOutcome.issue.where(code = '{code}').exists()"
  * stopTestOnFail = true
  * warningOnly = false


// No bearer credentials were presented at all. The status and the challenge are
// asserted the same way, but not the error code: RFC 6750 section 3.1 has the
// server omit it when the request carries no credentials, while security.md
// prescribes invalid_token for every refusal. Until that is settled a platform
// that follows the RFC must not fail here. See OP-01.
RuleSet: assertsNoCredentials
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 401 (Unauthorized)."
  * direction = #response
  * operator = #equals
  * responseCode = "401"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-additional-operators
  * extension[=].valueCode = #exists
  * description = "Confirm that the response carries a WWW-Authenticate header, which RFC 6750 section 3 requires on every refusal."
  * direction = #response
  * headerField = "WWW-Authenticate"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Check whether the WWW-Authenticate header names the error as invalid_token. Warning only: RFC 6750 section 3.1 omits the error code when no credentials were presented, and which of the two applies here is open on open-GUPZ issue #70."
  * direction = #response
  * headerField = "WWW-Authenticate"
  * operator = #contains
  * value = "error=\"invalid_token\""
  * stopTestOnFail = false
  * warningOnly = true

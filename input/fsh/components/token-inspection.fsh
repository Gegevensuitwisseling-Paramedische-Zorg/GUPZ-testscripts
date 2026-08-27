// Reading a token that a caller sends, from the receiving side.
//
// This is what makes a client aimed authentication set possible at all, and it
// only became available with the IG update of 18 August 2026. Before that a
// token was an opaque string to the engine.
//
// How far it reaches, and why. The token is a nested JWT: a JWS signed by the
// caller, encrypted into a JWE addressed to the receiving platform. Conformancelab
// holds no private key, so the payload stays closed and every claim with it,
// including `sub`, `patient`, `aud`, `scope` and the fifteen minute rule. What is
// readable is the JWE protected header, because that is base64url and not
// encrypted. It carries `alg`, `enc` and `cty`, which is exactly the three fields
// GUPZ-TOK-002 prescribes.
//
// So this set proves that a caller builds the right kind of envelope. It cannot
// prove what is inside it. That needs a receiver with the decryption key, which
// on this interface is the data platform and never the test tool.


// The whole token, everything after the Bearer prefix.
RuleSet: variableIncomingToken(requestId)
* variable[+].name = "dva-token"
* variable[=].extension[+].url = $CL-ext-variable-regex-mapper
* variable[=].extension[=].valueString = "(?<=Bearer ).*$"
* variable[=].headerField = "Authorization"
* variable[=].sourceId = "{requestId}"
* variable[=].description = "The token the caller sent, without the Bearer prefix."

// The first segment only, which is the JWE protected header. The character class
// stops at the first dot, so the match ends where the segment does.
RuleSet: variableIncomingTokenHeader(requestId)
* variable[+].name = "dva-token-header"
* variable[=].extension[+].url = $CL-ext-variable-regex-mapper
* variable[=].extension[=].valueString = "(?<=Bearer )[A-Za-z0-9_-]+"
* variable[=].headerField = "Authorization"
* variable[=].sourceId = "{requestId}"
* variable[=].description = "The protected header of the JWE, still base64url encoded."


// A compact JWE has five dot separated parts. A bare JWS has three. This is the
// cheapest way to tell the two apart, and it is the one assert that catches a
// caller who signs but does not encrypt.
RuleSet: assertTokenIsNestedJwt
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-input-variable
  * extension[=].valueString = "dva-token"
  * description = "Confirm that the token is a JWE in compact serialization, which has five dot separated parts. A token that was signed but not encrypted has three."
  * direction = #request
  * stopTestOnFail = true
  * warningOnly = false
  * value.extension[+].url = $CL-ext-assert-regex-matches
  * value.extension[=].valueString = "^[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]*\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+$"

// One field of the JWE protected header, read by decoding the first segment.
RuleSet: assertTokenHeaderField(field, value, meaning)
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-input-variable
  * extension[=].valueString = "dva-token-header"
  * extension[+].url = $CL-ext-assert-mapper-function
  * extension[=].valueCode = #base64Decode
  * description = "Confirm that the JWE header declares {field} as {value}, {meaning}."
  * direction = #request
  * stopTestOnFail = false
  * warningOnly = false
  * value.extension[+].url = $CL-ext-assert-regex-matches
  * value.extension[=].valueString = "\"{field}\"\\s*:\\s*\"{value}\""

// The key id is a different case and stays a warning. GUPZ-JWS-001 requires a
// kid on the JWS header, which is inside the encryption and unreadable here. The
// JWE header table in security.md lists only alg, enc and cty, so a kid there is
// not required by anything. It is worth reporting because #27 has the platform
// resolve its encryption key from a JWKS, and a kid is how that lookup finds the
// right one, but until the table says so this cannot fail a caller.
RuleSet: assertTokenHeaderHasKid
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-input-variable
  * extension[=].valueString = "dva-token-header"
  * extension[+].url = $CL-ext-assert-mapper-function
  * extension[=].valueCode = #base64Decode
  * description = "Check whether the JWE header names the key it was encrypted with. Warning only: security.md requires a kid on the JWS header, which cannot be read from outside, and its JWE header table does not list one. Reported because key rotation under open-GUPZ issue #27 needs it."
  * direction = #request
  * stopTestOnFail = false
  * warningOnly = true
  * value.extension[+].url = $CL-ext-assert-regex-matches
  * value.extension[=].valueString = "\"kid\"\\s*:\\s*\"[^\"]+\""


// The BSN travels in the token and nowhere else. These three say the caller did
// not put it in the url, which is what open-GUPZ issue #73 settled and what
// GUPZ-URL-001 records.
RuleSet: assertsNoBsnInUrl
* test[=].action[+].assert
  * description = "Confirm that query parameter 'patient=' was not present, so that no BSN travels in the url."
  * direction = #request
  * operator = #notContains
  * requestURL = "patient="
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that query parameter 'subject=' was not present, so that no BSN travels in the url."
  * direction = #request
  * operator = #notContains
  * requestURL = "subject="
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the Burgerservicenummer naming system does not appear in the url in any form."
  * direction = #request
  * operator = #notContains
  * requestURL = "fhir.nl/fhir/NamingSystem/bsn"
  * stopTestOnFail = false
  * warningOnly = false

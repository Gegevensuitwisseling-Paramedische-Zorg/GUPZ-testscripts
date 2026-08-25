// Building blocks for the client aimed set, where the calling party is the
// system under test and Conformancelab receives the requests.
//
// Conformancelab does not answer these requests itself. It watches: the proxy
// forwards the request to a FHIR server and returns that answer, and the engine
// matches the request against the operation that is active. So there are no
// stubs to write; what matters is that the right fixtures are on the server the
// proxy forwards to, which is what the provisioning set puts there.


// The Authorization header the client is expected to send.
//
// In a client aimed test the operation describes the request that is expected,
// and Conformancelab uses that description twice: to match an incoming request,
// and to build the request itself when a monitor runs the test as Automated.
// Removing the header therefore removes the token from an automated run, and
// without a token the server behind the proxy has nothing to scope its answer
// to. That is why the header stays even though its value is never compared.
RuleSet: requestHeaderToken(token)
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer {token}"


// What can be asserted about a GUPZ token from the receiving side.
//
// The imported scripts compared the Authorization header to a fixed MedMij
// qualification token. That cannot hold here: a GUPZ token is a JWS inside a
// JWE, minted per run and valid for fifteen minutes, so its value differs every
// time. What is stable is that the header is there and that it uses the Bearer
// scheme, and that is what these two asserts say.
//
// `exists` is not in the operator list of base FHIR, so it is carried by the
// Conformancelab extension for additional operators. `contains` is standard.
//
// This is as far as the engine goes today without decoding. Reading the claims
// out of the token is possible in principle, by chaining the regex mapper,
// assert-input-variable and the base64Decode mapper function, but for a JWE
// only the outer header is readable, which holds alg, enc and kid. That is a
// separate set and it is not built yet.
RuleSet: assertsIncomingBearerToken
* test[=].action[+].assert
  * extension[+].url = $CL-ext-assert-additional-operators
  * extension[=].valueCode = #exists
  * description = "Confirm that the request carries an Authorization header. Its value cannot be compared to a fixed string, because a GUPZ token is encrypted and differs on every run."
  * direction = #request
  * headerField = "Authorization"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the Authorization header uses the Bearer scheme, as security.md prescribes."
  * direction = #request
  * headerField = "Authorization"
  * operator = #contains
  * value = "Bearer "
  * stopTestOnFail = false
  * warningOnly = false


// A real client resolves references when it needs to, not when the script says
// so. Without this, an extra request between two operations fails the operation
// that was active, and the failure says nothing about conformance. The mode
// keeps the order of the defined operations but tolerates requests in between.
RuleSet: allowExtraRequests
* test[=].extension[+].url = $CL-ext-test-request-mode
* test[=].extension[=].valueCode = #extra-allowed

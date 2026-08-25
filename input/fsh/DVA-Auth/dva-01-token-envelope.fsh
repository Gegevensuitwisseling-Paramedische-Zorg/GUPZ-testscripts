// The only case in the client aimed authentication set so far. It judges the
// envelope of the token a caller sends, and the url it sends it in.

Instance: dva-01-token-envelope
InstanceOf: TestScript
Usage: #definition
* insert metadata(dva-01-token-envelope)
* name = "Dva_01_token_envelope"
* title = "DVA-01 - The token is a nested JWT with the prescribed JWE header"
* description = "Tests what a receiving platform can establish about the token a caller sends without holding the decryption key: that there is a Bearer token, that it is a JWS encrypted into a JWE rather than a bare JWS, and that the JWE header declares the three fields GUPZ-TOK-002 prescribes. Also confirms that no BSN travels in the url. The claims inside the token cannot be read here; that needs the platform's private key."

* insert clientAimed
* insert variableIncomingToken(dva-01-request)
* insert variableIncomingTokenHeader(dva-01-request)

* test[+].id = "dva-01"
* test[=].name = "DVA-01"
* test[=].description = "Any search on DocumentReference will do. The request is incidental; the token the caller chose to send with it is the subject. Nothing is asserted about the response."
* insert allowExtraRequests
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.description = "Test the calling party to search for DocumentReference resources with a conformant token."
* test[=].action[=].operation.params = "?status=current"
* test[=].action[=].operation.requestId = "dva-01-request"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
// No Authorization header is prescribed here, and this set is the only one where
// that is right. Everywhere else the operation names a fixed qualification token,
// which tells the caller what to send and lets the server behind the test pick a
// patient. Here the caller's own token is the subject, so prescribing one would
// replace the thing being judged. Two consequences. Conformancelab shows the
// request without a header, and the caller sends the token it would send to a
// real platform. And an Automated dry run cannot validate this set, because the
// engine then sends no token at all; only a real caller can.
* insert assertsIncomingBearerToken
* insert assertTokenIsNestedJwt
* insert assertTokenHeaderField(alg, RSA-OAEP, the key encryption algorithm)
* insert assertTokenHeaderField(enc, A256CBC-HS512, the content encryption algorithm)
* insert assertTokenHeaderField(cty, JWT, which is what marks the payload as a nested JWT)
* insert assertTokenHeaderHasKid
* insert assertsNoBsnInUrl

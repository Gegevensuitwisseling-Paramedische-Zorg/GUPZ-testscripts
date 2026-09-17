// Do the token asserts of the Auth DVA set fire?
//
// DVA-01 has been seen green once, against a real token from a caller. Green on
// its own says little: an assert that has never been seen to react may not be
// able to react. This set puts both directions to it, and it does so without a
// caller, because these scenarios can be run as Automated.
//
// Why Automated works here while the two stub sets need a caller. Automation
// builds the request from the operation and sends it itself. It only does that
// for an operation the engine would otherwise wait for, which a stub is not.
// DVA-01 is an ordinary search, so it qualifies; what it lacks is a token,
// because prescribing one there would replace the thing under test. These
// scenarios prescribe one. See D-32.
//
// The tokens are literals in the material, not something to paste at setup, so
// the run is the same for everyone. They are synthetic: five or three base64url
// segments with a real header and filler for the rest. Nothing is signed or
// encrypted and no key exists, which is enough, because these asserts read the
// dot structure and the JWE protected header and nothing else. They are not
// credentials. Pasting a real token over the default at setup is allowed and
// changes nothing about what is judged.
//
// What this set does not cover yet, and D-32 says why: a scenario with no
// Authorization header at all, and the three asserts that keep the BSN out of
// the url.


// The token a scenario presents. A static variable, so the engine reads the
// default and the setup screen offers it prefilled. The name carries the
// scenario id: Conformancelab offers to fill a variable that occurs in more
// than one scenario once for all of them, which would defeat the mutation.
RuleSet: selfTestToken(name, token)
* variable[+].name = "{name}"
* variable[=].defaultValue = "{token}"
* variable[=].description = "The token this self test presents. A synthetic string, not a credential."

// The same operation DVA-01 describes, with the Authorization header added.
// Nothing at setup can replace it: the engine only fills a header an operation
// does not have, and the field that could supply one appears only for a Test
// Set carrying allowCustomAuthorizationHeader, which none of ours does.
// The same operation again, without an Authorization header. Nothing at setup
// puts one back, so what arrives is a request with no token at all.
RuleSet: selfTestOperationNoToken(requestId)
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.params = "?status=current"
* test[=].action[=].operation.requestId = "{requestId}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true

// The same operation with a url that carries what GUPZ-URL-001 forbids: the
// patient as a parameter, and the BSN naming system as the value of an
// identifier parameter. No number, because a nine digit string in the material
// would look like a person's and is not needed: these asserts read names, and
// the last one reads the naming system.
RuleSet: selfTestOperationBsnInUrl(requestId, tokenVariable)
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.params = "?status=current&patient=Patient/self-test&subject:identifier=http://fhir.nl/fhir/NamingSystem/bsn|self-test"
* test[=].action[=].operation.requestId = "{requestId}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer ${{tokenVariable}}"

RuleSet: selfTestTokenOperation(requestId, tokenVariable)
* test[=].action[+].operation.type = $restful-interaction#search
* test[=].action[=].operation.resource = "DocumentReference"
* test[=].action[=].operation.params = "?status=current"
* test[=].action[=].operation.requestId = "{requestId}"
* test[=].action[=].operation.destination = 1
* test[=].action[=].operation.origin = 1
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer ${{tokenVariable}}"


Instance: self-dva-01-envelope-conforms
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-dva-01-envelope-conforms)
* name = "Self_dva_01_envelope_conforms"
* title = "SELF-DVA-01 - The token asserts pass on a conforming envelope"
* description = "Presents a token with the envelope GUPZ-TOK-002 prescribes: five dot separated segments, and a JWE protected header declaring alg RSA-OAEP, enc A256CBC-HS512 and cty JWT, with a kid. Every assert of DVA-01 has to pass."

* insert clientAimed
* insert selfTestToken(self-dva-01-token, eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIiLCJjdHkiOiJKV1QiLCJraWQiOiJndXB6LXNlbGYtdGVzdC1rZXkifQ.c2VsZi10ZXN0LWVuY3J5cHRlZC1rZXk.c2VsZi10ZXN0LWl2.c2VsZi10ZXN0LWNpcGhlcnRleHQ.c2VsZi10ZXN0LXRhZw)
* insert variableIncomingToken(self-dva-01-request)
* insert variableIncomingTokenHeader(self-dva-01-request)

* test[+].id = "self-dva-01"
* test[=].name = "SELF-DVA-01"
* test[=].description = "The envelope conforms, so every assert should be green. A warning on the kid is a defect here, because this token carries one."
* insert allowExtraRequests
* insert selfTestTokenOperation(self-dva-01-request, self-dva-01-token)
* test[=].action[=].operation.description = "Send the search DVA-01 expects, carrying a token with a conforming JWE header."
* insert assertsIncomingBearerToken(false)
* insert assertTokenIsNestedJwt(true, false)
* insert assertTokenHeaderField(alg, RSA-OAEP, the key encryption algorithm, false)
* insert assertTokenHeaderField(enc, A256CBC-HS512, the content encryption algorithm, false)
* insert assertTokenHeaderField(cty, JWT, which is what marks the payload as a nested JWT, false)
* insert assertTokenHeaderHasKid
* insert assertsNoBsnInUrl(false)


Instance: self-dva-02-bare-jws
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-dva-02-bare-jws)
* name = "Self_dva_02_bare_jws"
* title = "SELF-DVA-02 - The envelope asserts catch a token that is only signed"
* description = "Presents a bare JWS: three segments, and a header declaring alg RS256. This is the mistake DVA-01 catches: a caller that signs but does not encrypt. The assert on the number of segments and the three on the JWE header must all react."

* insert clientAimed
* insert selfTestToken(self-dva-02-token, eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imd1cHotc2VsZi10ZXN0LWtleSJ9.eyJpc3MiOiJzZWxmLXRlc3QiLCJub3RlIjoibm90IGEgY3JlZGVudGlhbCJ9.c2VsZi10ZXN0LXNpZ25hdHVyZQ)
* insert variableIncomingToken(self-dva-02-request)
* insert variableIncomingTokenHeader(self-dva-02-request)

* test[+].id = "self-dva-02"
* test[=].name = "SELF-DVA-02"
* test[=].description = "Four asserts have to warn here and two have to stay green: the header is there and it uses the Bearer scheme, so those two say nothing about the envelope."
* insert allowExtraRequests
* insert selfTestTokenOperation(self-dva-02-request, self-dva-02-token)
* test[=].action[=].operation.description = "Send the same search, carrying a token that was signed but not encrypted."
* insert assertsIncomingBearerToken(false)
* insert assertTokenIsNestedJwt(false, true)
* insert assertTokenHeaderField(alg, RSA-OAEP, the key encryption algorithm, true)
* insert assertTokenHeaderField(enc, A256CBC-HS512, the content encryption algorithm, true)
* insert assertTokenHeaderField(cty, JWT, which is what marks the payload as a nested JWT, true)
* insert assertsNoBsnInUrl(false)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the assert on the five segments warned and that the three on the JWE header warned with it. The token was a bare JWS, so all four had to react. One that stayed green is not testing what it claims. The kid assert is left out of this scenario on purpose: it is a warning in the shipped set as well, so its warning would say nothing."


Instance: self-dva-03-no-token
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-dva-03-no-token)
* name = "Self_dva_03_no_token"
* title = "SELF-DVA-03 - The presence asserts catch a request without a token"
* description = "Sends the same search with no Authorization header at all. The two asserts that state a Bearer token was presented must both react. This scenario is possible because the field for a custom authorization header appears only for a Test Set that asks for it, and no set here does, so nothing at setup supplies the header the operation leaves out."

* insert clientAimed

* test[+].id = "self-dva-03"
* test[=].name = "SELF-DVA-03"
* test[=].description = "Both presence asserts have to warn here. Neither the envelope asserts nor the url asserts belong in this scenario: without a token there is nothing to read, and the url is the same as everywhere else."
* insert allowExtraRequests
* insert selfTestOperationNoToken(self-dva-03-request)
* test[=].action[=].operation.description = "Send the search DVA-01 expects, carrying no Authorization header."
* insert assertsIncomingBearerToken(true)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that both asserts on the Authorization header warned. The request carried none, so both had to react. If either stayed green, it is not testing what it claims, and the likely cause is that something supplied a header the scenario left out."


Instance: self-dva-04-bsn-in-url
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-dva-04-bsn-in-url)
* name = "Self_dva_04_bsn_in_url"
* title = "SELF-DVA-04 - The url asserts catch a patient in the query"
* description = "Sends the same search with a conforming token but a url that carries what GUPZ-URL-001 forbids: a patient parameter, and the Burgerservicenummer naming system as the value of subject:identifier. Three of the five url asserts must react, and which three is the point: patient and subject:identifier by name, and the naming system as a value."

* insert clientAimed
* insert selfTestToken(self-dva-04-token, eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZDQkMtSFM1MTIiLCJjdHkiOiJKV1QiLCJraWQiOiJndXB6LXNlbGYtdGVzdC1rZXkifQ.c2VsZi10ZXN0LWVuY3J5cHRlZC1rZXk.c2VsZi10ZXN0LWl2.c2VsZi10ZXN0LWNpcGhlcnRleHQ.c2VsZi10ZXN0LXRhZw)

* test[+].id = "self-dva-04"
* test[=].name = "SELF-DVA-04"
* test[=].description = "Three asserts have to warn: the one on patient, the one on subject:identifier, and the one on the naming system. The two on subject and patient:identifier have to stay green, because those parameters are not in this url."
* insert allowExtraRequests
* insert selfTestOperationBsnInUrl(self-dva-04-request, self-dva-04-token)
* test[=].action[=].operation.description = "Send the search with the patient in the query, which the specification forbids."
* insert assertsNoBsnInUrl(true)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that exactly three asserts warned: patient, subject:identifier and the naming system. A silent one on patient or subject:identifier means the parameter is not being read by name. A silent one on the naming system means the url reaches the assert percent-encoded, which would make that assert useless against a real caller and is worth reporting."

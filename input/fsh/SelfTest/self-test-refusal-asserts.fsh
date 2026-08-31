// Does the refusal assert set of D-30 actually fire?
//
// The three asserts were written against security.md and have never run: no
// platform exists that answers a GUPZ token, and HAPI accepts everything. This
// set answers them from stubs instead, and inserts the shipped RuleSet rather
// than a copy, so what is checked is what suppliers get.
//
// A stub operation sends nothing. The engine waits for a request, then validates
// the asserts against that request and the stubbed response. So a caller is
// needed: Sjimmie, curl, anything that hits the stub endpoint the setup screen
// shows.
//
// One scenario must pass and three must fail. A mutation that stays green means
// the assert it targets is not testing what it claims. See D-31.

Instance: self-01-refusal-conforms
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-01-refusal-conforms)
* name = "Self_01_refusal_conforms"
* title = "SELF-01 - The refusal asserts pass on a conforming answer (must pass)"
* description = "Serves the refusal security.md prescribes: 401, WWW-Authenticate with error=invalid_token, and an OperationOutcome with severity error and code login. All three asserts of D-30 must pass."

* insert clientAimedStub
* insert stubFixture(refused-invalid-token, refused-invalid-token.stub)

* test[+].id = "self-01"
* test[=].name = "SELF-01"
* test[=].description = "The answer conforms, so every assert should be green."
* insert allowExtraRequests
* insert operationServeStub(refused-invalid-token)
* test[=].action[=].operation.description = "Answer with the refusal security.md prescribes."
* insert assertsTokenRefused

Instance: self-02-wrong-status
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-02-wrong-status)
* name = "Self_02_wrong_status"
* title = "SELF-02 - The status assert catches a 403 (must fail)"
* description = "Serves the 403 that belongs to a request outside scope. The first assert of D-30 expects 401 and must fail, which stops the test."

* insert clientAimedStub
* insert stubFixture(selftest-wrong-status, selftest-wrong-status.stub)

* test[+].id = "self-02"
* test[=].name = "SELF-02"
* test[=].description = "Expected outcome: the assert on the status code fails."
* insert allowExtraRequests
* insert operationServeStub(selftest-wrong-status)
* test[=].action[=].operation.description = "Answer with a 403 where the case expects a 401."
* insert assertsTokenRefused

Instance: self-03-no-challenge
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-03-no-challenge)
* name = "Self_03_no_challenge"
* title = "SELF-03 - The challenge assert catches a missing header (must fail)"
* description = "Serves a 401 without a WWW-Authenticate header. The second assert of D-30 must fail; the first and third should still pass."

* insert clientAimedStub
* insert stubFixture(selftest-no-challenge, selftest-no-challenge.stub)

* test[+].id = "self-03"
* test[=].name = "SELF-03"
* test[=].description = "Expected outcome: the assert on the WWW-Authenticate header fails."
* insert allowExtraRequests
* insert operationServeStub(selftest-no-challenge)
* test[=].action[=].operation.description = "Answer with a 401 that carries no challenge."
* insert assertsTokenRefused

Instance: self-04-wrong-outcome-code
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-04-wrong-outcome-code)
* name = "Self_04_wrong_outcome_code"
* title = "SELF-04 - The OperationOutcome assert catches the wrong code (must fail)"
* description = "Serves a conforming 401 whose OperationOutcome carries code forbidden instead of login. Only the third assert of D-30 must fail."

* insert clientAimedStub
* insert stubFixture(selftest-wrong-outcome-code, selftest-wrong-outcome-code.stub)

* test[+].id = "self-04"
* test[=].name = "SELF-04"
* test[=].description = "Expected outcome: the assert on the OperationOutcome code fails."
* insert allowExtraRequests
* insert operationServeStub(selftest-wrong-outcome-code)
* test[=].action[=].operation.description = "Answer with a 401 whose OperationOutcome code is forbidden."
* insert assertsTokenRefused

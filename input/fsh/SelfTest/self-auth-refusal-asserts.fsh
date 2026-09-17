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
// All four end green when the material is right. The conforming answer passes on
// the asserts themselves. The three wrong answers do three things: they state
// automatically that the stub really answered the deviation, they insert the
// asserts of D-30 as warnings so the scenario does not fail, and they ask whoever
// is watching whether the expected warning appeared. The first two are checked by
// the engine; only the last needs a person, because no assert can read another
// assert's outcome. See D-31.

Instance: self-auth-01-refusal-conforms
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-auth-01-refusal-conforms)
* name = "Self_auth_01_refusal_conforms"
* title = "SELF-AUTH-01 - The refusal asserts pass on a conforming answer"
* description = "Serves the refusal security.md prescribes: 401, WWW-Authenticate with error=invalid_token, and an OperationOutcome with severity error and code login. All three asserts of D-30 must pass."

* insert clientAimedStub
* insert stubFixture(refused-invalid-token, refused-invalid-token.stub)

* test[+].id = "self-auth-01"
* test[=].name = "SELF-AUTH-01"
* test[=].description = "The answer conforms, so every assert should be green."
* insert allowExtraRequests
* insert operationServeStub(refused-invalid-token)
* test[=].action[=].operation.description = "Answer with the refusal security.md prescribes."
* insert assertsTokenRefused(true, false)

Instance: self-auth-02-wrong-status
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-auth-02-wrong-status)
* name = "Self_auth_02_wrong_status"
* title = "SELF-AUTH-02 - The status assert catches a 403"
* description = "Serves the 403 that belongs to a request outside scope. The assert on the status expects a 401 and must react."

* insert clientAimedStub
* insert stubFixture(selftest-wrong-status, selftest-wrong-status.stub)

* test[+].id = "self-auth-02"
* test[=].name = "SELF-AUTH-02"
* test[=].description = "The assert on the status code has to warn here."
* insert allowExtraRequests
* insert operationServeStub(selftest-wrong-status)
* test[=].action[=].operation.description = "Answer with a 403 where the case expects a 401."
* insert assertStubStatus(403)
* insert assertsTokenRefused(false, true)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the assert on the status code warned. The answer was a 403 where D-30 requires a 401, so it had to react. If it stayed green, that assert is not testing what it claims."

Instance: self-auth-03-no-challenge
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-auth-03-no-challenge)
* name = "Self_auth_03_no_challenge"
* title = "SELF-AUTH-03 - The challenge assert catches a missing header"
* description = "Serves a 401 without a WWW-Authenticate header. The assert on the challenge must react; the other two should not."

* insert clientAimedStub
* insert stubFixture(selftest-no-challenge, selftest-no-challenge.stub)

* test[+].id = "self-auth-03"
* test[=].name = "SELF-AUTH-03"
* test[=].description = "The assert on the WWW-Authenticate header has to warn here."
* insert allowExtraRequests
* insert operationServeStub(selftest-no-challenge)
* test[=].action[=].operation.description = "Answer with a 401 that carries no challenge."
// No automatic check that the challenge is absent. An assert on a header falls
// back to a plain existence check unless it carries a value, so the absence of a
// header cannot be stated. The other two mutations do have one.
* insert assertsTokenRefused(false, true)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the assert on the WWW-Authenticate header warned and that the other two did not. The answer carried no challenge at all."

Instance: self-auth-04-wrong-outcome-code
InstanceOf: TestScript
Usage: #definition
* insert metadata(self-auth-04-wrong-outcome-code)
* name = "Self_auth_04_wrong_outcome_code"
* title = "SELF-AUTH-04 - The OperationOutcome assert catches the wrong code"
* description = "Serves a conforming 401 whose OperationOutcome carries code forbidden instead of login. Only the assert on the OperationOutcome must react."

* insert clientAimedStub
* insert stubFixture(selftest-wrong-outcome-code, selftest-wrong-outcome-code.stub)

* test[+].id = "self-auth-04"
* test[=].name = "SELF-AUTH-04"
* test[=].description = "The assert on the OperationOutcome has to warn here."
* insert allowExtraRequests
* insert operationServeStub(selftest-wrong-outcome-code)
* test[=].action[=].operation.description = "Answer with a 401 whose OperationOutcome code is forbidden."
* insert assertStubOutcomeCode(forbidden)
* insert assertsTokenRefused(false, true)
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the assert on the OperationOutcome warned and that the other two did not. The status and the challenge were correct; only the code was forbidden instead of login."

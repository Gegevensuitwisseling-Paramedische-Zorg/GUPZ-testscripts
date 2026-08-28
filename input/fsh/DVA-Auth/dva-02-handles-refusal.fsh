// What a caller does when the platform refuses. Two scenarios, one per refusal
// that security.md defines. See decisions D-21 and D-22 in docs/decisions.md
// for why the response is stubbed and why the judgement is manual.

Instance: dva-02-handles-refusal
InstanceOf: TestScript
Usage: #definition
* insert metadata(dva-02-handles-refusal)
* name = "Dva_02_handles_refusal"
* title = "DVA-02 - The caller handles a refused request"
* description = "Shows the caller the two refusals security.md defines, a 401 for an invalid token and a 403 for a request outside the granted scope, and asks whether it dealt with them properly. The responses come from WireMock stubs, so they are exactly what the specification prescribes rather than whatever a server happens to return. What the caller must do next is not specified anywhere, so the judgement is manual."

* insert clientAimedStub
* insert stubFixture(refused-invalid-token, refused-invalid-token.stub)
* insert stubFixture(refused-insufficient-scope, refused-insufficient-scope.stub)

* test[+].id = "dva-02a"
* test[=].name = "DVA-02a - refused with 401"
* test[=].description = "The platform refuses the token. The caller receives a 401 with a WWW-Authenticate header carrying error=invalid_token, and an OperationOutcome with code login."
* insert allowExtraRequests
* insert operationServeStub(refused-invalid-token)
* test[=].action[=].operation.description = "Refuse the request with the 401 that security.md prescribes for an invalid token."
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the caller reported the failure and stopped. It must not repeat the same request with the same token, and it must not fall back to a request without one."

* test[+].id = "dva-02b"
* test[=].name = "DVA-02b - refused with 403"
* test[=].description = "The request falls outside the scope in the token. The caller receives a 403 with error=insufficient_scope, a scope parameter naming what is needed, and an OperationOutcome with code forbidden."
* insert allowExtraRequests
* insert operationServeStub(refused-insufficient-scope)
* test[=].action[=].operation.description = "Refuse the request with the 403 that security.md prescribes for a request outside scope."
* insert assertManualJudgement
* test[=].action[=].assert.description = "Confirm that the caller reported the failure and made use of the scope parameter, which names the scope it would have to request. Repeating the same request unchanged is wrong."

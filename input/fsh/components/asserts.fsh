// Asserts on the response from the server under test.
//
// stopTestOnFail and warningOnly are always set explicitly. In R5
// stopTestOnFail is 1..1, so leaving it out produces a build error.

RuleSet: assertResponseCode(code, meaning)
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is {code} ({meaning})."
  * direction = #response
  * operator = #equals
  * responseCode = "{code}"
  * stopTestOnFail = true
  * warningOnly = false

RuleSet: assertResponseResourceType(resource)
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is {resource}."
  * direction = #response
  * resource = "{resource}"
  * stopTestOnFail = false
  * warningOnly = false

RuleSet: assertResponseConformsToProfile(resource, profileId)
* test[=].action[+].assert
  * description = "Confirm that the returned {resource} conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "{profileId}"
  * warningOnly = false


// The graceful refusal on DocumentManifest, identical in scenarios 2.2, 2.3 and
// 2.4 and verified so before it was extracted here. [`pdfa.md`] prescribes the
// 404 and the OperationOutcome; see decision D-04.
//
// The self test inserts the same RuleSet against a stub, because these asserts
// have only ever been seen to fail: the server behind the tests supports
// DocumentManifest and answers 200. An assert that has never been satisfied may
// be impossible to satisfy.
//
// The argument softens the profile assert, and only the self test uses that.
// Profile validation reads the payload from the proxy transaction log, addressed
// by the exchange id of the request. A stub is answered by the engine, so there
// is no exchange and the validator is handed nothing. It fails with "could not
// initiate validation", which says something about where the payload comes from
// and nothing about the OperationOutcome. Warning there, hard everywhere else.
RuleSet: assertsManifestNotSupported(softProfile)
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 404 (Not Found)."
  * direction = #response
  * operator = #equals
  * responseCode = "404"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned resource type is OperationOutcome."
  * direction = #response
  * resource = "OperationOutcome"
  * stopTestOnFail = true
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned OperationOutcome conforms to the base FHIR specification."
  * direction = #response
  * stopTestOnFail = false
  * validateProfileId = "OperationOutcome-profile"
  * warningOnly = {softProfile}
* test[=].action[+].assert
  * description = "Confirm that the OperationOutcome has .code set to not-supported."
  * direction = #response
  * expression = "OperationOutcome.issue.code = 'not-supported'"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the OperationOutcome has .severity set to fatal or error."
  * direction = #response
  * expression = "OperationOutcome.issue.severity = 'fatal' or OperationOutcome.issue.severity = 'error'"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Although not required, a human-readable description of the problem is strongly encouraged."
  * direction = #response
  * expression = "OperationOutcome.issue.diagnostics.exists() or OperationOutcome.issue.details.text.exists()"
  * stopTestOnFail = false
  * warningOnly = true

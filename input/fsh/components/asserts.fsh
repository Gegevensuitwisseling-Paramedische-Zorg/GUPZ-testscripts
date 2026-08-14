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

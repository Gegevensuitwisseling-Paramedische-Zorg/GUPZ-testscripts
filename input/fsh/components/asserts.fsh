// Asserts op de response van de server onder test.
//
// stopTestOnFail en warningOnly staan overal expliciet. In R5 is
// stopTestOnFail 1..1, dus weglaten levert een bouwfout op.

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

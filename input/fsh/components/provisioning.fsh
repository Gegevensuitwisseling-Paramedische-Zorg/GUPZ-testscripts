// Building blocks for the provisioning script, which writes the fixtures to a
// target server. That set is not a conformance test: open-GUPZ describes the
// data platform as a read only Document Responder, so this runs against a
// reference server that accepts writes, not against a supplier's platform.
//
// Two things here differ from every other set, both on purpose.
//
// The access token is fixed in the script rather than operator input. It
// resolves through Configuration/QualificationTokens.json, which the engine
// reads when the repository is loaded and which maps a token to a patient. Take
// the token out and that link breaks. A fixed opaque token is right here: it
// labels which patient a row belongs to, it is not a credential under test.
//
// There is no origin, no destination and no system under test. Nothing is being
// judged, so there is nothing to mark.


// One fixture plus the variable that reads its id back, which the PUT uses to
// address the resource.
RuleSet: loadFixture(kind, id, file)
* fixture[+].id = "{kind}-{id}"
* fixture[=].autocreate = false
* fixture[=].autodelete = false
* fixture[=].resource.reference = "../_reference/resources/{file}"
* variable[+].name = "{kind}-{id}-id"
* variable[=].expression = "{kind}.id"
* variable[=].sourceId = "{kind}-{id}"

// Clear out a patient and everything hanging off it, with the Conformancelab
// operation code purge.
RuleSet: purgePatient(id, token)
* setup.action[+].operation.type = $CL-operation-type#purge
* setup.action[=].operation.resource = "Patient"
* setup.action[=].operation.accept = #xml
* setup.action[=].operation.contentType = #xml
* setup.action[=].operation.encodeRequestUrl = true
* setup.action[=].operation.params = "{id}/$purge"
* setup.action[=].operation.requestHeader[+].field = "Authorization"
* setup.action[=].operation.requestHeader[=].value = "Bearer {token}"
* setup.action[+].assert
  * description = "Confirm that the returned HTTP status is 200(OK) or 204(No Content)"
  * operator = #in
  * responseCode = "200,204"
  * stopTestOnFail = false
  * warningOnly = false

// Write one fixture with a client assigned id, and check that it landed.
RuleSet: putFixture(kind, id, token)
* test[=].action[+].operation.type = $restful-interaction#update
* test[=].action[=].operation.resource = "{kind}"
* test[=].action[=].operation.description = "PUT {kind}/{id}"
* test[=].action[=].operation.accept = #xml
* test[=].action[=].operation.contentType = #xml
* test[=].action[=].operation.encodeRequestUrl = true
* test[=].action[=].operation.params = "/${{kind}-{id}-id}"
* test[=].action[=].operation.requestHeader[+].field = "Authorization"
* test[=].action[=].operation.requestHeader[=].value = "Bearer {token}"
* test[=].action[=].operation.sourceId = "{kind}-{id}"
* test[=].action[+].assert
  * description = "Confirm that the returned HTTP status is 200(OK) or 201(Created)."
  * operator = #in
  * responseCode = "200,201"
  * stopTestOnFail = false
  * warningOnly = false

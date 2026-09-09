Instance: auth-11-patient-scoping
InstanceOf: TestScript
Usage: #definition
* insert metadata(auth-11-patient-scoping)
* name = "Auth_11_patient_scoping"
* title = "AUTH-11 - The response is scoped to the patient in the token"
* description = "Tests whether the platform limits what it returns to the patient in the token. The same search is sent twice, once with a token for each test patient, and each response is checked for a document that only the other patient has. Since open-GUPZ issue #73 closed on 18 August a token used in a patient bound request is patient specific and a BSN never appears in a url or query parameter, so the token is the only thing that selects the patient. All asserts are hard."

* insert serverAimed
* insert variableToken(auth-11-token-patient-1)
* variable[=].description = "T1: valid token for the first test patient, XXX_Baltus."
* insert variableToken(auth-11-token-patient-2)
* variable[=].description = "T9: valid token for the second test patient, XXX_Schulte."

* test[+].id = "11a"
* test[=].name = "AUTH-11a"
* test[=].description = "A search with the token of the first patient returns that patient's documents"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-11-token-patient-1)
* insert assertsRequestAccepted
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a DocumentReference with LOINC code 68688-1, which belongs to the first test patient."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68688-1')).exists()"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains no DocumentReference with LOINC code 68626-1, which belongs to the second test patient. The specification requires a patient specific token, so a response holding the other patient's documents is not conformant."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68626-1')).exists().not()"
  * stopTestOnFail = false
  * warningOnly = false

* test[+].id = "11b"
* test[=].name = "AUTH-11b"
* test[=].description = "The same search with the token of the second patient returns that patient's documents"
* insert operationSearchDocumentReference
* insert headersWithBearerToken(auth-11-token-patient-2)
* insert assertsRequestAccepted
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains a DocumentReference with LOINC code 68626-1, which belongs to the second test patient."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68626-1')).exists()"
  * stopTestOnFail = false
  * warningOnly = false
* test[=].action[+].assert
  * description = "Confirm that the returned Bundle contains no DocumentReference with LOINC code 68688-1, which belongs to the first test patient. Not conformant for the same reason as in AUTH-11a."
  * direction = #response
  * expression = "Bundle.entry.select(resource as DocumentReference).where(type.coding.where(code = '68688-1')).exists().not()"
  * stopTestOnFail = false
  * warningOnly = false

# Postman collection

The same requests as the server aimed Test Sets, for checking a response by
hand. It runs nothing; Conformancelab drives the tests.

Three uses:

- Telling whether a failing assert is caused by the script or by the server
  under test.
- Checking, before a full run, whether a supplier endpoint answers at all with
  the certificate and the token in place.
- Acting as the client for a client aimed Test Set, pointed at the base URL
  Conformancelab shows for the run.

## Setting up

Import `GUPZ-dataplatform.postman_collection.json` and set the collection
variables:

| Variable | Meaning |
|---|---|
| `baseUrl` | FHIR base of the server under test. `https://hapi.fhir.org/baseDstu3` answers our searches and is a reasonable dry run target |
| `token` | Token for the first test patient, generated with `JwtCliTool` |
| `tokenPatient2` | Token for the second test patient, needed for AUTH-11 |
| `binaryId` | The Binary that scenario 1.5 reads and expects not to find |

`MedMij-Request-ID` and `X-Correlation-ID` are filled with a fresh guid per
request. The TestScripts no longer send them (decision D-08); the collection
still does, so that a supplier expecting them is not the variable under
investigation.

Against `hapi.fhir.org` the searches answer and return a Bundle, so the shape of
the request is right. The fixtures are not loaded there, so the content is
somebody else's.

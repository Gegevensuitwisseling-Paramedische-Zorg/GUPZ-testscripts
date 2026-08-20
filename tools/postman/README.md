# Hand checks with Postman

Conformancelab drives the tests: for a server aimed Test Set it is the client
and it makes the requests itself. This collection does not run anything. It
holds the same requests so that a response can be inspected by hand, which is
how you tell whether a failing assert is caused by the script or by the server
under test.

Two other uses. Before running the full set against a supplier, one request is a
quick way to find out whether the endpoint answers at all with the certificate
and the token in place. And for the client aimed Test Set, where Conformancelab
plays the server and waits to be called, a client has to make the requests;
Postman can be that client, pointed at the base url Conformancelab shows for the
run.

## Setting up

Import `GUPZ-dataplatform.postman_collection.json` and set the collection
variables:

| Variable | Meaning |
|---|---|
| `baseUrl` | The FHIR base of the server under test. `https://hapi.fhir.org/baseDstu3` answers our searches and is a reasonable dry run target |
| `token` | The token for the first test patient, generated with `JwtCliTool` |
| `tokenPatient2` | The token for the second test patient, needed for AUTH-11 |
| `binaryId` | The Binary that scenario 1.5 reads and expects not to find |

`MedMij-Request-ID` and `X-Correlation-ID` are filled with a fresh guid per
request, matching what the scripts send.

## What to expect against hapi.fhir.org

The searches answer and return a Bundle, so the shape of the request is right.
The fixtures are not loaded there, so the content is somebody else's. That is the
point of a dry run: it separates "the request is well formed" from "the platform
holds the right data".

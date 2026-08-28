# Conformancelab

Engine behaviour this repository depends on. Not a manual: only what a script
here relies on, and what is easy to get wrong.

## Which source to follow

1. The [Interoplab implementation guide][ig] carries the profile, the extensions
   and the value sets. That is the contract; build on it by default.
2. The [Conformancelab manual][manual] explains what the platform does with a
   script at run time, which the guide does not cover.
3. A run is the most direct source, and the last resort. The imported
   provisioning script uses the operation code `purge`, which is not in the
   published value set and works.

What is only in the code is not an agreement. Where a test has to depend on such
behaviour, say so in the script and raise it with Interoplab so it lands in the
guide.

## Test Sets

Conformancelab scans the repository for directories containing a
`properties.json`. Such a directory is a Test Set: a group of TestScripts for
one role within an information standard. The name of the directory above it is
free; `properties.json` decides what appears in the user interface.

Because the scan covers the whole repository, only `output/` may hold a file by
that name. The copies under `input/` are called `src-properties.json` and the
build renames them.

TestScripts refer to `../_reference/...`, so a Test Set directory has to stay
exactly one level below `_reference`.

Only the default branch is visible to regular users; other branches are
available to administrators. The default branch is set in the repository
configuration and does not have to be `main`. Adding this repository to a
Conformancelab instance is arranged through Interoplab.

`serverAlias` in `properties.json` names the FHIR server behind the proxy. For
GUPZ that is `gupz`, which is also the Development server of the repository
configuration, so it serves every branch: provisioning from any branch moves the
data for everyone.

## Server aimed runs

Conformancelab is the client. It sends the requests, the platform under test
answers, and the asserts run over the response.

Conformancelab presents a client certificate configured per instance, not per
TestScript. One useful consequence: every case that succeeds proves an mTLS
connection was established, because without an accepted client certificate there
would be no response at all. `GUPZ-TR-001` is covered implicitly by AUTH-01. The
other half, that a caller without a valid certificate is refused, cannot be
produced from a TestScript.

## Client aimed runs

The engine does not answer the requests. The system under test calls the address
it is given, the proxy forwards the request to a FHIR server and returns that
answer; the engine watches, matches the request against the operation that is
active and evaluates the asserts.

- **No stubs for ordinary FHIR traffic.** What decides the answer is the content
  of the server the proxy forwards to, which `_LoadResources` fills. The `stub`
  operation type is for non-FHIR endpoints and for a redirect after a
  `browser-interaction`.
- **Which server answers is declared.** A destination with the Conformancelab
  profile and no `url` of its own resolves to `serverAlias`, and falls back to
  the environment default when there is none. A `url` per destination is
  allowed, literal or through `${SERVER-ALIAS, <alias>}`, which is how a client
  set can read from a different server than the one provisioning fills. Not
  needed here.
- **The server scopes its answer to the token.** Established in an automated run
  on 25 August 2026: with the `Authorization` header present, a search on
  `?status=current` returns only the documents of the patient the token belongs
  to, and `Configuration/QualificationTokens.json` makes that mapping. Take the
  header out of the operation and the scoping goes with it, because
  Conformancelab builds an automated request from the operation description. The
  header therefore stays on every client operation even though its value is
  never compared (D-15).
- **Extra requests have to be allowed.** `Interoplab-CL-ext-test-request-mode`
  on `TestScript.test` takes `default`, `extra-allowed` or `random-order`. Under
  the default, anything between two operations fails the one that was active,
  which says nothing about conformance (D-16).
- **A set can be tried without a client.** A monitor or admin can mark client
  tests as Automated, after which Conformancelab sends the requests the system
  under test would have sent. Does not work for Auth DVA, see D-20.

### A stub answers on a different address

Established on 27 August 2026, after an operation sat on "Waiting for request"
with nothing wrong in the script.

| Traffic | Address | Route |
|---|---|---|
| FHIR request | `/q/<organization id>/<usecase>/<version>/fhir` | Proxy to a FHIR server; the engine watches |
| Stub | `/cl/<organization id>/` | Proxy straight through, stripping the id into a header; the engine answers from a WireMock mapping |

Only requests arriving at the second address reach the filter that answers from
a mapping. Both are on the same host and share the organization id, so one base
URL yields the other; `tools/dva-sim` derives it and shows it before sending.

Guidance being prepared for the IG will let a destination declare its own URL,
with `${STUB-ENDPOINT}` resolving to this address. Not live: the engine
deliberately does not store `destination.url` while its placeholders cannot be
resolved. A single destination is right for now.

## Tokens

Conformancelab cannot produce a nested JWT, so every set that reads from the
data platform takes its token as operator input: a variable with no default,
sent as `Authorization: Bearer ${auth-01-token}`, filled in when the run is set
up. The token is made outside the engine with `jwtcli` from open-GUPZ (D-11).
Variable naming follows D-19.

`${JWT-ENCODE}` can sign a JWS from a claims object, and
`${CURRENT-NUMERICDATE}` can set a stale `iat`, which together would cover the
happy flow and the two time based cases. They would not cover AUTH-09 and
AUTH-10, which need control over keys, nor anything encrypted. `${JWT-ENCODE}`
also signs with a key of the engine's own, published at `/cl/oauth2/jwks`, so a
minted token would carry an Interoplab signature rather than the signature of
the party the test represents.

Switching later costs one line per script, because the token is a variable.
Operator input stays the baseline because it covers all eleven cases.

Pasting is not the burden. The burden on a supplier is that their platform has
to trust whoever issued the token, and that is configuration they cannot avoid,
because validating the token is what is being tested.

## Reading a token

Three extensions in a chain, available since the IG update of 18 August 2026.
Before that a token was an opaque string to the engine.

1. A variable with `headerField` `Authorization` and a `sourceId` pointing at
   the operation's `requestId`, carrying
   `Interoplab-CL-ext-variable-regex-mapper` with the pattern `(?<=Bearer
   )[A-Za-z0-9_-]+`. The lookbehind skips the scheme; the character class stops
   at the first dot, so the match is exactly the first segment of the compact
   serialization, which is the protected header.
2. An assert carrying `Interoplab-CL-ext-assert-input-variable` with that
   variable's name and `Interoplab-CL-ext-assert-mapper-function`
   `base64Decode`.
3. `Interoplab-CL-ext-assert-regex-matches` on the assert's `value`, so the
   check is a pattern and not an exact string. `"alg"\s*:\s*"RSA-OAEP"`
   tolerates the whitespace a serialiser may or may not add.

Two limits. The regex mapper keeps only the first full match and does not
support capture groups, so a segment has to be isolated with lookaround. And for
a JWE only the protected header is readable; the claims need the private key.

A second variable holds the whole token, `(?<=Bearer ).*$`, to count the
segments.

Mapper functions: `length`, `urlDecode`, `urlEncode`, `base64Decode`,
`base64Encode`. The last two are in the IG and the code but not in the manual.

## Asserts

- `headerField`, `queryParam` and `path` accept `exists` and `notExists`,
  carried by `Interoplab-CL-ext-assert-additional-operators`; `expression` does
  not. `contains` is standard.
- `manualEval` pauses a run until somebody judges the outcome by hand. The
  operator is the whole mechanism; `defaultManualCompletion` looks like it
  should do the job and does not (D-22).
- Groovy rules remain the fallback for what an assert cannot express, with
  access to request, response and FHIRPath. Declared with
  `Interoplab-CL-ext-rule` and `Interoplab-CL-ext-assert-rule` (D-06).

## Reading the engine source

Naming is inverted against the user interface: `service/testrun/client` is
Conformancelab as an HTTP client, so the server aimed tests, and
`service/testrun/server` is the client aimed tests.

[ig]: https://fhir.interoplab.eu/ig/
[manual]: https://interoplab.atlassian.net/wiki/spaces/SUP/pages/4085317648

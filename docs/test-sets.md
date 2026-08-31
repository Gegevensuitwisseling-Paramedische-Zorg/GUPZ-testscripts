# Test sets

What each set tests, which scenarios are in it and why. The grounds are in
[decisions.md](decisions.md), the requirements in
[requirements.md](requirements.md), the engine mechanics in
[authoring.md](authoring.md).

| Test Set | Aim | System under test | Scripts | State |
|---|---|---|---|---|
| PDF/A Dataplatform | Document interface | Data platform | 20 | Built |
| PDF/A DVA | Document interface | Calling party | 5 | Built, four of five green |
| PDF/A _LoadResources | Provisioning | none | 1 | Built |
| Auth Dataplatform | Token and authentication | Data platform | 11 | Built, waiting on keys ([OP-05](open-points.md#op-05-key-material)) |
| Auth DVA | Token and authentication | Calling party | 2 | Built |
| Auth Self test | The asserts of this repository | none | 4 | Built, `adminOnly` |

Written against open-GUPZ commit `0a273ae`, 21 August 2026. A commit rather than
a release number, because the changelog there does not reliably track what
changed.

## Authentication situations

Every party that calls the data platform is a client. Which authentication
applies, and what a test looks like, depends on which side is under test.

| Actor | Role |
|---|---|
| PARIS | Source system, behind the data platform, out of scope |
| Data platform | Offers the FHIR APIs. The interface GUPZ specifies |
| DVA | Dienstverlener Aanbieder, the MedMij role that serves a PGO |
| Verwijsplatform, ZorgDomein | Referral |
| Vecozo dienst Verwijzen | Referral, with its own profile |
| NIS | Netwerk Informatie Systeem |
| PGO | Personal health environment. Talks to a DVA, never to the data platform |

| # | Situation | Under test | Conformancelab | Source | State |
|---|---|---|---|---|---|
| 1 | A DVA queries the data platform | Data platform | Caller. Sends the request with a supplied token, asserts on the response | [medmij.md][mm-rol], [pdfa.md][pdfa-sec], [security.md][sec-tok] | Built, 11 cases |
| 2 | The same interface, DVA under test | DVA | Receiver. Observes the request; stubs for the refusal scenarios | as 1 | Built, 2 cases |
| 3 | Vecozo sends a referral | Data platform | Caller, with a Vecozo token: signed but not encrypted, no `patient` or `provider`, fixed `iss` | [referral.md][ref-vec] | Not built |
| 4 | ZorgDomein sends a referral | Data platform | Caller. The security profile is not GUPZ's | [referral.md][ref-zd] | Not built, profile is external |
| 5 | A NIS queries the data platform | Data platform | Caller, as 1 | [PSA.md][psa-soc] | Not built, no separate requirements exist |
| 6 | The platform fetches a JWKS | Data platform | Caller and receiver. Hosts the key set as a stub and checks that the platform retrieves it and picks the key matching `kid` | [security.md][sec-rot], [#27][i27] | Not built, see [OP-10](open-points.md#op-10-jwks) |
| 7 | A PGO retrieves data from a DVA | PGO or DVA | Not involved. This is the Nictiz MedMij qualification | [medmij.md][mm-rol] | Outside GUPZ, and the source of the PDF/A scripts |

Three consequences:

- **There is no authorization server in GUPZ.** The data platform is a resource
  server: no `/authorize`, no `/token`. The calling system builds, signs and
  encrypts the token itself. Obtaining a token happens between a PGO, a DVA and
  the DVA's own authorization server, outside this interface. So there is no
  authentication flow to mock, and stubs appear only where traffic runs towards
  Conformancelab: situation 2 and the second half of situation 6.
- **Transport sits outside Conformancelab in every row.** See
  [OP-09](open-points.md#op-09-transport-checks).
- **Nobody uses the generic profile exactly as written.** MedMij adds `scope`,
  Vecozo deviates on five points, ZorgDomein has its own profile, and for a NIS
  nothing is written down. [#74][i74] settles that `security.md` will carry the
  profile for every situation, with ZorgDomein and Vecozo as named exceptions,
  so the generic profile is a baseline and not a fallback. It takes one test set
  per counterparty.

## PDF/A Dataplatform

Imported from the Nictiz `XIS-Server-NoManifest` variant (D-02). Server aimed:
the data platform answers, Conformancelab calls.

| Scenario | What it does | Nictiz | GUPZ | Ground |
|---|---|---|:---:|---|
| 1.1 Serve two DocumentReference resources | search `?status=current` | mandatory | yes | Core of Find Document Reference |
| 1.2 Serve zero DocumentReference resources | search on status plus a date range | mandatory | yes | An empty result must still be a valid Bundle |
| 1.3 Serve zero DocumentReference and one OperationOutcome | search with invalid syntax | mandatory | yes | Error handling |
| 1.4 Serve two PDF/A documents | retrieve two Binary resources | optional, at least one of 1.4 and 2.5 | yes | D-03 |
| 1.5 Serve zero Binary resources and one OperationOutcome | retrieve an unknown Binary | mandatory | yes | Error handling on Retrieve Document |
| 2.1 Serve one DocumentReference resource | search returning a single hit | mandatory | yes | Variant of 1.1, second test person |
| 2.2 Serve two DocumentManifest resources | request on DocumentManifest | optional | yes | D-04 |
| 2.3 Serve one DocumentManifest resource | request on DocumentManifest with a date range | optional | yes | D-04 |
| 2.4 Serve one DocumentReference by resolving a reference from a DocumentManifest | request on DocumentManifest | optional | yes | D-04 |
| 2.5 Serve one PDF/A document | retrieve through an HTTP reference | optional, alternative to 1.4 | no | D-03, and [OP-03](open-points.md#op-03-scenario-25) |
| 3.1 Receive one document | the server receives a document | [PDF/A Ontvangen][no] | no | D-01.1 |
| 3.2 Receive two documents | the server receives two documents | [PDF/A Ontvangen][no] | no | D-01.1 |

Test data: two fictional persons from the Nictiz qualification. Ellen XXX_Baltus
(fBSN 999910796) with two DocumentReferences and no manifest, and Eva
XXX_Schulte (fBSN 999910784) with two DocumentReferences and three
DocumentManifests. Fixtures in `_reference/resources`. See
[OP-04](open-points.md#op-04-test-data-specification) for why these do not hold
against a supplier.

Two GUPZ asserts are added to 1.1, 1.4 and 2.1, see D-12.

## PDF/A DVA

Imported from the Nictiz `PHR-Client` scripts. Client aimed: the calling party
is under test.

| Scenario | What it does | GUPZ | Ground |
|---|---|:---:|---|
| 1.1 Retrieve three DocumentReference resources | search | yes | Mirror of server 1.1 |
| 1.2 Retrieve zero DocumentReference resources | search without results | yes | Mirror of server 1.2 |
| 1.3 Retrieve two times one Binary resource | retrieve | yes | D-01.3 |
| 1.4 Retrieve zero Binary resources | retrieve an unknown Binary | yes | Error handling |
| 2.1 Retrieve two DocumentManifest resources | search on DocumentManifest | no | D-01.2: a conformant client never issues this request |
| 2.2 Retrieve one DocumentReference resource | search | yes | Variant of 1.1 |
| 3.1 Send one document | the client sends a document | no | D-01.1 |
| 3.2 Send two documents | the client sends two documents | no | D-01.1 |

The token here is a fixed opaque value that selects a patient (D-14): the server
behind the test scopes its answer to the patient that token belongs to, so
sending a different one changes what comes back and the counts stop matching. It
is test scaffolding, not an example of a GUPZ token. The asserts on it go no
further than presence and scheme (D-15). Testing the token itself is the Auth
DVA set.

## PDF/A _LoadResources

Writes the fixtures to the target server: two patients, seven DocumentReference
and four Binary resources, purged first and then PUT with client assigned ids
(D-13). Run it before the Dataplatform set, or every scenario fails on missing
data rather than on behaviour. It also feeds the client aimed set, which reads
from the same server.

This is provisioning, not a conformance test. [`pdfa.md`][pdfa] describes the
data platform as an MHD Document Responder, which reads; nothing in the
specification says a platform accepts writes over FHIR. So this set works
against a reference server that happens to allow them, which is how a dry run is
done, and it is not expected to work against a supplier's platform. There the
test data comes out of their own PARIS; see
[OP-04](open-points.md#op-04-test-data-specification).

Generated from FSH in `input/fsh/LoadResources/`, with its building blocks in
`components/provisioning.fsh`. Twelve fixtures, twelve writes and two purges
come down to a handful of parameterised inserts, which matters because this file
gets rewritten wholesale once GUPZ has test data of its own.

## Auth Dataplatform

Situation 1. Server aimed: the data platform is under test and Conformancelab is
the caller. Eleven cases in `output/STU3/Auth/GUPZ/Test/Dataplatform`.

| Case | What Conformancelab does | Expected | Requirement | Blocked by |
|---|---|---|---|---|
| AUTH-01 | Search with token T1 | Success | GUPZ-TOK-001, GUPZ-VAL-001 | |
| AUTH-02 | Search with token T2, signed only | Success in connectathon mode | GUPZ-TOK-001 | The configuration requirement is unwritten, [OP-06](open-points.md#op-06-the-unsigned-token) |
| AUTH-03 | Search with token T3, plain | Success in connectathon mode | GUPZ-TOK-001 | [OP-06](open-points.md#op-06-the-unsigned-token) |
| AUTH-04 | Search without an `Authorization` header | Refused | GUPZ-TOK-001 | [OP-01](open-points.md#op-01-the-challenge-when-no-credentials-are-presented) |
| AUTH-05 | Search with a header that is not a Bearer token | Refused | GUPZ-TOK-001 | [OP-01](open-points.md#op-01-the-challenge-when-no-credentials-are-presented) |
| AUTH-06 | Search with token T4, `iat` too old | Refused | GUPZ-VAL-002 | |
| AUTH-07 | Search with token T5, expired | Refused | GUPZ-VAL-002 | |
| AUTH-08 | Search with token T6, unknown issuer | Refused | GUPZ-VAL-002 | [#27][i27] on which issuers are trusted |
| AUTH-09 | Search with token T7, broken signature | Refused | GUPZ-VAL-001 | |
| AUTH-10 | Search with token T8, wrong encryption key | Refused | GUPZ-VAL-001 | |
| AUTH-11 | The same search with T1 and with T9 | Each response holds only that patient's documents | GUPZ-PAY-004, GUPZ-URL-001 | |

### AUTH-11

The token is the only thing that selects a patient, so the same request sent
with two different tokens has to produce two different result sets. AUTH-11
sends `?status=current` twice, once per test patient, and checks each response
both for a document that patient has and for the absence of a document only the
other patient has. Ellen XXX_Baltus is identified by LOINC 68688-1 and Eva
XXX_Schulte by 68626-1; both codes appear for one patient only in the Nictiz
fixtures.

All four asserts are hard. It began as a refusal case, sending a request about
one patient with a token for another, until [#73][i73] closed on 18 August 2026
with two rules: a BSN never appears in a FHIR URL or query parameter, and a
token used in a patient bound request is patient specific. The BSN stays in the
`patient` claim and that claim is what the platform resolves the patient from,
so there is nothing to compare between request and token and the refusal case
cannot exist. Until those rules were written down the two absence asserts were
warning only.

### Tokens T1 to T9

Produced with the `JwtCliTool` in open-GUPZ, generated shortly before a run
rather than handed over as files: [#69][i69] made explicit that testing should
not use static tokens, so that expired tokens can be tested too. Generating on
the spot also settles the fifteen minute lifetime, which would otherwise make a
pasted token stale within the hour. What the testers need is key material and
claim values; see [OP-05](open-points.md#op-05-key-material).

| Token | Description |
|---|---|
| T1 | Valid, RS256 signed and RSA-OAEP with A256CBC-HS512 encrypted, for the first test patient |
| T2 | Valid, signed only, not encrypted (connectathon variant) |
| T3 | Neither signed nor encrypted. May become a refusal case or disappear, see [OP-06](open-points.md#op-06-the-unsigned-token) |
| T4 | `iat` more than 900 seconds in the past, otherwise valid |
| T5 | `exp` in the past, otherwise valid |
| T6 | Unknown or untrusted `iss`, otherwise valid |
| T7 | Signature broken, for example signed with a different RS256 key |
| T8 | Encrypted with a public key that is not the platform's |
| T9 | Valid, for the second test patient, so that AUTH-11 can compare two scopes |

## Auth DVA

Situation 2. Client aimed: the token itself is judged, from the side that
receives it. This is the set that says something about a DVA's implementation;
the PDF/A DVA set does not, because there the token is scaffolding (D-14).

**How far it reaches.** A GUPZ token is a JWS signed by the caller, encrypted
into a JWE addressed to the platform. Conformancelab holds no decryption key, so
every claim stays closed: `sub`, `patient`, `aud`, `scope`, `iat`, `exp`, the
fifteen minute rule, and the whole JWS header with its `alg` and `kid`. Readable
is the JWE protected header, which is base64url and not encrypted; it carries
`alg`, `enc` and `cty`, exactly the three fields `GUPZ-TOK-002` prescribes.

So this set proves that a caller builds the right envelope and does not leak a
BSN into the URL. What is in the envelope needs a receiver with the private key,
which on this interface is the data platform and never the test tool. Everything
beyond the envelope is tested from the other side, by a platform refusing a
token.

| Case | What is checked | Requirement | Weight |
|---|---|---|---|
| DVA-01 | An `Authorization` header is present | GUPZ-TOK-001 | hard |
| | It uses the Bearer scheme | GUPZ-TOK-001 | hard |
| | The token has five dot separated parts, so it is a JWE and not a bare JWS | GUPZ-TOK-002 | hard, stops the test |
| | The JWE header declares `alg` `RSA-OAEP` | GUPZ-TOK-002 | hard |
| | The JWE header declares `enc` `A256CBC-HS512` | GUPZ-TOK-002 | hard |
| | The JWE header declares `cty` `JWT` | GUPZ-TOK-002 | hard |
| | The JWE header names a key | none | warning, D-23 |
| | No `patient=` in the URL | GUPZ-URL-001 | hard |
| | No `subject=` in the URL | GUPZ-URL-001 | hard |
| | The BSN naming system does not appear in the URL | GUPZ-URL-001 | hard |
| DVA-02a | The caller handles a 401 with `invalid_token` | none | manual, D-22 |
| DVA-02b | The caller handles a 403 with `insufficient_scope` | none | manual, D-22 |

The part count stops the test when it fails: decoding a header out of something
that is not a JWE says nothing. How the header is read is in
[authoring.md](authoring.md#reading-a-token).

DVA-02 hands the caller each refusal from a WireMock stub rather than from a
server, which is the point: a real server refuses when it feels like it, a stub
refuses exactly as the specification prescribes, every time, in both shapes. The
mapping sits in a `.stub` file under `_stub/`, is declared as a fixture, and an
operation of type `stub` points at it. Stubs answer on a different address than
FHIR traffic, see
[authoring.md](authoring.md#destinations).

Not covered beyond the envelope: the signature, which needs the decrypted inner
token; and one token per patient, which is observable in principle by capturing
two and asserting they differ, but needs a second operation and a caller willing
to drive it.

[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[pdfa-sec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#security
[psa-soc]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/PSA.md#seperation-of-concerns
[mm-rol]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/architecture/medmij.md#rol-in-het-medmij-afsprakenstelsel
[sec-tok]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#token-beveiliging
[sec-rot]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#key-rotation
[ref-vec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/referral.md#vecozo-dienst-verwijzen-1
[ref-zd]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/referral.md#zorgdomein
[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i69]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/69
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73
[i74]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/74
[no]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Ontvangen

## Auth Self test

Not a conformance test, and hidden from anyone without the admin role through
`adminOnly` in its properties. It answers a question about this repository: do
the refusal asserts of [D-30][d30] fire? They were written against
`security.md` and have never run, because no platform answers a GUPZ token yet
and the FHIR server behind the tests accepts everything.

Each scenario answers from a stub and inserts the shipped RuleSet, not a copy,
so what is exercised is what a supplier gets.

| Scenario | The stub answers | Expected |
|---|---|---|
| SELF-01 | the refusal `security.md` prescribes | passes |
| SELF-02 | 403 with `insufficient_scope` | fails on the status |
| SELF-03 | 401 without a `WWW-Authenticate` header | fails on the challenge |
| SELF-04 | 401 whose OperationOutcome carries `forbidden` | fails on the OperationOutcome |

Three scenarios are meant to be red. A mutation that stays green means the
assert it targets is not testing what it claims, which is the point of running
it.

A stub operation sends nothing: the engine waits for a request and then
validates against it and the stubbed answer. So this set needs a caller pointed
at the stub endpoint the setup screen shows. Any client will do, and the mapping
matches any GET, so the path is free:

```
curl -i -H "Authorization: Bearer whatever" "<stub endpoint>/DocumentReference?status=current"
```

Running the set as Automated does nothing. Automation only sends the requests
the engine would send itself, and a stub operation is not one of them. The same
holds for DVA-02.

[d30]: decisions.md#d-30-a-refusal-is-asserted-on-status-challenge-and-operationoutcome

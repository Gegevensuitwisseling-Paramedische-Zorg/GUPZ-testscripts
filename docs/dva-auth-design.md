# Testing the token a caller produces

The authentication set aimed at the calling party. Where
[auth-test-design.md](auth-test-design.md) judges what a data platform does with
a token it receives, this one judges the token itself, from the side that
receives it.

The distinction matters because the obligations run the other way. Everything
`security.md` says about the content of a token is a requirement on the party
that builds it. A platform can only accept or refuse. So for a DVA this is the
set that says something about their implementation, and the PDF/A set is not.

## How far this can reach, and why

A GUPZ token is a nested JWT: a JWS signed by the caller, encrypted into a JWE
addressed to the receiving platform. Conformancelab holds no decryption key, so
everything inside stays closed. That includes every claim: `sub`, `patient`,
`aud`, `scope`, `iat`, `exp` and the fifteen minute rule, and the whole JWS
header with its `alg` and `kid`.

What is readable is the JWE protected header, because that part is base64url and
not encrypted. It carries `alg`, `enc` and `cty`, which happens to be exactly
the three fields `GUPZ-TOK-002` prescribes.

So this set proves that a caller builds the right kind of envelope, and that it
does not leak a BSN into the url. It cannot prove what is in the envelope. That
needs a receiver with the private key, which on this interface is the data
platform and never the test tool. Anything beyond the envelope has to be tested
by a platform refusing a token, which is what the Dataplatform set does.

## How the token is read

Three Conformancelab extensions in a chain, available since the IG update of
18 August 2026. Before that a token was an opaque string to the engine.

1. A variable with `headerField` `Authorization` and a `sourceId` pointing at
   the operation's `requestId`, carrying
   `Interoplab-CL-ext-variable-regex-mapper`
   with the pattern `(?<=Bearer )[A-Za-z0-9_-]+`. The lookbehind skips the
   scheme; the character class stops at the first dot, so the match is exactly
   the first segment of the compact serialization, which is the protected
   header. Regex groups are not supported, so the pattern has to match the
   wanted text and nothing else.
2. An assert carrying `Interoplab-CL-ext-assert-input-variable` with that
   variable's name and `Interoplab-CL-ext-assert-mapper-function`
   `base64Decode`.
3. `Interoplab-CL-ext-assert-regex-matches` on the assert's `value`, so the
   check is a pattern and not an exact string. `"alg"\s*:\s*"RSA-OAEP"`
   tolerates the whitespace a serialiser may or may not add.

A second variable holds the whole token, `(?<=Bearer ).*$`, to count the
segments.

## The cases

| Case | What is checked | Requirement | Weight |
|---|---|---|---|
| DVA-01 | An `Authorization` header is present | GUPZ-TOK-001 | hard |
| | It uses the Bearer scheme | GUPZ-TOK-001 | hard |
| | The token has five dot separated parts, so it is a JWE and not a bare JWS | GUPZ-TOK-002 | hard, stops the test |
| | The JWE header declares `alg` `RSA-OAEP` | GUPZ-TOK-002 | hard |
| | The JWE header declares `enc` `A256CBC-HS512` | GUPZ-TOK-002 | hard |
| | The JWE header declares `cty` `JWT` | GUPZ-TOK-002 | hard |
| | The JWE header names a key | none yet | warning |
| | No `patient=` in the url | GUPZ-URL-001 | hard |
| | No `subject=` in the url | GUPZ-URL-001 | hard |
| | The BSN naming system does not appear in the url | GUPZ-URL-001 | hard |
| DVA-02a | The caller handles a 401 with `invalid_token` | none | manual |
| DVA-02b | The caller handles a 403 with `insufficient_scope` | none | manual |

The part count stops the test when it fails, because decoding a header out of
something that is not a JWE says nothing.

The key id is the one warning, and the reason is worth keeping. `GUPZ-JWS-001`
requires a `kid`, but on the JWS header, which is inside the encryption and
unreadable from here. The JWE header table in `security.md` lists only `alg`,
`enc` and `cty`. So a `kid` on the JWE is required by nothing, and failing a
caller over it would make a tool's habit into a rule. It is still worth
reporting, because key rotation under [#27][i27] has the platform resolve its
encryption key from a JWKS and a `kid` is how that lookup finds the right one.
That gap is raised in [#75][i75].

## No token is prescribed, and this set is the only one where that is right

Every other set names a fixed qualification token on the operation. That tells
the caller what to send and lets the server behind the test scope its answer to
one patient. Here the caller's own token is the subject, so prescribing one
would replace the thing being judged.

Two consequences follow. Conformancelab shows the expected request without an
`Authorization` header, and the caller sends the token it would send to a real
platform. And an Automated dry run cannot validate this set: with no header
described, the engine sends no token, and every assert here fails. Only a real
caller can exercise it.

## Showing the caller a refusal

`security.md` defines two refusals: a 401 with `error=invalid_token` and an
OperationOutcome carrying `login`, and a 403 with `error=insufficient_scope`, a
`scope` parameter naming what is needed, and an OperationOutcome carrying
`forbidden`. The Dataplatform set checks that a platform produces them. DVA-02
does the reverse: it hands a caller each one and asks what it did with it.

The response comes from a WireMock stub rather than from a server, which is the
point. A real server refuses when it feels like it; a stub refuses exactly as the
specification prescribes, every time, in both shapes. The mapping sits in a
`.stub` file under `_stub/`, is declared as a fixture, and an operation of type
`stub` points at the fixture.

### The two open ends of #70, and what was done with them

The shape of both responses is settled: status, `WWW-Authenticate` and the
OperationOutcome code all stand in `security.md`. Two things are not.

**How much detail the text may carry.** In test more is allowed, provided a
platform can show it switches off. The stubs use the terse form, the one a
platform must be able to produce, because a caller that copes with a bare
"The access token expired" copes with a chattier variant too. The reverse does
not hold.

**When a 401 applies and when a 403.** For these scenarios it does not need
deciding. Each refusal gets its own scenario, and a caller has to handle both
whichever way the question is settled. So this set is not waiting on that issue.

### Why the judgement is manual, and how one is written

`security.md` says what a platform must return. It says nothing about what a
caller must then do, and asserting something anyway would invent a requirement
rather than test one. So the assert pauses the run and puts the question to
whoever is watching. The answer lands in the report like any other result.

What makes an assert manual is `operator` `manualEval` and nothing else. The
engine picks a validator by operator, so that one word is the whole mechanism.
R5 also has a field `defaultManualCompletion`, which looks like it should do the
job and does not: the engine stores it and acts on the operator. Written the
wrong way round the first time, and both scenarios then failed instead of
waiting, which is a confusing way to fail because nothing about the response was
wrong.

`manualEval` appears in neither the base FHIR operator list nor the
Conformancelab one for additional operators, so it lives only in the engine.
Used anyway, because there is no other way to record a human judgement inside a
run, and because the imported material relies on it too.

An unattended run of this set therefore never finishes: it waits. That is
correct. It needs a real caller and somebody watching.

The questions are deliberately concrete. After a 401: did the caller report the
failure and stop, rather than repeat the same request with the same token or fall
back to a request without one. After a 403: did it use the `scope` parameter,
which exists precisely so a caller can ask for what it lacks.

### A stub answers on a different address

Established on 27 August, after the first attempt left the operation sitting on
"Waiting for request". Nothing was wrong with the script or with the platform; the
request went to the wrong place.

Conformancelab reaches these scenarios by two separate paths. A FHIR request goes
to `/q/<organization id>/<usecase>/<version>/fhir`, which the proxy routes to a
FHIR server; the engine watches that traffic and matches it against an operation.
A stub is not on that path at all. It is served by the engine itself, at
`/cl/<organization id>/`, which the proxy routes straight through, stripping the
id into a header. Only requests arriving there reach the filter that answers from
a WireMock mapping.

Both addresses are on the same host and share the same organization id, so one
base url is enough to work out the other. The simulator in `tools/dva-sim` does
that: a card whose operation is a stub sends to the derived address and shows it
before sending.

Guidance being prepared for the implementation guide will let a destination
declare its own url, with `${STUB-ENDPOINT}` resolving to exactly this address.
That is not live yet: the engine deliberately does not store `destination.url`
while its placeholders cannot be resolved. So a single destination is right for
now, and the address is the caller's problem rather than the script's.

## What is not covered

**Every claim.** See above; they are encrypted. The Dataplatform set covers them
from the other side, by checking that a platform refuses a token that is wrong.

**The signature.** Whether the JWS is signed with RS256, and whether it verifies
against the caller's published key, needs the decrypted inner token.

**One token per patient.** [#73][i73] requires a patient specific token. Two
requests with two different patients would have to carry two different tokens,
which is observable in principle: capture both and assert they differ. Not
built, because it needs a second operation and a caller willing to drive it.

**Whether the caller validates the server certificate.** Not visible in a
request. The Proxy records what was presented in the other direction, which is
the closest thing available.

[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73
[i75]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/75

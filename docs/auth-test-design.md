# Auth test set: model

The model behind the second Test Set, covering the token and authentication part
of the interface between a calling party and the GUPZ data platform. It was
written before any TestScript, so that the scope and the requirement behind each
case were agreed first, and it stays here as the record of what each case tests
and what is still open.

All eleven cases are built and sit in `output/STU3/Auth/GUPZ/Test/Dataplatform`.
What is not there is the test data: every case needs a token that GUPZ supplies,
and the operator pastes it when setting up the run.

## Scope

Server aimed: the data platform is the system under test and Conformancelab is
the caller. The mirror image, testing a DVA as the calling party, is out of
scope for now, for the same reason as with the PDF/A set: the connectathon of
22 September 2026 is about the data platform.

The requirement identifiers used below (`GUPZ-TR-001`, `GUPZ-VAL-002` and so on)
come from the Interoplab requirements inventory for token and authentication.
That inventory is not public yet; it is expected to be published later, and this
page will link to it once it is. Until then every row points at the section of
the open-GUPZ specification the requirement was derived from, which is the
authoritative source anyway. Open-GUPZ issue [#71][i71] is the public index of
the open points that came out of the inventory.

## What the specification asks

All of it comes from [`docs/api/security.md`][sec] unless stated otherwise.

| Id | Requirement | Source |
|---|---|---|
| GUPZ-TR-001 | Traffic runs over mTLS, both sides authenticate with a certificate | [Transport level security][sec-tls] |
| GUPZ-TR-002 | TLS 1.2 or 1.3, at least NCSC level *Voldoende* | [Eisen aan de TLS configuratie][sec-tlscfg] |
| GUPZ-TR-003 | The listed cipher suites are supported | [Eisen aan de TLS configuratie][sec-tlscfg] |
| GUPZ-TR-004 | PKIoverheid Private G1 certificates on both sides | [Eisen aan de te gebruiken certificaten][sec-cert] |
| GUPZ-TOK-001 | Every call carries `Authorization: Bearer <encrypted token>` | [Token beveiliging][sec-tokensec] |
| GUPZ-TOK-002 | Sign then encrypt: JWS inside JWE | [Token beveiliging][sec-tokensec] |
| GUPZ-JWS-001 | JWS header carries `alg`, `typ` and `kid` | [Token inhoud][sec-token] |
| GUPZ-PAY-001 | Payload carries `iat`, `exp` and `iss` | [Token inhoud][sec-token] |
| GUPZ-PAY-002 | `patient`, `provider`, `nbf`, `jti`, `aud` and `scope` are optional, with a prescribed format when present | [Token inhoud][sec-token] |
| GUPZ-VAL-001 | The platform decrypts the JWE and validates the JWS signature | [Token beveiliging][sec-tokensec] |
| GUPZ-VAL-002 | The platform refuses a request when `iat` is older than 15 minutes, when `exp` has passed, and validates `iss` | [Token beveiliging][sec-tokensec] |
| GUPZ-CRY-001 | X.509 keys from a trusted CA, RSA-SHA256 for signing, RSA-OAEP-256 for encryption | [Eisen aan de te gebruiken certificaten][sec-cert2] |
| GUPZ-JWKS-001 | JWKS key rotation | [Key rotation][sec-rot] |
| GUPZ-MED-002 | A DVA fills `scope` with MedMij data service numbers | [MedMij specifieke eisen][sec-medmij] |

## What Conformancelab can and cannot do here

**The token is operator input.** A TestScript variable, sent as
`Authorization: Bearer ${token}`. The variable deliberately has no default: the
operator pastes the token the case describes. This is the same mechanism the
Nictiz PDF/A scripts use for their tokens, so it is proven on this engine. It also means GUPZ can
supply pre-signed tokens without the engine having to sign anything, which
matters because Conformancelab cannot produce a JWE at all.

**Conformancelab cannot inspect a token.** There is no JWT decode, and the assert
mapper functions are limited to `length`, `urlDecode` and `urlEncode`. So the
content of a token can only be tested through the behaviour of the platform that
receives it, never by reading the token itself. For a server aimed set that is
no loss: what the platform does with a token is exactly what we want to test.

**Groovy rules are the escape hatch.** An assert can call an external Groovy
script with access to request, response and FHIRPath. If we ever need to inspect
a token or decode base64, that is where it would happen. Not needed for the
model below.

**Conformancelab presents a client certificate, pre-configured.** Nothing in the
Conformancelab guide or in any Interoplab TestScript repository mentions client
certificates, but Interoplab confirms the engine can present one and that it is
configured per instance rather than per TestScript. That has one useful
consequence for this set: every case that succeeds proves an mTLS connection was
established, because without an accepted client certificate there would be no
response at all. `GUPZ-TR-001` is therefore covered implicitly by AUTH-01.

It does not cover the other half of that requirement, that the platform refuses
a caller without a valid client certificate. If the engine always presents its
certificate, a TestScript cannot produce that situation. Nor does it cover
`GUPZ-TR-002` and `GUPZ-TR-003`, the TLS version and cipher suites, or
`GUPZ-TR-004`, the certificate profile: those live in the handshake, which a
TestScript never sees.

## Why this set uses no stubs

Conformancelab can mock an endpoint with a WireMock stub and the `stub`
operation code: it registers the stub, waits for the system under test to call
it, and asserts on the request that arrives. That is how our earlier OAuth proof
of concept tested a client, by playing the authorization server and the token
endpoint.

None of that applies here, and the reason is worth writing down because it is
easy to mistake for an omission.

**There is no flow on this interface to mock.** The data platform is a resource
server, not an authorization server. It has no `/authorize` and no `/token`
endpoint. According to [`security.md`][sec-tokensec] the calling system creates
the token itself, signs it with its own private key, encrypts it with the
platform's public key and sends it on every call; the platform decrypts,
validates and answers. Obtaining a token happens between a PGO, a DVA and the
DVA's own authorization server, all of which sit outside this interface. A stub
would have nothing to stand in for.

**A stub only works when the system under test calls us.** Conformancelab hosts
its stubs on its own `/cl/{organizationId}/` route. In a server aimed test the
traffic runs the other way, so there is nothing for a stub to catch.

What follows from this is a real limitation, not a gap in the test set: these
cases prove what the platform does with a token, never that a caller can produce
one correctly. Token production is a property of the caller and belongs in a
client aimed test.

### Where stubs do belong

Three places, none of them in this set today.

**Testing a DVA.** When the calling party is the system under test,
Conformancelab has to be the counterparty: mock the authorization and token
endpoints, let the DVA run the flow against them, and assert on the requests it
sends. That is the client aimed set, and the mechanics are proven.

**A JWKS fetch by the platform.** This is the one moment where the data platform
would call out during authentication: to retrieve the public signing key of the
caller so it can verify the signature, or to publish its own encryption key.
Conformancelab could host that JWKS as a stub, which would make it testable
whether the platform fetches the key set, picks the key that matches the `kid`
in the token header, and follows a rotation. It is not built because the
mechanism is not specified: [`security.md`][sec-rot] says only that JWKS key
rotation is used and flags the subject as still to be worked out, and
[#27][i27] is the open discussion.

**Obtaining a token dynamically.** Conformancelab has an authentication script
concept that runs a token flow before a test set and hands the result to the
tests that follow. If GUPZ ever wants the token fetched rather than pasted, that
is the mechanism, and it would need stubbed or real endpoints to fetch from. For
now pasting is deliberate: the tokens come from GUPZ and the engine cannot
produce a JWE anyway.

## Test data GUPZ needs to supply

Every case below needs a prepared token. They can be produced with the
`JwtCliTool` that already sits in open-GUPZ, except where noted. This is the
list to hand to whoever prepares the connectathon data.

| Token | Description |
|---|---|
| T1 | Valid, signed and encrypted, for the test patient |
| T2 | Valid, signed only, not encrypted (connectathon variant) |
| T3 | Valid, neither signed nor encrypted (connectathon variant, definition still open) |
| T4 | `iat` more than 15 minutes in the past, otherwise valid |
| T5 | `exp` in the past, otherwise valid |
| T6 | Unknown or untrusted `iss`, otherwise valid |
| T7 | Signature broken, for example signed with a different key |
| T8 | Encrypted with a public key that is not the platform's |
| T9 | Valid, but `patient` is a different person than the one the request asks for |

Two practical points. A token with a fifteen minute lifetime cannot sit in a
TestScript as a default value for long, so either the connectathon tokens get a
long `exp`, or they are generated on the day, or the platform relaxes the age
check in test mode. And T3 cannot be produced by `JwtCliTool` as it stands,
because what "plain" means has not been defined: an unsigned JWT per RFC 7519 is
a JWS with `alg: none` and an empty signature, which is a different thing from a
bare base64 payload.

## The test model

Two levels of assert for every negative case. What we can do today is confirm
that the request did not succeed. What we want is the exact status code and
`OperationOutcome`, and that is blocked by [#70][i70]; the model is written so
those asserts can be added later without restructuring.

| Case | What Conformancelab does | Expected | Requirement | Blocked by |
|---|---|---|---|---|
| AUTH-01 | Search with token T1 | Success | GUPZ-TOK-001, GUPZ-VAL-001 | |
| AUTH-02 | Search with token T2, signed only | Success in connectathon mode | GUPZ-TOK-001 | Configuration requirement is specified nowhere |
| AUTH-03 | Search with token T3, plain | Success in connectathon mode | GUPZ-TOK-001 | Definition of "plain" is open |
| AUTH-04 | Search without an `Authorization` header | Refused | GUPZ-TOK-001 | [#70][i70] for the exact response |
| AUTH-05 | Search with a header that is not a Bearer token | Refused | GUPZ-TOK-001 | [#70][i70] |
| AUTH-06 | Search with token T4, `iat` too old | Refused | GUPZ-VAL-002 | [#69][i69] on what the rule means, [#70][i70] |
| AUTH-07 | Search with token T5, expired | Refused | GUPZ-VAL-002 | [#70][i70] |
| AUTH-08 | Search with token T6, unknown issuer | Refused | GUPZ-VAL-002 | [#27][i27] on which issuers are trusted, [#70][i70] |
| AUTH-09 | Search with token T7, broken signature | Refused | GUPZ-VAL-001 | [#67][i67] on the algorithm, [#70][i70] |
| AUTH-10 | Search with token T8, wrong encryption key | Refused | GUPZ-VAL-001 | [#68][i68] on the JWE profile, [#70][i70] |
| AUTH-11 | Search with token T9, other patient than the request | Refused | not specified | [#73][i73], case is advisory |

AUTH-11 is the case worth arguing about. `security.md` describes `patient` as the
BSN of the patient whose data is being requested, but nowhere does it say that
the platform must refuse a request for a different patient than the one in the
token. As an authorisation rule that is arguably the single most important check
in the whole interface, and it is not written down. Raised as [#73][i73]. The
case is built with both asserts on warning only, so it reports what a platform
does without being able to fail it while the question is open.

## What this set does not cover

**Transport beyond the connection itself.** `GUPZ-TR-002`, `GUPZ-TR-003` and
`GUPZ-TR-004` need inspection of the handshake and of the certificates, which a
TestScript does not do, and the refusal half of `GUPZ-TR-001` cannot be produced
by an engine that always presents its certificate. Proposal: check these out of
band on the day, with a TLS scanner against the endpoint and a manual attempt to
connect without a client certificate. That does need a written expectation,
which for the connectathon is complicated by the fact that one mail says
self-signed certificates and a later one says self-signed is undesirable and
proposes a hosted CA.

**Token structure.** `GUPZ-TOK-002`, `GUPZ-JWS-001`, `GUPZ-CRY-001` and
`GUPZ-PAY-001` describe what the caller produces. In a server aimed set they can
only be tested indirectly, through acceptance and refusal. Testing them directly
belongs in the client aimed set, where a DVA is under test, and would need a
Groovy rule to inspect the token.

**Key rotation.** `GUPZ-JWKS-001` needs a JWKS endpoint and an agreement on
discovery and trust, which is [#27][i27]. Not for this connectathon.

**Claim obligations.** Which claims are mandatory in which profile is [#38][i38]
and [#52][i52]. Until those are settled, a test on the presence of `patient`,
`aud` or `scope` would test an assumption.

## What still has to happen

1. Get the tokens T1 to T9, or agree who produces them and when. This is the
   critical path: the scripts run, but without tokens they prove nothing.
2. Decide what "plain" means for T3, otherwise AUTH-03 cannot be prepared.
3. Tighten the negative asserts once [#70][i70] lands. Each refusal case now
   only asserts that the response is not 200, with the expected 401 or 403 as a
   warning. Those become hard asserts as soon as the response is specified.
4. Arrange the out of band transport check described above.
5. Revisit AUTH-11 when [#73][i73] is decided. If the check becomes a
   requirement, the two warnings become hard asserts.

[sec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[sec-tls]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#transport-level-security
[sec-tlscfg]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-tls-configuratie
[sec-cert]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten
[sec-cert2]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten-1
[sec-token]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#token-inhoud
[sec-tokensec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#token-beveiliging
[sec-medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#medmij-specifieke-eisen-op-het-gebied-van-application-level-security
[sec-rot]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#key-rotation
[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i38]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/38
[i52]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/52
[i67]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/67
[i68]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/68
[i69]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/69
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i71]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/71
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73

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

This set covers one of the seven authentication situations on this interface,
situation 1 in [auth-situations.md](auth-situations.md), which also explains who
is the system under test in the other six and why most of them need something
this set does not.

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

The Modality column reads the source with the key words of [RFC 2119][rfc2119].
`security.md` does not use them, so each one is our reading of a Dutch sentence,
and where that reading is not certain the column says so. It is not decoration:
the modality decides what an assert may do.

| Modality in the source | What the assert does |
|---|---|
| MUST, MUST NOT, REQUIRED | Hard assert. A platform that fails it is not conformant |
| SHOULD, RECOMMENDED | `warningOnly` is true. Reports the deviation without failing anyone |
| MAY, OPTIONAL | No assert, or an informational one. There is nothing to be conformant to |
| Unclear | Treated as SHOULD until it is settled, and an issue is raised |

That last row is where two of our findings come from. `GUPZ-TR-002` and
`GUPZ-TR-003` are only open because nobody can tell whether every party has to
support every version and every cipher suite, or one of each. Written with the
key words, neither question would exist.

| Id | Requirement | Modality | Source |
|---|---|---|---|
| GUPZ-TR-001 | Traffic runs over mTLS, both sides authenticate with a certificate | MUST | [Transport level security][sec-tls] |
| GUPZ-TR-002 | TLS 1.2 or 1.3, at least NCSC level *Voldoende* | MUST, but unclear which version | [Eisen aan de TLS configuratie][sec-tlscfg] |
| GUPZ-TR-003 | The listed cipher suites are supported | Unclear: all suites or one | [Eisen aan de TLS configuratie][sec-tlscfg] |
| GUPZ-TR-004 | PKIoverheid Private G4 certificates on both sides, and not required for testing | MUST in production, NOT REQUIRED for testing | [Eisen aan de te gebruiken certificaten][sec-cert] |
| GUPZ-TOK-001 | Every call carries `Authorization: Bearer <encrypted token>` | MUST | [Token beveiliging][sec-tokensec] |
| GUPZ-TOK-002 | Sign then encrypt: JWS inside JWE, with a JWE header carrying `alg` RSA-OAEP, `enc` A256CBC-HS512 and `cty` JWT | MUST | [Token beveiliging][sec-tokensec] |
| GUPZ-JWS-001 | JWS header carries `alg` with the fixed value `RS256`, `typ` and `kid` | MUST | [Token inhoud][sec-token] |
| GUPZ-PAY-001 | Payload carries `iat`, `exp` and `iss` | MUST | [Token inhoud][sec-token] |
| GUPZ-PAY-002 | `aud` is mandatory and `patient` is mandatory for a patient bound request; `provider`, `nbf`, `jti` and `scope` are optional. Each has a prescribed format when present | MUST for `aud`, and for `patient` on a patient bound request; the rest OPTIONAL | [Token inhoud][sec-token] |
| GUPZ-VAL-001 | The platform decrypts the JWE and validates the JWS signature | MUST | [Token beveiliging][sec-tokensec] |
| GUPZ-VAL-002 | The platform refuses a request unless `now - iat < 900` and `now < exp`, and validates `iss`. The tolerated clock skew is [#77][i77], proposing Dutch NTP and at most 30 seconds | MUST; the clock skew is unresolved | [Token beveiliging][sec-tokensec] |
| GUPZ-CRY-001 | X.509 keys from a trusted CA, RSA-SHA256 for signing, RSA-OAEP with A256CBC-HS512 for encryption | MUST | [Eisen aan de te gebruiken certificaten][sec-cert2] |
| GUPZ-JWKS-001 | Both sides publish a JWKS on `/.well-known/jwks.json`: the caller its signing keys, the platform its encryption keys. The platform refetches when a token carries an unknown `kid` | MUST, with manual exchange as the fallback for 22 September | [Key rotation][sec-rot] |
| GUPZ-VAL-003 | A refused token is answered with 401, a `WWW-Authenticate: Bearer` header carrying `error="invalid_token"`, and an OperationOutcome with `severity` error and `code` `login` | MUST, under review | [Afhandeling van ongeldige tokens][sec-invalid] |
| GUPZ-VAL-004 | A request outside the scope in the token is answered with 403, `error="insufficient_scope"` with the required scope, and an OperationOutcome with `code` `forbidden` | MUST, under review | [Afhandeling van ontbrekende autorisatie][sec-forbidden] |
| GUPZ-MED-002 | A DVA fills `scope` with MedMij data service numbers | MUST for a DVA; checking it is a MAY for the platform | [MedMij specifieke eisen][sec-medmij] |

## What Conformancelab can and cannot do here

**The token is operator input.** A TestScript variable without a default, sent
as `Authorization: Bearer ${token}`; the operator pastes the token the case
describes. The Nictiz PDF/A scripts use the same mechanism, so it is proven on
this engine, and it lets GUPZ supply pre-signed tokens without the engine having
to sign anything, which matters because Conformancelab cannot produce a JWE.

**A token can be read, but that does not help here.** Since 18 August a regex
mapper, `Interoplab-CL-ext-assert-input-variable` and `base64Decode` can be
chained to read a claim out of a token. In a server aimed set we made the token
ourselves, so there is nothing to learn. It matters for the mirror image, where
a DVA is under test; see [auth-situations.md](auth-situations.md).

**Groovy rules remain the fallback for what an assert cannot express**, with
access to request, response and FHIRPath. Not needed for the model below.

**Conformancelab presents a client certificate, configured per instance rather
than per TestScript.** That has one useful consequence for this set: every case
that succeeds proves an mTLS connection was established, because without an
accepted client certificate there would be no response at all. `GUPZ-TR-001` is
therefore covered implicitly by AUTH-01.

It does not cover the other half of that requirement, that the platform refuses
a caller without a valid client certificate. If the engine always presents its
certificate, a TestScript cannot produce that situation. Nor does it cover
`GUPZ-TR-002` and `GUPZ-TR-003`, the TLS version and cipher suites, or
`GUPZ-TR-004`, the certificate profile: those live in the handshake, which a
TestScript never sees.

## Where the token comes from

The operator generates it with `JwtCliTool` and pastes it, the route [#69][i69]
also points at. The alternative, letting Conformancelab mint the token, is what
suppliers tend to prefer, so it is worth being clear about what that would and
would not solve.

Pasting is not the burden; that is one field per run. The burden on a supplier
is that their platform has to trust whoever issued the token, and that is
configuration they cannot avoid, because validating the token is what is being
tested. The real question is therefore not how the token reaches Conformancelab
but whose key the platform has to trust.

Minting would cover the happy flow and the two time based cases, since
`${JWT-ENCODE}` takes a claims object and `${CURRENT-NUMERICDATE}` can set a
stale `iat`. It would not cover AUTH-09 and AUTH-10, which need control over
keys, nor the encrypted variant, which needs a JWE the engine cannot produce.
And the guide does not say which key signs or where the matching public key can
be found, so a supplier could not verify a minted token at all.

Switching later costs little: the token is a variable, so operator input or a
`${JWT-ENCODE, ...}` default is one line per script. Operator input stays the
baseline because it covers all eleven cases.

## Why this set uses no stubs

Conformancelab can mock an endpoint with a WireMock stub, wait for the system
under test to call it and assert on the request that arrives. Two reasons that
does not apply here, both worth stating because the absence looks like an
omission.

There is no flow to mock. The data platform is a resource server with no
`/authorize` and no `/token`: the caller builds, signs and encrypts the token
itself and sends it on every call. Obtaining a token happens between a PGO, a
DVA and the DVA's own authorization server, outside this interface. And a stub
only catches traffic that comes towards us, while in a server aimed test it runs
the other way.

The limitation that follows is real: these cases prove what the platform does
with a token, never that a caller can produce one correctly. That belongs in a
client aimed set.

Stubs return in three places, none of them here. Testing a DVA needs
Conformancelab to play the authorization and token endpoints. A JWKS fetch by
the platform could be stubbed now that [#27][i27] specifies one on
`/.well-known/jwks.json`, which would make key selection on `kid` testable. And
if GUPZ ever wants the token fetched rather than pasted, the engine has an
authentication script concept that would need endpoints to fetch from.

## Test data GUPZ needs to supply

Every case below needs a token. They are produced with the `JwtCliTool` that
already sits in open-GUPZ, and they are generated shortly before a run rather
than handed over as a set of files: in [#69][i69] it was made explicit that
testing should not use static tokens, so that expired tokens can be tested too.
What the testers need is therefore the key material and the claim values, not
nine finished tokens. The list below is the recipe.

| Token | Description |
|---|---|
| T1 | Valid, signed with RS256 and encrypted with RSA-OAEP and A256CBC-HS512, for the test patient |
| T2 | Valid, signed only, not encrypted (connectathon variant) |
| T3 | Neither signed nor encrypted. GUPZ has come out against this variant, see below; it may become a refusal case or disappear |
| T4 | `iat` more than 900 seconds in the past, otherwise valid |
| T5 | `exp` in the past, otherwise valid |
| T6 | Unknown or untrusted `iss`, otherwise valid |
| T7 | Signature broken, for example signed with a different RS256 key |
| T8 | Encrypted with a public key that is not the platform's |
| T9 | Valid, for the second test patient, so that AUTH-11 can compare two scopes |

Generating on the spot also settles the fifteen minute lifetime, which would
otherwise make a token pasted into a script stale within the hour. GUPZ supplies
the PEM files.

T3 is the one entry that may disappear rather than get defined. What "plain"
means was never written down, and asked which reading applies GUPZ answered on
17 August that it would rather have neither, because of the known
vulnerabilities around `alg: none`. A token is always signed; dropping the
encryption is the concession a test setup gets. If that holds, AUTH-03 reverses
into a refusal case, which is the stronger test because it asserts a security
property instead of a configuration. Nothing is changed here until the issue
lands.

## The test model

Two levels of assert for every negative case. What we can do today is confirm
that the request did not succeed. What we want is the exact status code and
`OperationOutcome`, and that is blocked by [#70][i70]; the model is written so
those asserts can be added later without restructuring.

`security.md` now describes those responses, and GUPZ confirmed on 17 August that
they may be taken as written, with only the detail level of `error_description`
and `diagnostics` still under discussion. That is enough to harden most of what
these cases assert: the status code, the `WWW-Authenticate` header and the
`OperationOutcome` code are settled, and only the human readable text is not.

Two things came up afterwards and are not settled. Which failure is a 401 and
which a 403 was raised as needing agreement, because the two lie close together
and implementations differ. And there is a proposal to let a platform reveal as
much as possible in a test setup while revealing nothing in production, as a
switch, which GUPZ can accept on the condition that a run without the switch is
also tested. If that lands, a refusal case has two expected outcomes rather than
one, and this set will need to know which mode a platform is running in.

| Case | What Conformancelab does | Expected | Requirement | Blocked by |
|---|---|---|---|---|
| AUTH-01 | Search with token T1 | Success | GUPZ-TOK-001, GUPZ-VAL-001 | |
| AUTH-02 | Search with token T2, signed only | Success in connectathon mode | GUPZ-TOK-001 | Configuration requirement is specified nowhere |
| AUTH-03 | Search with token T3, plain | Success in connectathon mode | GUPZ-TOK-001 | Definition of "plain" is open |
| AUTH-04 | Search without an `Authorization` header | Refused | GUPZ-TOK-001 | [#70][i70] for the exact response |
| AUTH-05 | Search with a header that is not a Bearer token | Refused | GUPZ-TOK-001 | [#70][i70] |
| AUTH-06 | Search with token T4, `iat` too old | Refused | GUPZ-VAL-002 | [#70][i70] |
| AUTH-07 | Search with token T5, expired | Refused | GUPZ-VAL-002 | [#70][i70] |
| AUTH-08 | Search with token T6, unknown issuer | Refused | GUPZ-VAL-002 | [#27][i27] on which issuers are trusted, [#70][i70] |
| AUTH-09 | Search with token T7, broken signature | Refused | GUPZ-VAL-001 | [#70][i70] |
| AUTH-10 | Search with token T8, wrong encryption key | Refused | GUPZ-VAL-001 | [#70][i70] |
| AUTH-11 | The same search with T1 and with T9 | Each response holds only that patient's documents | not specified | [#73][i73], distinguishing asserts are advisory |

AUTH-11 is the case that needed the most argument, and it changed shape on 17 August.
It began as a refusal case: send a request about one patient with a token for
another and expect a rejection. Raised as [#73][i73], because `security.md`
describes `patient` as the BSN of the patient whose data is being requested but
never says the platform has to check it.

The answer settled the design rather than the question. The preference stated in
[#73][i73] is to carry the BSN in the token and keep it out of request
parameters, which means there is nothing to compare: a search never names a
patient. That matches what the scripts already do, since every PDF/A search in
this repository queries `?status=current` and leaves the patient to the token.

So the refusal case cannot exist, but the risk behind it can still be tested,
and more directly. The token is now the only thing that selects a patient, so
the same request sent with two different tokens has to produce two different
result sets. AUTH-11 sends `?status=current` twice, once per test patient, and
checks each response both for a document that patient has and for the absence of
a document only the other patient has. Ellen XXX_Baltus is identified by LOINC
68688-1 and Eva XXX_Schulte by 68626-1; both codes appear for one patient only in
the Nictiz fixtures.

A platform that ignores the token and returns everything now fails on the first
assert of each test, because a response holding both patients also holds the
wrong one. The two absence asserts stay warning only: scoping follows from the
design, but [#73][i73] has not put it in the specification, and until it does no
platform should fail on it.

## What this set does not cover

**Transport beyond the connection itself.** `GUPZ-TR-002`, `GUPZ-TR-003` and
`GUPZ-TR-004` need inspection of the handshake and of the certificates, which a
TestScript does not do, and the refusal half of `GUPZ-TR-001` cannot be produced
by an engine that always presents its certificate. Proposal: check these out of
band on the day, with a TLS scanner against the endpoint and a manual attempt to
connect without a client certificate. That needs a written expectation of what
applies on the day, which is still being decided.

**Token structure.** `GUPZ-TOK-002`, `GUPZ-JWS-001`, `GUPZ-CRY-001` and
`GUPZ-PAY-001` describe what the caller produces. In a server aimed set they can
only be tested indirectly, through acceptance and refusal. Testing them directly
belongs in the client aimed set, where a DVA is under test, and would need a
Groovy rule to inspect the token.

**Key rotation, only partly.** Rotation itself needs two runs with a key change
in between, which is beyond a TestScript. That the platform publishes a JWKS is
not: it is a plain GET and the one half of `GUPZ-JWKS-001` a script can reach.
GUPZ expects JWKS may not be ready by 22 September, with manual exchange as the
fallback.

**Single use of a token.** GUPZ rejected one-time tokens in [#52][i52]: the
fifteen minute lifetime combined with mTLS is considered sufficient. There is no
case to write, and this set may reuse a token across cases.

**Claim obligations.** Settled on 17 August: `provider` is the name to use,
`patient` is mandatory for a patient bound request ([#38][i38]) and `aud` is
mandatory ([#52][i52]). Still open are the separator in `scope` ([#52][i52]) and
the claims for the end user ([#76][i76]). A case on the presence of `aud` or
`patient` can be built once the refusal responses are settled, since that is
what it would assert on.

## What still has to happen

1. Get the key material, so that tokens can be generated on the spot. This is
   the critical path: the scripts run, but without keys they prove nothing.
2. Settle the unsigned token. GUPZ is against supporting one at all, even in a
   test setup, and will raise an issue after discussing it with the front
   runners. Either AUTH-03 inverts into a refusal case or it disappears.
3. Tighten the negative asserts once [#70][i70] closes. Each refusal case now
   only asserts that the response is not 200, with the expected 401 or 403 as a
   warning. Two things have to be settled before those become hard asserts:
   which failure is a 401 and which a 403, and whether the diagnostics switch
   is adopted. The switch would mean every refusal case needs a second expected
   outcome, since GUPZ requires a run with it turned off as well.
4. Arrange the out of band transport check described above. Easier since
   17 August: a G4 certificate is explicitly not required for testing, so what
   has to be agreed is only what does apply on the day.
5. Get the scoping rule into the specification. [#73][i73] states the preference
   to keep the BSN out of request parameters; the obligation that follows from
   it, that the platform limits the response to the patient in the token, is not
   written down. Once it is, the two AUTH-11 absence asserts go from warning to
   hard.
6. Add a case for the JWKS endpoint. `security.md` now puts one on
   `/.well-known/jwks.json` at both ends, and the platform's is a plain GET that
   a script can make. GUPZ expects this may not be ready by 22 September, with
   manual key exchange as the fallback, so the case should be built but should
   not fail anyone on that day.

[sec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[sec-tls]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#transport-level-security
[sec-tlscfg]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-tls-configuratie
[sec-cert]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten
[sec-cert2]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten-1
[sec-token]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#jws-token-inhoud
[sec-tokensec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#token-beveiliging
[sec-medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#medmij-specifieke-eisen-op-het-gebied-van-application-level-security
[sec-rot]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#key-rotation
[sec-invalid]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#afhandeling-van-ongeldige-tokens
[sec-forbidden]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#afhandeling-van-ontbrekende-autorisatie
[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i38]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/38
[i52]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/52
[i76]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/76
[i77]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/77
[rfc2119]: https://www.rfc-editor.org/rfc/rfc2119
[i67]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/67
[i68]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/68
[i69]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/69
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i71]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/71
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73

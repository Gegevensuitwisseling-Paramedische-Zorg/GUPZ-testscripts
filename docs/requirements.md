# Requirements and coverage

What the specification asks, and which test covers it. Identifiers
(`GUPZ-TR-001` and so on) come from the Interoplab requirements inventory for
token and authentication. That inventory is not public yet; every row points at
the section of open-GUPZ it was derived from, which is the authoritative source.
open-GUPZ [#71][i71] is the public index of the open points it produced.

Source is [`security.md`][sec] unless stated otherwise.

## Modality

The Modality column reads the source with the key words of [RFC 2119][rfc2119].
`security.md` does not use them, so each entry is a reading of a Dutch sentence,
and where that reading is uncertain the column says so. The modality decides
what an assert may do.

| Modality | What the assert does |
|---|---|
| MUST, MUST NOT, REQUIRED | Hard assert. A platform that fails it is not conformant |
| SHOULD, RECOMMENDED | `warningOnly` is true. Reports the deviation without failing anyone |
| MAY, OPTIONAL | No assert, or an informational one. There is nothing to be conformant to |
| Unclear | Treated as SHOULD until settled, and an issue is raised |

`GUPZ-TR-002` and `GUPZ-TR-003` are open only because nobody can tell whether
every party has to support every version and every cipher suite, or one of each.
Written with the key words, neither question would exist. Proposed to GUPZ as
[#78][i78], accepted and deferred.

## Requirements

| Id | Requirement | Modality | Source | Tested by |
|---|---|---|---|---|
| GUPZ-TR-001 | Traffic runs over mTLS, both sides authenticate with a certificate | MUST | [Transport level security][sec-tls] | AUTH-01, implicitly. The refusal half is [OP-09](open-points.md#op-09-transport-checks) |
| GUPZ-TR-002 | TLS 1.2 or 1.3, at least NCSC level *Voldoende* | MUST, unclear which version | [TLS configuratie][sec-tlscfg] | [OP-09](open-points.md#op-09-transport-checks) |
| GUPZ-TR-003 | The listed cipher suites are supported | Unclear: all or one | [TLS configuratie][sec-tlscfg] | [OP-09](open-points.md#op-09-transport-checks) |
| GUPZ-TR-004 | PKIoverheid Private G4 certificates on both sides, not required for testing | MUST in production, NOT REQUIRED for testing | [Certificaten][sec-cert] | [OP-09](open-points.md#op-09-transport-checks) |
| GUPZ-TOK-001 | Every call carries `Authorization: Bearer <encrypted token>` | MUST | [Token beveiliging][sec-tokensec] | AUTH-01, AUTH-04, AUTH-05, DVA-01 |
| GUPZ-TOK-002 | Sign then encrypt: JWS inside JWE, JWE header carrying `alg` RSA-OAEP, `enc` A256CBC-HS512, `cty` JWT | MUST | [Token beveiliging][sec-tokensec] | DVA-01 |
| GUPZ-JWS-001 | JWS header carries `alg` `RS256`, `typ` and `kid` | MUST | [JWS token inhoud][sec-token] | Not covered, see below |
| GUPZ-PAY-001 | Payload carries `iat`, `exp` and `iss` | MUST | [JWS token inhoud][sec-token] | Not covered, see below |
| GUPZ-PAY-002 | `aud`, `sub` and `scope` are mandatory; `patient` is mandatory for a patient bound request. `sub` carries the BSN of the patient, the same value as `patient`, or of an authorised representative, or a string for a care provider. `provider`, `nbf` and `jti` are optional | MUST for `aud`, `sub`, `scope`, and `patient` on a patient bound request; the rest OPTIONAL | [JWS token inhoud][sec-token] | Not covered, blocked on [OP-01](open-points.md#op-01-401-against-403) |
| GUPZ-PAY-004 | A token used in a patient bound request is patient specific | MUST | [Application level security][sec-app] | AUTH-11 |
| GUPZ-PAY-005 | The token may bind itself to the client certificate with `cnf.x5t#S256` after RFC 8705 | MAY, expected to become MUST | [JWS token inhoud][sec-token] | Not covered, see below |
| GUPZ-URL-001 | A BSN never appears in a FHIR URL or query parameter | MUST | [Risico analyse][sec-risk] | AUTH-11, DVA-01, and the self link assert in every PDF/A search scenario |
| GUPZ-VAL-001 | The platform decrypts the JWE and validates the JWS signature | MUST | [Token beveiliging][sec-tokensec] | AUTH-01, AUTH-09, AUTH-10 |
| GUPZ-VAL-002 | The platform refuses a request unless `now - iat < 900` and `now < exp`, and validates `iss`. Clock skew is [#77][i77]: Dutch NTP and at most 30 seconds | MUST; clock skew unresolved | [Token beveiliging][sec-tokensec] | AUTH-06, AUTH-07, AUTH-08 |
| GUPZ-CRY-001 | X.509 keys from a trusted CA, RSA-SHA256 for signing, RSA-OAEP with A256CBC-HS512 for encryption | MUST | [Certificaten][sec-cert2] | DVA-01 for the encryption half |
| GUPZ-JWKS-001 | Both sides publish a JWKS on `/.well-known/jwks.json`; the platform refetches on an unknown `kid` | MUST, manual exchange as the fallback for 22 September | [Key rotation][sec-rot] | [OP-10](open-points.md#op-10-jwks) |
| GUPZ-VAL-003 | A refused token is answered with 401, `WWW-Authenticate: Bearer` carrying `error="invalid_token"`, and an OperationOutcome with `severity` error and `code` `login` | MUST, under review | [Ongeldige tokens][sec-invalid] | AUTH-04 to AUTH-10 softly (D-24), DVA-02a from the other side |
| GUPZ-VAL-004 | A request outside the scope in the token is answered with 403, `error="insufficient_scope"` naming the required scope, and an OperationOutcome with `code` `forbidden` | MUST, under review | [Ontbrekende autorisatie][sec-forbidden] | DVA-02b from the other side |
| GUPZ-MED-002 | A DVA fills `scope` with one or more MedMij data service numbers, separated by a space | MUST for a DVA; checking it is a MAY for the platform | [MedMij specifieke eisen][sec-medmij] | Not covered, blocked on [OP-01](open-points.md#op-01-401-against-403) |

## What no TestScript covers

**Transport beyond the connection itself.** See
[OP-09](open-points.md#op-09-transport-checks).

**Token structure, from the server side.** `GUPZ-TOK-002`, `GUPZ-JWS-001`,
`GUPZ-CRY-001` and `GUPZ-PAY-001` describe what the caller produces. A server
aimed set reaches them only indirectly, through acceptance and refusal. The
client aimed Auth set reaches the JWE envelope and nothing inside it, because
Conformancelab holds no decryption key; see
[test-sets.md](test-sets.md#auth-dva).

**Single use of a token.** GUPZ rejected one-time tokens in [#52][i52]: the
fifteen minute lifetime combined with mTLS is considered sufficient. There is
nothing to write, and a token may be reused across cases except where
`GUPZ-PAY-004` requires one per patient.

**The audit trail.** The platform has to log the value of `sub`. A TestScript
sees responses, not logs. Check it by asking a supplier to show a log line next
to a run; connectathon programme rather than script.

**Binding the token to the certificate.** `GUPZ-PAY-005` is a MAY, and it would
need Conformancelab to know the thumbprint of the certificate it presents. Not
testable until that is arranged, not required until the claim becomes mandatory.

**Whether a caller validates the server certificate.** Not visible in a request.
The Proxy records what was presented in the other direction, which is the
closest thing available.

## Cases still to build

1. AUTH-12, the detail switch. Send three different failures in one script, for
   instance a missing header, an unknown issuer and a token encrypted with the
   wrong key, and assert that the returned `diagnostics` are identical. A
   platform that reveals nothing beyond "expired" or "signature failed" cannot
   distinguish those three, so identical text is what switching the detail off
   means. Run in the closed mode only. Blocked on
   [OP-01](open-points.md#op-01-401-against-403). Two mechanics: the comparison
   has to happen inside one script, because a variable reads from an earlier
   response in the same script, and the comparison itself uses the regex chain
   in [authoring.md](authoring.md#reading-a-token).
2. Cases for `sub` and `scope`, mandatory since 18 August 2026. Both assert on a
   refusal, so they wait on the same question.
3. A case for the JWKS endpoint, see [OP-10](open-points.md#op-10-jwks).
4. Tighten the seven refusal cases when [#70][i70] closes: the
   `WWW-Authenticate` header, the `OperationOutcome` code, and the equality of
   `error_description` and `diagnostics`.

[sec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[sec-tls]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#transport-level-security
[sec-tlscfg]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-tls-configuratie
[sec-cert]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten
[sec-cert2]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#eisen-aan-de-te-gebruiken-certificaten-1
[sec-token]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#jws-token-inhoud
[sec-tokensec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#token-beveiliging
[sec-medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#medmij-specifieke-eisen-op-het-gebied-van-application-level-security
[sec-rot]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#key-rotation
[sec-app]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#application-level-security
[sec-risk]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#risico-analyse
[sec-invalid]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#afhandeling-van-ongeldige-tokens
[sec-forbidden]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md#afhandeling-van-ontbrekende-autorisatie
[i52]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/52
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i71]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/71
[i77]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/77
[i78]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/78
[rfc2119]: https://www.rfc-editor.org/rfc/rfc2119

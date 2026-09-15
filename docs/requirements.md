# Requirements and coverage

What the specification asks, and what covers it. Identifiers
(`GUPZ-TR-001` and so on) come from the Interoplab requirements inventory for
token and authentication. That inventory is not public yet; every row points at
the section of open-GUPZ it was derived from, which is the authoritative source.
open-GUPZ [#71][i71] is the public index of the open points it produced.

Source is [`security.md`][sec] unless stated otherwise.

## Two ways to cover a requirement

A TestScript sees a request and a response, and nothing else. What falls outside
that is covered by a Quest, where a participant records what they observed. Two
columns, because the two carry different weight: an assert is evidence, a Quest
answer is a declaration.

| Column | What it names | Weight |
|---|---|---|
| Tested by | the scenarios whose asserts reach the requirement | evidence produced by a run |
| Recorded by | the Quest and the items where the participant records it | a declaration by the participant |

The Quests are generated from `build.py` in the working notes and are not held
in this repository. Three of them appear here:

| Short name | Quest | Who fills it in |
|---|---|---|
| peer-1 | GUPZ Auth, direct test | both parties, per pair and per direction |
| peer-2 | GUPZ PDF/A, direct test | both parties, per pair |
| decl | GUPZ PARIS and document content, declaration | the Dataplatform, once |

Where a row says "recorded and not judged", the specification leaves the point
open, so the Quest asks for the observation and states no requirement. Those
items are open ended or optional.

## Modality

The Modality column reads the source with the key words of [RFC 2119][rfc2119].
`security.md`, `pdfa.md` and `Medmij-pdfa.md` do not use them, so each entry is
a reading of a Dutch sentence, and where that reading is uncertain the column
says so. The modality decides
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

| Id | Requirement | Modality | Source | Tested by | Recorded by |
|---|---|---|---|---|---|
| GUPZ-TR-001 | Traffic runs over mTLS, both sides authenticate with a certificate | MUST | [Transport level security][sec-tls] | AUTH-01, implicitly. The refusal half is [OP-09](open-points.md#op-09-transport-checks) | peer-1 `dva-clientcertificaat`, `dva-servercontrole`, `dp-vraagt-certificaat`, `dp-weigert-zonder-certificaat` |
| GUPZ-TR-002 | TLS 1.2 or 1.3, at least NCSC level *Voldoende* | MUST, unclear which version | [TLS configuratie][sec-tlscfg] | [OP-09](open-points.md#op-09-transport-checks) | peer-1 `dva-tls`, `dp-tls` |
| GUPZ-TR-003 | The listed cipher suites are supported | Unclear: all or one | [TLS configuratie][sec-tlscfg] | [OP-09](open-points.md#op-09-transport-checks) | peer-1 `dva-cipher`, `dp-cipher`, recorded and not judged |
| GUPZ-TR-004 | PKIoverheid Private G4 certificates on both sides, not required for testing | MUST in production, NOT REQUIRED for testing | [Certificaten][sec-cert] | [OP-09](open-points.md#op-09-transport-checks) | peer-1 `dva-certificaat-uitgever`, `dp-certificaat-uitgever` |
| GUPZ-TOK-001 | Every call carries `Authorization: Bearer <encrypted token>` | MUST | [Token beveiliging][sec-tokensec] | AUTH-01, AUTH-04, AUTH-05, DVA-01 | Not recorded. Every script reaches it |
| GUPZ-TOK-002 | Sign then encrypt: JWS inside JWE, JWE header carrying `alg` RSA-OAEP, `enc` A256CBC-HS512, `cty` JWT | MUST | [Token beveiliging][sec-tokensec] | DVA-01 | peer-1 `dva-nested`, `dva-jwe-parameters` |
| GUPZ-JWS-001 | JWS header carries `alg` `RS256`, `typ` and `kid` | MUST | [JWS token inhoud][sec-token] | Not covered, see below | peer-1 `dva-jws-header`, `dp-jws-header` |
| GUPZ-PAY-001 | Payload carries `iat`, `exp` and `iss` | MUST | [JWS token inhoud][sec-token] | Not covered, see below | peer-1 `dva-claims`, `dp-claims-gecontroleerd` |
| GUPZ-PAY-002 | `aud`, `sub` and `scope` are mandatory; `patient` is mandatory for a patient bound request. `sub` carries the BSN of the patient, the same value as `patient`, or of an authorised representative, or a string for a care provider. `provider`, `nbf` and `jti` are optional | MUST for `aud`, `sub`, `scope`, and `patient` on a patient bound request; the rest OPTIONAL | [JWS token inhoud][sec-token] | Not covered; the cases need tokens that do not exist yet, see [OP-05](open-points.md#op-05-key-material) | peer-1 `dva-claims`, `dva-claim-formaat`, `dp-claims-gecontroleerd` |
| GUPZ-PAY-004 | A token used in a patient bound request is patient specific | MUST | [Application level security][sec-app] | AUTH-11 | peer-1 `dva-per-patient` |
| GUPZ-PAY-005 | The token may bind itself to the client certificate with `cnf.x5t#S256` after RFC 8705 | MAY, expected to become MUST | [JWS token inhoud][sec-token] | Not covered, see below | peer-1 `dva-cnf`, `dp-cnf`, recorded and not judged |
| GUPZ-URL-001 | A BSN never appears in a FHIR URL or query parameter | MUST | [Risico analyse][sec-risk] | AUTH-11, DVA-01, and the self link assert in every PDF/A search scenario | peer-1 `dva-geen-bsn-in-url`, `dp-geen-bsn-in-url` |
| GUPZ-VAL-001 | The platform decrypts the JWE and validates the JWS signature | MUST | [Token beveiliging][sec-tokensec] | AUTH-01, AUTH-09, AUTH-10 | peer-1 `dp-ontsleuteld` |
| GUPZ-VAL-002 | The platform refuses a request unless `now - iat < 900` and `now < exp`, and validates `iss`. Clock skew is [#77][i77]: Dutch NTP and at most 30 seconds | MUST; clock skew unresolved | [Token beveiliging][sec-tokensec] | AUTH-06, AUTH-07, AUTH-08 | peer-1 `dp-claims-gecontroleerd`, `dva-per-patient` |
| GUPZ-CRY-001 | X.509 keys from a trusted CA, RSA-SHA256 for signing, RSA-OAEP with A256CBC-HS512 for encryption | MUST | [Certificaten][sec-cert2] | DVA-01 for the encryption half | peer-1 `dva-sleutelmateriaal`, `dp-sleutelmateriaal` |
| GUPZ-JWKS-001 | Both sides publish a JWKS on `/.well-known/jwks.json`; the platform refetches on an unknown `kid` | MUST, manual exchange as the fallback for 22 September | [Key rotation][sec-rot] | [OP-10](open-points.md#op-10-jwks) | peer-1 `dva-sleutels`, `dp-jwks`, `dp-kid-onbekend` |
| GUPZ-VAL-003 | A refused token is answered with 401, `WWW-Authenticate: Bearer` carrying `error="invalid_token"`, and an OperationOutcome with `severity` error and `code` `login` | MUST | [Ongeldige tokens][sec-invalid] | AUTH-04 to AUTH-10 (D-30), DVA-02a from the other side | peer-1 `dp-weigering-401`, `dp-401-detail`, `dp-detail-uitschakelbaar` |
| GUPZ-VAL-004 | A request outside the scope in the token is answered with 403, `error="insufficient_scope"` naming the required scope, and an OperationOutcome with `code` `forbidden` | MUST | [Ontbrekende autorisatie][sec-forbidden] | DVA-02b from the other side; no server aimed case, see [OP-01](open-points.md#op-01-the-challenge-when-no-credentials-are-presented) | peer-1 `dp-scope-beproefd`, `dp-403` |
| GUPZ-MED-002 | A DVA fills `scope` with one or more MedMij data service numbers, separated by a space | MUST for a DVA; checking it is a MAY for the platform | [MedMij specifieke eisen][sec-medmij] | Not covered; the cases need tokens that do not exist yet, see [OP-05](open-points.md#op-05-key-material) | peer-1 `dva-scope-formaat`, `dp-medmij-controle` |

## Documents

Source is [`pdfa.md`][pdfa] unless stated otherwise. These rows carry no
identifier. The inventory covers token and authentication only, so there is
nothing to point at and the section of the specification does the identifying.

| Requirement | Modality | Source | Tested by | Recorded by |
|---|---|---|---|---|
| The platform is an MHD Document Responder for Find Document Reference and Retrieve Document, following MedMij FHIR IG PDF/A 3.0.53 | MUST | [FHIR Implementation Guide][pdfa-ig] | PDF/A 1.1, 1.2, 1.3, 1.5 and 2.1, and 1.4 for the retrieve half | peer-2 `dva-zoeken`, `dva-binary`, `dp-zoeken`, `dp-binary`, `dp-profiel` |
| A request on DocumentManifest is answered with 404 and an OperationOutcome carrying `severity` error and `code` `not-supported` | MUST, and the source contradicts itself, see below | [Afhandeling van DocumentManifest requests][pdfa-dm] | PDF/A 2.2, 2.3 and 2.4 (D-04) | peer-2 `dva-geen-manifest`, `dp-manifest` |
| Every document reference points at a `Binary`, so Retrieve Document queries that `Binary` | MUST | [Document referenties][pdfa-ref] | PDF/A 1.1, 1.4 and 2.1, through the two asserts of D-12 | peer-2 `dva-binary`, `dp-binary` |
| `DocumentReference.status` carries the Nictiz coding | MUST | [Document status][pdfa-status] | PDF/A 1.1 and 2.1 search on `status=current`; the filtering is what 2.1 checks (D-13) | peer-2 `dp-status`, all four statuses |
| A document with GUPZ status Concept is never offered through the PDF/A API | MUST | [Document status][pdfa-status] | Not covered. Absence shows only if the test data holds a Concept document, see [OP-04](open-points.md#op-04-test-data-specification) | decl `status-concept-niet-beschikbaar` |
| A new current version archives the one it replaces, and may point at it with `relatesTo` `replaces` | MUST to archive, MAY for `relatesTo` | [Document status][pdfa-status] | Not covered. It is PARIS behaviour over time and a single run does not show it | decl `status-nieuwe-versie`, and `status-relatesto` recorded and not judged |
| A document that became entered-in-error and was demonstrably never viewed may be deleted | MAY | [Document status][pdfa-status] | No assert. There is nothing to be conformant to | decl `status-foutief-verwijderd`, recorded and not judged |
| Only documents the paramedic generated themselves are made available | MUST | [Medmij-pdfa][mm-own] | Not covered. It decides what the test data holds, not how the interface answers | decl `inhoud-eigen` |
| Every document carries a letterhead identifying the provider and the patient, without the BSN | MUST | [Medmij-pdfa][mm-head] | Not covered by a script. It sits inside the document, so it is a manual check next to the flavour | decl `inhoud-briefhoofd` |
| An empty template field is left out of the generated document | MUST | [Medmij-pdfa][mm-empty] | Not covered. It sits inside the document | decl `template-lege-velden` |
| Every field the templates mark as mandatory can be recorded, and a generated document holds no fields beyond the template | MUST | [Medmij-pdfa][mm-tpl] | Not covered. It sits in the PARIS | decl `template-verplichte-velden`, `template-geen-extra-velden` |
| The PARIS keeps a status out of Concept, Actueel, Gearchiveerd and Foutief for every generated summary, and shows it | MUST | [Medmij-pdfa][mm-status] | Not covered. It sits in the PARIS | decl `status-vier` |
| A change to an underlying dossier field yields a new Concept document and archives the Actueel one resting on the same fields | MUST | [Medmij-pdfa][mm-version] | Not covered. It is PARIS behaviour over time | decl `status-nieuwe-versie` |
| A dossier summary rests on dossier fields alone and is never adjusted by hand | MUST | [Medmij-pdfa][mm-manual] | Not covered. It sits in the PARIS | decl `status-niet-handmatig` |
| The practitioner sees the Actueel version and can open the Concept and Gearchiveerd ones | MUST | [Medmij-pdfa][mm-hist] | Not covered. It is a PARIS screen | decl `status-versiehistorie` |
| A patient under treatment for several diagnoses can hold several Actueel treatment plans at once | MUST | [Medmij-pdfa][mm-parallel] | Not covered. It sits in the PARIS | decl `status-parallelle-plannen` |
| The reference set for procedures is taken up in the templates once delivered | MUST, manner still open | [Medmij-pdfa][mm-refset] | Not covered. Nothing is delivered yet | decl `template-referentiesets`, recorded and not judged |
| Correspondence and messages may be adjusted by hand, are not archived when a dossier field changes, and carry the same statuses as a summary | MUST | [Medmij-pdfa][mm-corr] | Not covered. It sits in the PARIS | decl `corr-onderscheid`, `corr-handmatig`, `corr-niet-gearchiveerd` |
| The documents served are valid PDF/A | MUST; no flavour is named, see below | [Ongestructureerde documenten][pdfa-intro] | Not covered. Conformancelab does not validate PDF/A | decl `inhoud-geldig`, and `inhoud-smaak` recorded and not judged; peer-2 `dva-geldig`, `dva-smaak` |

**`pdfa.md` says two things about DocumentManifest.** The Implementation Guide
section states that the Find Document Manifest transaction is not supported. The
section below it states that support is not mandatory and prescribes the 404 for
a platform that leaves it out. Read strictly the first forbids what the second
permits, and a platform that does answer a manifest request cannot tell which
sentence applies to it. The set asserts the 404, which holds under both readings
(D-04).

**No flavour is named.** `pdfa.md` requires PDF/A and never says which flavour.
The connectathon asks for PDF/A-1b, the imported fixtures are PDF/A-2b, and who
validates which is open-GUPZ [#66][i66]. No TestScript reaches it either way:
Conformancelab does not validate PDF/A.

## What no TestScript covers

Every heading below is covered by a Quest instead. The Quest is a declaration,
not evidence, so a row that rests on one carries less weight than a row with an
assert behind it.

**Transport beyond the connection itself.** See
[OP-09](open-points.md#op-09-transport-checks). Recorded in peer-1: the TLS
version, the certificates presented on both sides, the refusal of a connection
without one, and the cipher suite as an observation.

**Token structure, from the server side.** `GUPZ-TOK-002`, `GUPZ-JWS-001`,
`GUPZ-CRY-001` and `GUPZ-PAY-001` describe what the caller produces. A server
aimed set reaches them only indirectly, through acceptance and refusal. The
client aimed Auth set reaches the JWE envelope and nothing inside it, because
Conformancelab holds no decryption key; see
[test-sets.md](test-sets.md#auth-dva). Recorded in peer-1, from both sides: the
caller declares what it put in the header and the claims, the platform declares
what it read and validated.

**Single use of a token.** GUPZ rejected one-time tokens in [#52][i52]: the
fifteen minute lifetime combined with mTLS is considered sufficient. There is
nothing to write, and a token may be reused across cases except where
`GUPZ-PAY-004` requires one per patient.

**The audit trail.** The platform has to log the value of `sub`. A TestScript
sees responses, not logs. Check it by asking a supplier to show a log line next
to a run; connectathon programme rather than script. Recorded in peer-1 as
`dp-audittrail`, which is optional, because the participant may not have looked.

**Binding the token to the certificate.** `GUPZ-PAY-005` is a MAY, and it would
need Conformancelab to know the thumbprint of the certificate it presents. Not
testable until that is arranged, not required until the claim becomes mandatory.
Recorded in peer-1 as an observation, so the take up is visible before the claim
becomes mandatory.

**What the PARIS does rather than the interface.** `Medmij-pdfa.md` sets out how
a summary comes about: the template a field has to come from, the statuses the
PARIS keeps, the version history a practitioner can open, parallel current
treatment plans per diagnosis, the reference sets, and the rules for
correspondence. None of it is visible in a FHIR response. What reaches the
interface is the result, which documents come back and what status they carry.
All of it is recorded in the declaration Quest, which a Dataplatform fills in
once: it does not depend on which counterparty was connected.

**Whether a caller validates the server certificate.** Not visible in a request.
The Proxy records what was presented in the other direction, which is the
closest thing available. Recorded in peer-1 as `dva-servercontrole`.

**PDF/A itself.** Conformancelab does not validate PDF/A, and no flavour is
named, so neither validity nor flavour can be asserted. Recorded on both sides
in peer-2 and in the declaration Quest, the flavour as an observation.

## Cases still to build

Each of these is recorded in a Quest in the meantime, so the requirement is not
unobserved while the case is missing. A declaration is weaker than an assert,
which is why the case is still worth building.

1. AUTH-12, the detail switch. Send three different failures in one script, for
   instance a missing header, an unknown issuer and a token encrypted with the
   wrong key, and assert that the returned `diagnostics` are identical. A
   platform that reveals nothing beyond "expired" or "signature failed" cannot
   distinguish those three, so identical text is what switching the detail off
   means. Run in the closed mode only. A script cannot put a platform into that
   mode, so the demonstration itself is a manual assert on the connectathon
   programme. See [OP-01](open-points.md#op-01-the-challenge-when-no-credentials-are-presented).
   Two mechanics: the comparison has to happen inside one script, because a
   variable reads from an earlier response in the same script, and the
   comparison itself uses the regex chain in
   [authoring.md](authoring.md#reading-a-token).
2. Cases for `sub` and `scope`, mandatory since 18 August 2026. A missing
   mandatory claim fails token validation, so both assert the refusal of D-30.
   They need two tokens that do not exist yet, see
   [OP-05](open-points.md#op-05-key-material).
3. A case for the JWKS endpoint, see [OP-10](open-points.md#op-10-jwks).
4. A case for a valid token that asks beyond its scope, the only refusal
   `security.md` answers with a 403. It waits on what `scope` means for a caller
   that is not a DVA.
5. A case that a Concept document never comes back. It needs test data holding
   one, which is [OP-04](open-points.md#op-04-test-data-specification).

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
[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[pdfa-ig]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#fhir-implementation-guide
[pdfa-dm]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#afhandeling-van-documentmanifest-requests
[pdfa-ref]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#document-referenties
[pdfa-status]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#document-status
[mm-own]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#alleen-documenten-die-de-paramedicus-zelf-heeft-gegenereerd-worden-aan-het-pgo-beschikbaargesteld
[mm-head]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#iedere-dossiersamenvatting-bevat-een-briefhoofd-met-identificatie-van-de-auteur-en-de-patiënt
[mm-empty]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#niet-ingevulde-velden-worden-niet-opgenomen-in-de-dossiersamenvattingen
[i52]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/52
[i66]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/66
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i71]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/71
[i77]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/77
[i78]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/78
[mm-tpl]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#vastlegging-in-het-paris-voldoet-aan-de-door-de-beroepsgroepen-vastgestelde-document-templates
[mm-status]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#voor-alle-gegenereerde-dossiersamenvattingen-wordt-een-status-bijgehouden
[mm-version]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#een-wijziging-in-een-onderliggend-dossierveld-leidt-altijd-tot-een-nieuwe-versie-van-de-dossiersamenvatting
[mm-manual]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#dossiersamenvattingen-zijn-uitsluitend-gebaseerd-op-dossiervelden-en-worden-nooit-handmatig-aangepast-of-uitgebreid
[mm-hist]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#de-behandelaar-kan-de-versiehistorie-van-een-dossiersamenvatting-inzien
[mm-parallel]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#een-client-kan-meerdere-actuele-behandelplannen-hebben-indien-deze-in-behandeling-is-voor-verschillende-diagnoses
[mm-refset]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#referentiesets-worden-opgenomen-in-de-templates-zodra-deze-opgeleverd-zijn-voor-integratie
[mm-corr]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/requirements/Medmij-pdfa.md#paramedie-specifieke-eisen-ten-voor-het-beschikbaar-stellen-van-correspondentie-en-berichten-via-het-pgo
[pdfa-intro]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md#ongestructureerde-documenten-beschikbaar-stellen-in-pdfa-formaat
[rfc2119]: https://www.rfc-editor.org/rfc/rfc2119

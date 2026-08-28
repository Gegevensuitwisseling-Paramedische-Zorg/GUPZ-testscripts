# Open points

What is not decided, and what a decision would change here. Settled choices are
in [decisions.md](decisions.md).

| Id | Subject | Blocks | Owner |
|---|---|---|---|
| [OP-01](#op-01-401-against-403) | 401 against 403 | seven refusal cases, AUTH-12, the `sub` and `scope` cases | open-GUPZ [#70][i70] |
| [OP-02](#op-02-two-roles-disagree-on-the-document-count) | Two roles disagree on the document count | PDF/A Dataplatform 1.1 | test data specification |
| [OP-03](#op-03-scenario-25) | Scenario 2.5 | nothing; it is out of the set | GUPZ |
| [OP-04](#op-04-test-data-specification) | Test data specification | all three PDF/A sets against a supplier | GUPZ |
| [OP-05](#op-05-key-material) | Key material | every Auth Dataplatform case | GUPZ |
| [OP-06](#op-06-the-unsigned-token) | The unsigned token | AUTH-03 | open-GUPZ [#79][i79] |
| [OP-07](#op-07-pdfa-version) | PDF/A version | the Binary fixtures | open-GUPZ [#66][i66] |
| [OP-08](#op-08-gupz-canonical) | GUPZ canonical | the `url` of every script | GUPZ |
| [OP-09](#op-09-transport-checks) | Transport checks | GUPZ-TR-001 to TR-004 | GUPZ, Interoplab |
| [OP-10](#op-10-jwks) | JWKS | GUPZ-JWKS-001 | open-GUPZ [#27][i27] |
| [OP-11](#op-11-no-assert-validates-against-an-mhd-profile) | No assert validates against an MHD profile | nothing today | this repository |
| [OP-12](#op-12-directory-names-under-inputfsh) | Directory names under `input/fsh` | nothing | this repository |

## OP-01 401 against 403

[`security.md`][security] settles the shape of both refusals: status code,
`WWW-Authenticate` header and `OperationOutcome` code. Not settled is which
failure is a 401 and which a 403; the two lie close together and implementations
differ. Raised on [#70][i70], 18 August 2026.

A second proposal on that issue is a switch: reveal as much as possible in test,
nothing in production. GUPZ can live with it provided the closed mode is tested
too.

Consequence here: the seven refusal cases keep the soft assert of D-24, and
AUTH-12, which tests the switch itself, is not built. Neither is affected by the
mode question otherwise, because the cases assert only what holds in both modes.

| Holds in both modes | Mode dependent |
|---|---|
| HTTP 401 | whether `diagnostics` names the cause |
| `WWW-Authenticate: Bearer` with `error="invalid_token"` | |
| OperationOutcome with `severity` error and `code` `login` | |
| `error_description` and `diagnostics` carry the same value | |

## OP-02 Two roles disagree on the document count

Server aimed scenario 1.1 asserts two current documents for `XXX_Baltus`; client
aimed scenario 1.1 asserts three. Both numbers are right for the interface they
were written for. At Nictiz they never meet, because the server scenarios run
against the supplier's own system and the client scenarios against a simulated
one. Here both run against the same server, so one has to be off by one.

The third document was removed on 21 August 2026 and put back on 25 August,
because the client set has nowhere else to read from. The server aimed set is
the one that carries the discrepancy, since it is meant for a supplier's
platform anyway and reading from ours is a convenience. Do not resolve it by
removing the document again. Resolved properly by OP-04.

## OP-03 Scenario 2.5

Scenario 2.5 serves a document over an ordinary HTTP URL instead of a `Binary`.
A platform implementing [`pdfa.md`][pdfa] cannot pass it (D-01.3), and one that
does pass it is serving documents in a way GUPZ has ruled out. The run of 21
August 2026 confirmed it from the other side: the scenario failed on its control
test, a request without an `Authorization` header, which is worth having and
does not depend on how the document is served.

Three options, none chosen:

1. Drop it. The set then contains only scenarios a conformant platform can pass,
   which matters on a connectathon where a red result should mean something.
2. Keep it. A vendor may support HTTP references in addition to Binary. Cost: a
   scenario permanently red for everyone who follows the specification.
3. Keep only the control test and move it into the Auth set.

Option 3 looks best from here, but it is a scope question for GUPZ. [#61][i61]
decided in favour of 1.4 without saying what should happen to 2.5.

## OP-04 Test data specification

The imported fixtures cannot all be conformant at once. `XXX_Baltus` follows the
GUPZ rule; `XXX_Schulte` deliberately breaks it, because her only current
document, DocumentReference `kwalificatie4`, carries a plain HTTPS URL to a PDF
on the Nictiz website rather than a Binary reference. Nictiz built that patient
for the 2.5 flow. So scenario 2.1 has one red assert (D-12) that says something
about the fixture and nothing about the platform.

Against a supplier the fixtures do not apply at all: the data comes out of their
own PARIS, and `_LoadResources` is not expected to work there
([test-sets.md](test-sets.md#pdfa-_loadresources)). What is needed is a written
specification of the test data every supplier loads. Also resolves OP-02.

## OP-05 Key material

Every Auth Dataplatform case needs a token, generated shortly before a run
because [#69][i69] made explicit that testing should not use static tokens. What
the testers need is therefore key material and claim values, not finished
tokens. GUPZ supplies the PEM files. The recipe is in
[test-sets.md](test-sets.md#tokens-t1-to-t9).

This is the critical path: the scripts run, but without keys they prove nothing.

## OP-06 The unsigned token

The connectathon brief asks for three token variants: plain, signed, and signed
and encrypted. What "plain" means was never written down. Asked which reading
applies, GUPZ answered on 17 August 2026 that it would rather have neither,
because of the known vulnerabilities around `alg: none`. A token is always
signed; dropping the encryption is the concession a test setup gets. Raised by
GUPZ as [#79][i79].

If that holds, AUTH-03 inverts from an acceptance case into a refusal case,
which is the stronger test because it asserts a security property instead of a
configuration. Nothing is changed until the issue lands.

A second gap sits behind it: the requirement that a platform in test mode
accepts a signed only token is written down nowhere. Proposal is that a platform
must be able to demonstrate both settings, as with the diagnostics switch in
OP-01.

## OP-07 PDF/A version

The functional design requires at least PDF/A-1. The `Binary` fixtures under
`_reference` contain real PDFs whose XMP metadata says `pdfaid part=2,
conformance=B`, so PDF/A-2b, which is consistent with "at least PDF/A-1". The
connectathon asks for valid PDF/A-1b, and a PDF/A-2b file is not a valid
PDF/A-1b file. Either the requirement or the test data needs revisiting, and it
has to be clear what a validator will actually check. Conformancelab does not
validate PDF/A. See [#66][i66].

## OP-08 GUPZ canonical

All scripts derive their `url` from `http://gupz.nl/fhir`, chosen on 20 August
2026 as a placeholder (D-10). Replace it once GUPZ names a canonical.

## OP-09 Transport checks

`GUPZ-TR-002`, `GUPZ-TR-003` and `GUPZ-TR-004` need inspection of the handshake
and of the certificates, which a TestScript does not do. The refusal half of
`GUPZ-TR-001` cannot be produced by an engine that always presents its
certificate.

Proposal: check these out of band on the day, with a TLS scanner against the
endpoint and a manual attempt to connect without a client certificate. That
needs a written expectation of what applies on 22 September. Easier since 17
August 2026: a G4 certificate is explicitly not required for testing, so only
what does apply has to be agreed.

The Conformancelab Proxy records per transaction whether a client certificate
was presented and which, in both directions. That is the instrument for the
observable half.

## OP-10 JWKS

[`security.md`][security] puts a JWKS on `/.well-known/jwks.json` at both ends:
the caller publishes signing keys, the platform encryption keys, and the
platform refetches on an unknown `kid`. The platform side is a plain GET that a
script can make, so half of `GUPZ-JWKS-001` is reachable. Rotation itself needs
two runs with a key change in between and is beyond a TestScript.

GUPZ expects this may not be ready by 22 September, with manual key exchange as
the fallback, so the case should be built but should not fail anyone that day.
Stubbing the fetch by the platform would make key selection on `kid` testable;
that is situation 6 in [test-sets.md](test-sets.md#authentication-situations).

## OP-11 No assert validates against an MHD profile

The Test Sets declare `nictiz.fhir.nl.stu3.zib2017` 2.3.2 in `properties.json`,
which records the package the material is written against. It does not make a
response conformant to a profile in it: every `validateProfileId` in the set
points at a base FHIR profile, `Bundle`, `Binary` or `OperationOutcome`, and the
Nictiz canonicals appear only in the `meta.profile` of the fixtures.

So a profile constraint that has to hold for a test to mean anything needs an
assert of its own, the way D-12 adds one. Which constraints those are has not
been worked through.

## OP-12 Directory names under `input/fsh`

`Dataplatform` and `DVA` are the two PDF/A sets, `Auth` and `DVA-Auth` the two
authentication ones, so the same word names a role in one place and a standard
in another. Nothing depends on it: `build.sh` routes on the filename prefix, not
on the directory. Straighten it when the branch is merged.

[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[security]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i61]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/61
[i66]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/66
[i69]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/69
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i79]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/79

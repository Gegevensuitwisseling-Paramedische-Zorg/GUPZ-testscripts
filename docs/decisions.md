# Decisions

Every deliberate choice in this repository, numbered so that other documents can
cite one instead of repeating it. A decision states what holds, the ground it
rests on, and the reference that settles it. Anything not yet decided is in
[open-points.md](open-points.md).

Format: `D-nn` is stable. A decision that is reversed is struck through and
kept, never renumbered.

## Scope

### D-01 Only Find and Retrieve are in scope

The data platform is an MHD Document Responder for ITI-67 Find Document
Reference and ITI-68 Retrieve Document ([`pdfa.md`][pdfa]). Three properties
follow and they decide the whole selection:

1. The platform never receives documents, so ITI-65 Provide Document Bundle is
   out of scope.
2. ITI-66 Find Document Manifest is not supported. The Nictiz IG marks that
   transaction optional, so not supporting it is conformant.
3. Every document reference points at a `Binary` resource, so Retrieve Document
   reads the Binary rather than an external URL.

### D-02 The imported variant is XIS-Server-NoManifest

Chosen over plain `XIS-Server` because of D-01.2. Its DocumentManifest scenarios
do not test that manifests work; they test that a request for one is handled
gracefully. The qualification script foresees this: systems without
DocumentManifest support run the same tests and are expected to receive an error
saying the resource is not supported. Confirmed in [#61][i61].

### D-03 Scenario 1.4 is the retrieve scenario, 2.5 is not in the GUPZ set

The qualification leaves the choice between a `Binary` and an HTTP reference
free; D-01.3 removes that freedom. Agreed with the front runner architects on 18
May 2026, recorded in [#61][i61]. Scenario 2.5 stays in the repository but is
not part of the GUPZ set. Whether it should stay at all is [open-points.md
OP-03](open-points.md#op-03-scenario-25).

### D-04 DocumentManifest scenarios 2.2, 2.3 and 2.4 are kept

Not to test manifests but to test the graceful failure D-01.2 implies.
[`pdfa.md`][pdfa] prescribes 404 with an OperationOutcome carrying `severity`
`error` and `code` `not-supported`, added on request in [#72][i72], and that is
what these three scenarios assert.

### D-05 The roles are Dataplatform and DVA

The imported material calls them `XIS-Server-NoManifest` and `PHR-Client`. The
rename of 14 August 2026 produced `Dataplatform` and `DVA-Client`; the suffix
came off on 27 August. Two grounds: the pair was asymmetric, one name for a
party and one for a party plus its role; and `DVA-Client` reads as either the
DVA in the client role or the client of a DVA, which is the PGO and is not on
this interface. Kickstart asks for the role of the system under test, so the
value names that system and nothing more.

[#74][i74] settles that the generic token profile applies to every caller, a NIS
or a referral platform included, so the role will eventually be the calling
party rather than the DVA. Not renamed now: vagueness costs more today than
precision will cost later.

## Deviations from the imported scripts

Each of these is a difference between a generated script and its Nictiz
original. Everything else compares identical, verified with
`scripts/compare-testscript.py`.

### D-06 Rules use the Conformancelab extension

Nictiz declares rules with the Touchstone extensions `testscript-rule` and
`testscript-assert-rule`. Conformancelab defines `Interoplab-CL-ext-rule` and
`Interoplab-CL-ext-assert-rule`, structurally identical and published in the IG.
The conversion rewrites both URLs. Confirmed by Interoplab, 14 August 2026.

### D-07 The BSN assert is removed, the self link assert is kept

Every imported script asserted `Confirm that Bundle does not use
Burgerservicenummer (BSN) anywhere`. That rule comes from the functional design,
which forbids exchanging the BSN with a PGO, so it belongs to the PGO to DVA
interface. Between DVA and data platform the opposite holds:
[`medmij.md`][medmij] has the BSN travel as the patient identifier and the DVA
filters it out. Applied unchanged the assert rejects conformant behaviour.
Raised as [#80][i80].

The neighbouring assert, that no BSN appears in the self link, is kept and is
now stronger: the self link echoes the request URL, and [#73][i73] settled that
a BSN never appears in a URL or query parameter. It therefore tests
`GUPZ-URL-001`, a GUPZ requirement, rather than a MedMij one.

### D-08 The MedMij tracing headers are not sent

The imported scripts put `MedMij-Request-ID` and `X-Correlation-ID` on every
request, which the MedMij Afsprakenstelsel requires. The data platform is not a
participant in that framework and offers, in the words of [`medmij.md`][medmij],
APIs independent of it. Neither header appears in the specification. Scenario
2.5 still sends them; it is out of the GUPZ set (D-03). Whether GUPZ wants a
correlation id of its own is put to them in [#80][i80], given that the audit
trail has to log `sub`.

### D-09 The system under test is marked with a profile

The imported scripts flag it with `Interoplab-CL-ext-SUT`, a boolean on `origin`
and `destination`. The IG deprecated that on 18 August 2026 in favour of codes
on `origin.profile` and `destination.profile`: `Conformancelab-Client` where
Conformancelab initiates the operations, `Conformancelab-Server` where it
answers them. The system under test is the side without a Conformancelab
profile.

All uses sit in `input/fsh/components/origin-destination.fsh`.

### D-10 The scripts carry GUPZ identity

All scripts declare version `0.1.0`, publisher GUPZ, and derive their `url` from
the canonical `http://gupz.nl/fhir`. The imported scripts named Nictiz as
publisher, pointed their `url` at `nictiz.nl` and declared `stu3-2.0-patchlevel
2026.30` as their version; publishing somebody else's version number invites the
reading that these are the Nictiz qualification scripts.

The canonical is provisional, chosen on 20 August 2026 until GUPZ names
something better. See [open-points.md
OP-08](open-points.md#op-08-gupz-canonical).

### D-11 The token is operator input

Every imported script defaulted its `Authorization` header to a fixed value such
as `Bearer f92b6141-55db-46d5-a3ae-874b69907d22`, a MedMij qualification token
that the Nictiz simulator recognises. A GUPZ data platform expects a JWS nested
in a JWE ([`security.md`][security]), so the imported default cannot work
anywhere.

It is removed rather than replaced: a wrong default runs and fails for a reason
that has nothing to do with the platform under test. What is left is a variable
the operator fills. The `Bearer` prefix moved from the value into the header
template, so what is pasted is the bare token. Mechanics in
[authoring.md](authoring.md#tokens).

Raised as point 3 of [#80][i80], where it was written up as affecting five
client scripts; it affects all eighteen Dataplatform scripts and the loader as
well.

### D-12 Two asserts are added on documents offered as a Binary reference

[`pdfa.md`][pdfa] requires every document reference to point at a `Binary`.
Nothing in the imported set tests it: a platform returning the PDF inline in
`content.attachment.data` passes every other assert, and scenario 1.4 reads
whatever URL the response hands it. The asserts sit in
`components/asserts-gupz.fsh` and run on scenarios 1.1, 1.4 and 2.1.

| Assert | Weight | Ground |
|---|---|---|
| Every attachment has a `url` containing `Binary/` | hard | [`pdfa.md`][pdfa]. Matched on containing, because the reference may be relative or absolute |
| No attachment carries inline `data` | warning | An attachment with both a URL and inline data still offers the document as a reference, so `pdfa.md` does not forbid it in so many words. What forbids it is `IHE.MHD.Minimal.DocumentReference`, a Nictiz profile GUPZ has not adopted. A hard assert would make a Nictiz artefact normative for GUPZ by the back door |

The warning becomes hard if GUPZ confirms that inline data is not allowed.

### D-13 The provisioning set is trimmed

Down from three patients, nine DocumentReference and six Binary resources to two
patients, seven DocumentReference and four Binary resources.

- The five DocumentManifest fixtures are out. No GUPZ scenario reads them; 2.2
  and 2.3 assert a 404 (D-04) and never retrieve a manifest by id. A conformant
  platform refuses these PUTs, so loading them either fails or succeeds where it
  should not have. The files stay under `_reference`, unreferenced, so
  comparison against the Nictiz baseline remains possible.
- `XXX_Ellens` and both his documents are out. He appears in no scenario on
  either side.
- The superseded and entered-in-error documents of `XXX_Schulte` stay on
  purpose. Scenario 2.1 checks that only current documents come back, and that
  check needs something to filter out.

The third document of `XXX_Baltus` was removed on 21 August and put back on 25
August; see [open-points.md
OP-02](open-points.md#op-02-two-roles-disagree-on-the-document-count).

### D-14 The provisioning set keeps its tokens fixed in the script

The tokens resolve through `Configuration/QualificationTokens.json`, which the
engine reads when the repository loads and which maps a token to a patient. Take
the token out of the script and that link breaks. They were briefly turned into
an operator variable, on the reasoning behind D-11, and that was wrong:
Conformancelab does not ask for a token in this set.

The distinction is not an inconsistency. `_LoadResources` writes test data, so a
fixed opaque token there is a label saying which patient a row belongs to, not a
credential under test. Every set that reads from the platform follows D-11.

### D-15 The client side asserts presence and scheme, not a value

The imported scripts assert that `Authorization` equals a MedMij qualification
token. A GUPZ token is minted per run and valid for fifteen minutes, so its
value differs every time. What is stable is that the header exists and uses the
Bearer scheme, and that is what `components/client-asserts.fsh` says. Settles
point 3 of [#80][i80].

### D-16 Client tests allow extra requests

By default the order of requests is fixed and anything in between fails the
operation that was active, which says nothing about conformance. A real client
resolves a reference when it needs to. All five PDF/A DVA scripts set
`Interoplab-CL-ext-test-request-mode` to `extra-allowed`.

## Authoring

### D-17 TestScripts are FSH, everything else is copied

What we author lives in `input/fsh/`; what we import stays verbatim in
`input/static/`. The line is not "TestScripts are FSH", which is why the
provisioning script sits in `input/fsh/` while the fixtures do not.

TestScript resources are R5 even though the material under test is STU3.
Conformancelab only officially supports TestScript R5; the FHIR version of the
material under test is declared in `properties.json`.

### D-18 Fixtures are not written in FSH

Two reasons, both hard:

- SUSHI does not do STU3. `fhirVersion: 3.0.2` yields `The sushi-config.yaml
  must specify a supported version of FHIR. Found 3.0.2.`
- The fixtures are templates, not resources. They carry Conformancelab
  placeholders in typed fields, for example `<indexed value="${DATE, T, D,
  -355}T00:00:00+01:00"/>`. Any tool that type checks rejects that; SUSHI writes
  the resource without the field.

No loss: a fixture is data, not structure. The value of FSH sits in the
TestScripts, where the same seventeen asserts appear in every search scenario.

### D-19 Variable names are unique per case in Auth and shared per patient in PDF/A

Conformancelab spots a variable name occurring in more than one scenario and
offers to fill it once for all of them. In the Auth set that is a trap, because
every case needs a different token, so each case names its variable after
itself. In the PDF/A set the offer is wanted: ten scenarios share one patient's
token and filling it ten times is only a way to make mistakes. Same engine
behaviour, opposite choice.

### D-20 The Auth DVA set prescribes no token

Every other set names a fixed qualification token on the operation, which tells
the caller what to send and lets the server scope its answer to one patient.
Here the caller's own token is the subject, so prescribing one would replace the
thing being judged.

Two consequences. Conformancelab shows the expected request without an
`Authorization` header. And an Automated dry run cannot validate DVA-01: with no
header described the engine sends no token and every assert fails. DVA-02 cannot
be automated either, for a different reason: automation sends only the requests
the engine would send itself, and a stub operation is not one of them. Both need
a real caller.

### D-21 The DVA-02 stubs use the terse error form

[#70][i70] leaves open how much detail `error_description` and `diagnostics` may
carry; in test more is allowed provided a platform can show it switches off. The
stubs use the terse form, the one a platform must be able to produce, because a
caller that copes with a bare `The access token expired` copes with a chattier
variant too. The reverse does not hold.

The other open end of [#70][i70], when a 401 applies and when a 403, does not
need deciding here: each refusal gets its own scenario and a caller has to
handle both.

### D-22 The DVA-02 judgement is manual

[`security.md`][security] says what a platform must return. It says nothing
about what a caller must then do, so asserting anything would invent a
requirement rather than test one. The assert pauses the run and puts the
question to whoever is watching; the answer lands in the report like any other
result.

The assert carries `operator` `manualEval`. An unattended run of this set
therefore never finishes: it waits, which is correct. It needs a real caller and
somebody watching.

The questions are deliberately concrete. After a 401: did the caller report the
failure and stop, rather than repeat the same request with the same token or
fall back to a request without one. After a 403: did it use the `scope`
parameter, which exists precisely so a caller can ask for what it lacks.

### D-23 A `kid` on the JWE header is a warning, not a requirement

`GUPZ-JWS-001` requires a `kid`, but on the JWS header, which is inside the
encryption and unreadable from outside. The JWE header table in
[`security.md`][security] lists only `alg`, `enc` and `cty`. So a `kid` on the
JWE is required by nothing, and failing a caller over it would make a tool's
habit into a rule. It is still reported, because key rotation under [#27][i27]
has the platform resolve its encryption key from a JWKS and a `kid` is how that
lookup finds the right one. Raised in [#75][i75].

### ~~D-24 Negative asserts stay soft until #70 closes~~

Reversed by D-30. [#70][i70] closed on 18 August 2026 and
[`security.md`][security] now settles the shape of a refusal.

### D-30 A refusal is asserted on status, challenge and OperationOutcome

[`security.md`][security] answers a failed token validation with a 401, a
`WWW-Authenticate` header carrying `error="invalid_token"`, and an
OperationOutcome with `severity` error and `code` `login`. All three are
asserted hard. None of them moves with the detail switch of D-21, which only
widens `error_description` and `diagnostics`; neither of those is asserted.

A 403 answers a valid token that asks beyond its scope. Every case in this set
presents a token the platform has to reject, so every case expects a 401. The
open question of when a 403 applies therefore touches no case here.

Two cases present no bearer credentials at all: AUTH-04 sends no header, AUTH-05
sends one that is not a Bearer token. There the error code stays a warning,
because RFC 6750 section 3.1 omits it when a request carries no credentials
while `security.md` prescribes it for every refusal. See
[open-points.md OP-01](open-points.md#op-01-the-challenge-when-no-credentials-are-presented).

### D-26 A stub scenario declares `${STUB-ENDPOINT}` as its destination

A WireMock stub is not served on the FHIR path. Until the IG published section
3.2.1 the address had to be worked out from the base URL, which cost a run to
discover. A `Conformancelab-Server` destination with `url` `${STUB-ENDPOINT}`
resolves to it, so the address comes out of the setup screen instead. Applies to
DVA-02, through the `clientAimedStub` RuleSet.

Not adopted: naming the endpoint with a literal URL carrying
`${ORGANIZATION-ID}`, which is what the neighbouring Nictiz material does. That
puts an environment into the test material; `${STUB-ENDPOINT}` does not.

### D-27 Every destination carries a title

`Interoplab-CL-ext-destination-title` names a destination on the setup screen.
Without it an operator fills in a field that says only "destination". The
imported scripts have none, so this is a deviation from them.

### D-28 Operations use the `Interoplab-CL-operation-type` code system

The imported scripts declare `purge` and `stub` against
`.../CodeSystem/Interoplab-CL-operation-codes`, which the IG does not define.
The IG defines `.../CodeSystem/Interoplab-CL-operation-type`. The engine matches
on the code, so both run, but only one is a defined artefact.

### D-29 Semantic Versioning

The repository follows [Semantic Versioning][semver], read from the position of
a supplier who has already run the material. It stays below 1.0.0 while the
specification itself is still moving; 1.0.0 is cut when the material sits on
`main` and has run against a data platform.

One number is authoritative: `version` in the RuleSet `metadata`, because SUSHI
does not apply the version from `sushi-config.yaml` to an Instance. `build.sh`
refuses to build when the two disagree.

### D-31 The refusal asserts are exercised by a hidden self test

An assert that has never run is an assumption. The three asserts of D-30 were
written against [`security.md`][security] and cannot be exercised against the
FHIR server behind the tests, which accepts every token.

The set answers from stubs and inserts the shipped RuleSet rather than a copy,
so a change to D-30 is picked up without touching it. That rules out the obvious
alternative, a scenario asserting the opposite of D-30. It would be green on a
wrong answer, and it would stop following the requirement the day it changes.

A TestScript cannot say that an assert has to fail, and the engine has no flag
for it either. So the three scenarios built on a wrong answer insert the asserts
as warnings, which do not fail a scenario, and then add a manual assert asking
whether the expected warning appeared. All four then end green when the
material is right, instead of three of them being permanently red, which invites
someone to fix what is not broken.

Next to that sits a hard, automatic assert on what the stub answered: a 403, a
missing challenge, the wrong OperationOutcome code. That is a different claim,
namely that the case is built on a real deviation, and it catches a stub file
that has drifted without anyone reading a warning column. It does not replace
the question to the person: an assert on the answer says nothing about whether
another assert reacted to it.

The cost is one judgement per mutation, and the set already needed a person,
because a stub operation waits for a caller.

`adminOnly` in the properties keeps it out of a supplier's view, which is what
that property is for.

What this set deliberately does not do is relax an assert so that the server
behind the tests passes. A green would then say something about that server
rather than about the specification, and the two red asserts in the PDF/A
Dataplatform set would stop pointing at [OP-04][op04].

### D-25 Everything is in English

Documentation, comments, commit messages and the TestScripts themselves. The
imported material and the Conformancelab IG are English; open-GUPZ keeps its
specifications in Dutch.

[op04]: open-points.md#op-04-test-data-specification
[semver]: https://semver.org/spec/v2.0.0.html
[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[security]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/architecture/medmij.md
[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i61]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/61
[i70]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70
[i72]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/72
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73
[i74]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/74
[i75]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/75
[i80]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/80

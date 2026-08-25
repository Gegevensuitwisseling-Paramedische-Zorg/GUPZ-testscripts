# Which scenarios we run, and why

The PDF/A scripts in this repository come from the MedMij qualification material
published by Nictiz (see [UPSTREAM.md](../UPSTREAM.md) for the exact import).
That set covers more than GUPZ needs, because the Nictiz material combines use
cases that the GUPZ data platform does not all play a part in. This page records
which scenarios are in scope, which are not, and on what grounds. Update it
whenever a decision changes.

**How to read this page.** The Nictiz material is reference material, not law
here. GUPZ aims to stay compatible with the MedMij PDF/A qualification wherever
that is sensible, because the front runners have to pass it, but GUPZ also makes
its own choices and a deliberate deviation is a legitimate outcome. So each row
below separates two things: what the qualification asks, and what GUPZ decided.
Where those differ, the reason is stated.

Sources referenced below:

- open-GUPZ issue [#61 Test scenario's voor MedMij kwalificatie][i61]
- open-GUPZ [`docs/api/pdfa.md`][pdfa] and [`docs/architecture/medmij.md`][medmij]
- Nictiz [functional design PDF/A][fo] and [FHIR IG PDF/A][ig]
- Nictiz qualification scripts [PDF/A Beschikbaarstellen][nb] and
  [PDF/A Ontvangen][no]
- FHIR package [`nictiz.fhir.nl.stu3.zib2017` 2.3.2][pkg], which the Test Sets
  declare in `properties.json`

## Current state

| | |
|---|---|
| Dataplatform | 1.1 through 1.5 and 2.1 through 2.5 built from FSH, twenty TestScripts |
| DVA-Client | 1.1, 1.2, 1.3, 1.4, 2.2 built from FSH, five TestScripts |
| Provisioning | the script that writes the fixtures, built from FSH, one TestScript |
| Removed | Dataplatform 3.1 and 3.2, DVA-Client 2.1, 3.1 and 3.2 |

Every script here is generated from FSH; nothing is imported XML any more. Each
one was compared with its Nictiz original and matches it apart from the
deliberate deviations listed below, so the set can be run as it
stands. Removed scenarios remain available through the tag
`nictiz-baseline-2026.30` and the `nictiz` remote.

## The deciding constraints

Three properties of the GUPZ data platform determine the selection. All three
come from [`pdfa.md`][pdfa].

1. **Only "Find and retrieve existing PDF/A document(s)" is supported.** The
   platform is a Document Responder for ITI-67 Find Document Reference and
   ITI-68 Retrieve Document. It never receives documents, so ITI-65 Provide
   Document Bundle is out.
2. **ITI-66 Find Document Manifest is not supported.** The Nictiz IG marks that
   transaction as optional, so not supporting it is conformant.
3. **Every document reference points at a Binary resource**, so Retrieve
   Document queries the Binary rather than an external URL.

## Server aimed set: Dataplatform

Imported from the Nictiz `XIS-Server-NoManifest` variant. That variant was
chosen over plain `XIS-Server` because of constraint 2: its DocumentManifest
scenarios do not test that manifests work, they test that a request for one is
handled gracefully. The qualification script foresees exactly that, stating that
systems without DocumentManifest support run the same tests and are expected to
receive an error saying the resource is not supported. Reasoning confirmed in
[#61][i61].

| Scenario | What it does | Nictiz qualification | GUPZ | Why |
|---|---|---|:---:|---|
| 1.1 Serve two DocumentReference resources | search `?status=current` | mandatory | yes | Core of Find Document Reference |
| 1.2 Serve zero DocumentReference resources | search on status plus a date range | mandatory | yes | Empty result must still be a valid Bundle |
| 1.3 Serve zero DocumentReference and one OperationOutcome | search with invalid syntax | mandatory | yes | Error handling |
| 1.4 Serve two PDF/A documents | retrieve two Binary resources | optional, but at least one of 1.4 and 2.5 | yes | The qualification leaves the choice between Binary and an HTTP reference free. Constraint 3 removes that freedom for GUPZ, so 1.4 becomes the mandatory retrieve scenario. Agreed with the architects of the front runners on 18 May 2026, recorded in [#61][i61] |
| 1.5 Serve zero Binary resources and one OperationOutcome | retrieve an unknown Binary | mandatory | yes | Error handling on Retrieve Document |
| 2.1 Serve one DocumentReference resource | search returning a single hit | mandatory | yes | Variant of 1.1, second test person |
| 2.2 Serve two DocumentManifest resources | request on DocumentManifest | optional | yes | Kept deliberately. Not to test manifests, but to test the graceful failure that constraint 2 implies |
| 2.3 Serve one DocumentManifest resource | request on DocumentManifest with a date range | optional | yes | Same as 2.2 |
| 2.4 Serve one DocumentReference by resolving a reference from a DocumentManifest | request on DocumentManifest | optional | yes | Same as 2.2 |
| 2.5 Serve one PDF/A document | retrieve through an HTTP reference instead of a Binary | optional, alternative to 1.4 | not required | Replaced by 1.4 because of constraint 3. Kept in the repository but not part of the GUPZ set, and it is an open question whether it belongs here at all; see below |
| 3.1 Receive one document | the server receives a document | belongs to [PDF/A Ontvangen][no] | no | ITI-65. Constraint 1 |
| 3.2 Receive two documents | the server receives two documents | belongs to [PDF/A Ontvangen][no] | no | Same as 3.1 |

Test data used by these scenarios: two fictional persons from the Nictiz
qualification, Ellen XXX_Baltus (fBSN 999910796) with two DocumentReferences and
no manifest, and Eva XXX_Schulte (fBSN 999910784) with two DocumentReferences and
three DocumentManifests. The fixtures live in `_reference/resources`.

## Client aimed set: DVA-Client

Imported from the Nictiz `PHR-Client` scripts. Here the calling party is the
system under test, which in a MedMij context is the DVA. This set is second
priority: the connectathon of 22 September 2026 is about the data platform.

| Scenario | What it does | GUPZ | Why |
|---|---|:---:|---|
| 1.1 Retrieve three DocumentReference resources | search | yes | Mirror image of server 1.1 |
| 1.2 Retrieve zero DocumentReference resources | search without results | yes | Mirror image of server 1.2 |
| 1.3 Retrieve two times one Binary resource | retrieve | yes | Constraint 3 |
| 1.4 Retrieve zero Binary resources | retrieve an unknown Binary | yes | Error handling |
| 2.1 Retrieve two DocumentManifest resources | search on DocumentManifest | no | Constraint 2: a conformant client never issues this request |
| 2.2 Retrieve one DocumentReference resource | search | yes | Variant of 1.1 |
| 3.1 Send one document | the client sends a document | no | ITI-65, constraint 1 |
| 3.2 Send two documents | the client sends two documents | no | ITI-65, constraint 1 |

## What the declared FHIR package says, and what enforces it

The Test Sets declare `nictiz.fhir.nl.stu3.zib2017` 2.3.2 in `properties.json`.
Note what that does and does not do today: the Conformancelab setup guide states
that use of `fhirPackage` has yet to be implemented, so the declaration records
which package the material is written against rather than switching on
validation against it. Where a constraint has to hold for a test to mean
anything, it needs an assert of its own until that changes.

These are the constraints from `IHE.MHD.Minimal.DocumentReference` that the
package carries:

| Element | Constraint | Consequence |
|---|---|---|
| `masterIdentifier` | 1..1 | Every document reference needs a version specific identifier assigned by the source |
| `content` | 0..1 | One document per reference |
| `content.attachment.contentType` | 1..1 | `application/pdf` |
| `content.attachment.url` | 1..1 | A retrievable location is mandatory |
| `content.attachment.data` | 0..0 | The PDF may not be embedded in the DocumentReference. This is the technical basis under constraint 3 |
| `docStatus`, `created`, `custodian` | 0..0 | Removed from the profile |

The `status` search parameter is mandatory in the IG and only takes `current` or
`superseded`.

## Deliberate deviations from the imported scripts

**The Groovy rule uses the Conformancelab extension.** Nictiz declares its rules
with the Touchstone extensions,
`.../StructureDefinition/testscript-rule` on the TestScript and
`.../testscript-assert-rule` on the assert. Conformancelab defines its own,
`Interoplab-CL-ext-rule` and `Interoplab-CL-ext-assert-rule`, which are
structurally identical. On confirmation by Interoplab on 14 August 2026 the
conversion rewrites both urls. Both extensions are published in the IG under
those canonicals, so the rewritten scripts point at defined artefacts.

**The BSN assert that does not apply here is removed.** Every imported script
asserted `Confirm that Bundle does not use Burgerservicenummer (BSN) anywhere`.
That rule comes from the functional design, which forbids exchanging the BSN
with a PGO, so it belongs to the interface between PGO and DVA. Between DVA and
data platform the opposite holds: [`medmij.md`][medmij] has the BSN travel along
as the patient identifier and the DVA filters it out. Applied unchanged the
assert rejects conformant behaviour, so it is gone from the converted scripts.
Raised with GUPZ as [#80][i80]. Scenario 2.5 was the last script still carrying
it; since that scenario was converted on 21 August 2026 the assert is gone from
the whole repository.

The neighbouring assert, that the BSN does not appear in the self link, is
deliberately kept and is now stronger than it was. The self link echoes the
request url, and [#73][i73] settled that a BSN never appears in a url or query
parameter. That assert therefore tests a GUPZ requirement rather than a MedMij
one.

**The MedMij tracing headers are not sent.** The imported scripts put
`MedMij-Request-ID` and `X-Correlation-ID` on every request, which the MedMij
Afsprakenstelsel requires. The data platform is not a participant in that
framework and offers, in the words of [`medmij.md`][medmij], APIs independent of
it. Neither header appears anywhere in the specification. Sending them suggested
an expectation that nothing supports, so they are gone. Whether GUPZ wants a
correlation id of its own is a fair question, given that the audit trail has to
log `sub`, and it has been put to them in [#80][i80].

**The system under test is marked with a profile, not an extension.** The
imported scripts flag it with `Interoplab-CL-ext-SUT`, a boolean on `origin` and
`destination`. The IG deprecated that on 18 August 2026 in favour of codes on
`origin.profile` and `destination.profile`: `Conformancelab-Client` where
Conformancelab initiates the operations, so the `FHIR-Server` opposite it is
under test, and `Conformancelab-Server` where Conformancelab answers them, so
the `FHIR-Client` opposite it is under test. The system under test is now the
side without a Conformancelab profile.

The generated scripts use the new form. The extension still works, so this is a
change we could have postponed, but it was confined to
`input/fsh/components/origin-destination.fsh` and it removes a deprecated
construct before more scripts are written against it. Scenario 2.5, which is
kept exactly as Nictiz wrote it, still carries the extension.

**The scripts carry GUPZ identity, not Nictiz identity.** The imported scripts
name Nictiz as publisher, point their `url` at `nictiz.nl` and declare
`stu3-2.0-patchlevel 2026.30` as their version. They were left that way so the
generated JSON could be compared one to one against the original, but with four
deliberate deviations in place that reason lapsed, and publishing somebody
else's version number invites the reading that these are the Nictiz
qualification scripts. All 37 scripts now say version `0.1.0`, publisher GUPZ,
and derive their url from the canonical `http://gupz.nl/fhir`. That canonical is
provisional, chosen on 20 August 2026 until GUPZ names something better.

**The token is operator input, not a MedMij qualification token.** Every
imported script defaulted its `Authorization` header to a fixed value such as
`Bearer f92b6141-55db-46d5-a3ae-874b69907d22`. That is a MedMij qualification
token: an opaque OAuth token that the Nictiz simulator recognises. A GUPZ data
platform expects something else entirely, a JWS nested inside a JWE as
[`security.md`][security] describes, so the imported default cannot work
anywhere. It is removed rather than replaced. A wrong default runs and fails for
a reason that has nothing to do with the platform under test, which is worse
than no default at all.

What is left is a variable the operator fills in, the same construction the auth
Test Set uses and for the same reason: Conformancelab can sign a JWS but cannot
produce a nested JWT, and it gives no control over the `kid`, so the token is
made outside the engine with `jwtcli` and pasted in. The `Bearer` prefix moved
from the value into the header template, so what is pasted is the bare token.

The scripts already split into two patient groups, `XXX_Baltus` for scenarios
1.1 to 1.5 and `XXX_Schulte` for 2.1 to 2.5, and that split is kept because
[#73][i73] requires a token per patient. So the set takes two tokens, one for
each test patient, and the same search returns different documents depending on
which one is used.

One detail runs against the rule the auth set follows. There the variable names
are unique per case, to stop Conformancelab offering to fill a repeated name
once for all scenarios. Here that offer is wanted: ten scenarios share one
patient's token, and filling it ten times is only a way to make mistakes. Same
engine behaviour, opposite choice, because the sets need opposite things.

Raised with GUPZ as point 3 of [#80][i80], where it was written up as affecting
five DVA-Client scripts. That understated it: the same token sits in all
eighteen Dataplatform scripts and in the loader as well.

These six are the only differences between the generated scripts and their
originals; everything else compares identical.

## Open: does scenario 2.5 belong here at all

Scenario 2.5 serves a document over an ordinary http url instead of through a
Binary resource. It is the alternative to 1.4, and the qualification lets a
vendor pick either one.

GUPZ does not. [`pdfa.md`][pdfa] says the data platform offers every document
reference as a reference to a Binary, which is why 1.4 is the retrieve scenario
here and why the hard assert described below exists. A platform that implements
the specification therefore cannot pass 2.5, and one that does pass it is
serving documents in a way GUPZ has ruled out.

The run of 21 August confirmed this from the other side. Scenario 2.5 failed on
its control test, which sends a request without an `Authorization` header and
expects it to be refused. That control is worth having and does not depend on
how the document is served.

So the choice is threefold and it has not been made.

- **Drop it.** Cleanest reading of the specification. The set then contains only
  scenarios a conformant platform can pass, which matters on a connectathon
  where a red result should mean something.
- **Keep it as it is.** A vendor is free to support http references in addition
  to Binary, and then the scenario says something. The cost is a scenario that
  is permanently red for everyone who follows the specification exactly.
- **Keep only the control test**, the request without an `Authorization` header,
  and move it into the auth set where it belongs. That preserves the part that
  applies to every platform and drops the part that does not.

The third looks best from here, but it is a scope question for GUPZ rather than
an authoring decision, so nothing has been changed. Related: the same question
decided [#61][i61] in favour of 1.4, without saying what should then happen to
2.5.

## An assert that open-GUPZ requires and the imported set does not have

[`pdfa.md`][pdfa] says the data platform offers every document reference as a
reference to a Binary resource, so that Retrieve Document reads the Binary.
Nothing in the imported set tests it. A platform that returns the PDF inline,
base64 encoded in `DocumentReference.content.attachment.data`, passes every
other assert in the Dataplatform set. Scenario 1.4 does read a Binary, but it
reads whatever url the response handed it, so a plain http url gets through
there as well.

Two asserts were added, in `components/asserts-gupz.fsh`, on the scenarios that
return documents: 1.1, 1.4 and 2.1.

The first is hard: every returned attachment has a url and that url contains
`Binary/`. It is matched on containing rather than starting with, because the
reference may be relative or absolute, and scenario 1.4 already resolves both
forms.

The second is warning only, which is a judgement worth recording. An attachment
carrying both a url and inline data still offers the document as a reference, so
the sentence in `pdfa.md` does not forbid it in so many words. What does forbid
it is `IHE.MHD.Minimal.DocumentReference`, which puts `attachment.data` at 0..0,
and that is a Nictiz profile GUPZ has not adopted in its own text. Asserting it
hard would make a Nictiz artefact normative for GUPZ through the back door. If
GUPZ confirms that inline data is not allowed, it becomes a hard assert.

### What this exposes in the test data

Scenario 2.1 now fails on the imported fixtures, and for a reason worth stating
plainly. The only current document of `XXX_Schulte`, DocumentReference
`kwalificatie4`, carries a plain https url to a PDF on the Nictiz website
instead of a Binary reference. Nictiz built that patient for the scenario 2.5
flow, where documents are served over an ordinary url; GUPZ does not allow that
flow, which is why 1.4 is in scope here and 2.5 is not.

So the imported fixtures cannot all be conformant at once: the data for
`XXX_Baltus` follows the GUPZ rule and the data for `XXX_Schulte` deliberately
breaks it. The fix is GUPZ test data rather than a softer assert, and it is one
more reason the test data specification has to be written. Until then scenario
2.1 has one red assert that says something about the fixture and nothing about
the platform.

### What the Nictiz STU3 package does and does not change

Loading the Nictiz STU3 package on the server does not change any of this. Every
`validateProfileId` in the set points at a base FHIR profile, `Bundle`, `Binary`
or `OperationOutcome`; not one assert validates against an MHD profile. The
Nictiz canonicals appear only in the `meta.profile` of the fixtures, so the
package matters when data is loaded and validated, not when a response is
judged. Note also that `fhirPackage` in `properties.json` has yet to be
implemented, so that declaration is documentation rather than working
configuration.


## Client aimed testing: how it actually works

Established on 25 August 2026 from the Conformancelab manuals and, where those
and the IG disagreed, from the engine itself.

**Conformancelab does not answer these requests.** When the system under test
calls the address it is given, the proxy forwards the request to a FHIR server
and returns that answer; the engine watches, matches the request against the
operation that is active, and evaluates the asserts. So no stubs have to be
written for ordinary FHIR traffic. What matters is that the right fixtures are on
the server the proxy forwards to, which is what `_LoadResources` puts there. The
`stub` operation type does exist, but it is a WireMock stub meant to catch a
redirect after a `browser-interaction`, so for flows like OAuth.

**The server behind the proxy scopes its answer to the token.** Established in an
automated run on 25 August: with the `Authorization` header present, a search on
`?status=current` returns only the documents of the patient the token belongs to,
and `Configuration/QualificationTokens.json` is what makes that mapping. Take the
header out of the operation and the scoping disappears with it, because
Conformancelab builds an automated request from the operation description. So the
header stays on every client operation even though its value is never compared.

**The token cannot be compared to a fixed value.** The imported scripts assert
that the `Authorization` header equals a MedMij qualification token. A GUPZ token
is a JWS inside a JWE, minted per run and valid for fifteen minutes, so its value
differs every time. What is stable is that the header is present and uses the
Bearer scheme, and that is what the two asserts in
`components/client-asserts.fsh` now say. `exists` is not an operator in base
FHIR, so it is carried by the Conformancelab extension for additional operators;
`contains` is standard. This settles point 3 of [#80][i80].

Reading the claims out of the token is possible in principle, by chaining the
regex mapper, `assert-input-variable` and the `base64Decode` mapper function, but
for a JWE only the outer header is readable, which holds `alg`, `enc` and `kid`.
That is a separate set and it is not built.

**Extra requests have to be allowed.** By default the order of requests is fixed
and anything in between fails the operation that was active, which says nothing
about conformance. A real client resolves a reference when it needs to, not when
the script says so. All five scripts therefore set the request mode to
`extra-allowed`, which keeps the order of the defined operations but tolerates
requests between them.

**The set can be tried without a real client.** A monitor can mark client tests
as Automated, after which Conformancelab sends the requests the system under test
would have sent. That makes a dry run possible before any supplier connects.

## The _LoadResources set

A third Test Set under PDF/A writes the fixtures to the target server: three
patients, six `Binary` resources and nine `DocumentReference` resources, purged
first and then PUT with client assigned ids. Run it before the Dataplatform set,
or every scenario fails on missing data rather than on behaviour.

The set is generated from FSH like everything else here, in
`input/fsh/LoadResources/` with its building blocks in
`components/provisioning.fsh`. Twelve fixtures, twelve writes and two purges
come down to a handful of parameterised inserts, which matters because this file
gets rewritten wholesale the moment GUPZ has test data of its own.

It is provisioning and not a conformance test, and the difference matters.
[`pdfa.md`][pdfa] describes the data platform as an MHD Document Responder,
which reads; nothing in the specification says a platform accepts writes over
FHIR. So this set works against a reference server that happens to allow them,
which is how a dry run is done, and it is not expected to work against a
supplier's platform. There the test data comes out of their own PARIS, which is
what a test data specification still has to describe.

Two changes were made to the imported version.

**The set is trimmed to what the scenarios need**: two patients, seven
DocumentReference resources and four Binary resources, down from three, nine and
six.

Out went the five DocumentManifest fixtures. No GUPZ scenario reads them.
Scenarios 2.2 and 2.3 search for `DocumentManifest` and assert a 404 with an
OperationOutcome, which is what [#72][i72] settled, and they never retrieve a
manifest by id. A platform that implements the specification refuses these PUTs,
so loading them either fails or, worse, succeeds on a platform that should not
have accepted them. The fixture files themselves are kept under `_reference`,
unreferenced, so the comparison against the Nictiz baseline stays possible.

Out went `XXX_Ellens` and both of his documents, who appear in no scenario on
either side.

The third document of `XXX_Baltus` went out too and came back, which is worth
recording because it exposes something the two role sets disagree about. It was
removed on 21 August because the server aimed scenario 1.1 asserts two current
documents for that patient and was getting three. It was put back on 25 August
because the client aimed scenario 1.1 asserts three, and that set has nowhere
else to read from.

Both numbers are right for the interface they were written for. In the Nictiz
arrangement they never met: the server scenarios run against the supplier's own
system and the client scenarios against a simulated one. Here both run against
the same server, so one of them has to be off by one. It is the server aimed
dry run, because that set is meant for a supplier's platform anyway and reading
from ours is a convenience. One more argument for a test data specification.

What stays, on purpose, are the documents of `XXX_Schulte` that are superseded or
entered-in-error. Scenario 2.1 checks that only current documents come back, and
that check needs something to filter out.

**The three tokens stay fixed in the script.** They were briefly turned into an
operator variable, on the reasoning that applies to every other set here, and
that was wrong. Conformancelab does not ask for a token in this set. The tokens
resolve through `Configuration/QualificationTokens.json`, a file the engine
reads when the repository is loaded, which maps a token to the patient it
belongs to. Take the token out of the script and that link breaks.

That file is now part of this repository, restricted to the three PDF/A patients
and otherwise unchanged from the Nictiz original. See
[Configuration/README.md](../Configuration/README.md).

The distinction is worth stating, because it looks like an inconsistency and is
not. `_LoadResources` writes test data, so a fixed opaque token there is a label
saying which patient this row belongs to, not a credential being tested. Every
set that reads from the data platform takes its token as operator input, because
there the token is the thing under test.

## Where the Nictiz scripts do not simply carry over

These are properties of the imported scripts that need a GUPZ decision. Not all
of them have been decided.

**The response to a DocumentManifest request is specified.** [`pdfa.md`][pdfa]
prescribes 404 with an OperationOutcome carrying `severity` `error` and `code`
`not-supported`. That is what scenarios 2.2, 2.3 and 2.4 already assert, so
those cases test a GUPZ requirement rather than an assumption. Added on request,
see [#72][i72].

**The patient is never named in a request.** Every search here queries on status
and dates, never on a patient identifier: the patient comes from the token.
[#73][i73] closed on 18 August with two rules that make this binding. A BSN never
appears in a FHIR url or query parameter, and a token used in a patient bound
request is patient specific, so a new token is made per patient. The BSN itself
stays in the `patient` claim of the token, which is where the platform resolves
the patient from.

Three rules follow for authoring here:

- A script may not put a BSN in a url or a query parameter, and may not search
  for a patient by any other identifier either.
- A patient reference has to be read out of a response, for instance from
  `DocumentReference.subject`, not constructed.
- A token belongs to exactly one patient, the model AUTH-11 uses.

**`status=current` is already covered.** All Nictiz search scenarios query
`?status=current`, which lines up with the requirement in [`pdfa.md`][pdfa] that
documents with GUPZ status `Concept` are never served. Whether an extra assert is
needed stating that nothing other than `current` comes back is open. Related:
[#64 Mapping GUPZ documentstatussen naar MHD statussen][i64].

**Which PDF/A version applies.** The functional design requires at least
PDF/A-1. The `Binary` fixtures under `_reference` contain real PDFs whose XMP
metadata says `pdfaid part=2, conformance=B`, so PDF/A-2b, which is consistent
with "at least PDF/A-1". The connectathon of 22 September asks for valid
PDF/A-1b, and a PDF/A-2b file is not a valid PDF/A-1b file. So either the
requirement or the test data needs revisiting, and it needs to be clear what a
validator will actually check. Related:
[#66 Afspraak t.a.v. de PDF/A validator][i66].

[i61]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/61
[i64]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/64
[i66]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/66
[i72]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/72
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73
[i80]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/80
[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[security]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/security.md
[medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/architecture/medmij.md
[fo]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/OntwerpPDFA
[ig]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/FHIR_PDFA
[nb]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Beschikbaarstellen
[no]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Ontvangen
[pkg]: https://simplifier.net/packages/nictiz.fhir.nl.stu3.zib2017/2.3.2

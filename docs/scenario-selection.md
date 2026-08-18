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
| Dataplatform | 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4 built from FSH, eighteen TestScripts |
| DVA-Client | 1.1, 1.2, 1.3, 1.4, 2.2 built from FSH, five TestScripts |
| Kept as imported XML | Dataplatform 2.5, because it is optional rather than out of scope |
| Removed | Dataplatform 3.1 and 3.2, DVA-Client 2.1, 3.1 and 3.2 |

Everything converted was compared with its Nictiz original and matches it apart
from the two deliberate deviations listed below, so the set can be run as it
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
| 2.5 Serve one PDF/A document | retrieve through an HTTP reference instead of a Binary | optional, alternative to 1.4 | not required | Replaced by 1.4 because of constraint 3. A vendor is free to support HTTP references as well, so the scenario is kept in the repository but is not part of the GUPZ set |
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

These two are the only differences between the generated scripts and their
originals; everything else compares identical.

## Where the Nictiz scripts do not simply carry over

These are properties of the imported scripts that need a GUPZ decision. Not all
of them have been decided.

**The BSN assert is contested.** Every imported script asserts
`Confirm that Bundle does not use Burgerservicenummer (BSN) anywhere`. That rule
comes from the functional design, which states that the BSN may not be exchanged
with PGOs, and it therefore belongs to the interface between PGO and DVA. On the
interface between DVA and data platform the opposite holds:
[`medmij.md`][medmij] has the BSN travel along as the patient identifier, and the
DVA is the party that filters it out. Applied unchanged, the assert would reject
conformant behaviour of the data platform. In [#61][i61] it was suggested to
filter the BSN between DVA and platform as well, so that the same scripts can be
used and there is double assurance, while acknowledging that this may not be
equally easy for every vendor. **Not decided.**

**The response to a DocumentManifest request is specified.** [`pdfa.md`][pdfa]
prescribes 404 with an OperationOutcome carrying `severity` `error` and `code`
`not-supported`. That is what scenarios 2.2, 2.3 and 2.4 already assert, so
those cases test a GUPZ requirement rather than an assumption. Added on request,
see [#72][i72].

**The patient is never named in a request.** Every search here queries on status
and dates, never on a patient identifier: the patient comes from the token.
[#73][i73] goes further and moves to one token per patient without a BSN at all,
so the BSN disappears from both the query and the claim. Three rules follow for
authoring:

- A script may not search for a patient, by BSN or by any other identifier.
- A patient reference has to be read out of a response, for instance from
  `DocumentReference.subject`, not constructed.
- A token belongs to exactly one patient, the model AUTH-11 already uses.

What the token carries instead of the BSN is not yet written down and overlaps
with `sub` in [#76][i76], so a script can assume nothing about the value, only
about the binding.

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
[i76]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/76
[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/architecture/medmij.md
[fo]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/OntwerpPDFA
[ig]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/FHIR_PDFA
[nb]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Beschikbaarstellen
[no]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Ontvangen
[pkg]: https://simplifier.net/packages/nictiz.fhir.nl.stu3.zib2017/2.3.2

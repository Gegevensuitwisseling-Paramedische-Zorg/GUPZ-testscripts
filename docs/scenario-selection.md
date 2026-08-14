# Which scenarios we run, and why

The PDF/A scripts in this repository come from the MedMij qualification material
published by Nictiz (see [UPSTREAM.md](../UPSTREAM.md) for the exact import).
That set covers more than GUPZ needs, because the Nictiz script combines the
*Beschikbaarstellen* and *Ontvangen* use cases while the GUPZ data platform only
plays one of those roles. This page records which scenarios are in scope, which
are not, and on what grounds. Update it whenever a decision changes.

Sources referenced below:

- open-GUPZ issue [#61 Test scenario's voor MedMij kwalificatie][i61]
- open-GUPZ [`docs/api/pdfa.md`][pdfa] and [`docs/architecture/medmij.md`][medmij]
- Nictiz [PDF/A Beschikbaarstellen][nb] and [PDF/A Ontvangen][no]

## The deciding constraints

Three properties of the GUPZ data platform determine the selection. All three
come from [`pdfa.md`][pdfa].

1. **Only "Find and retrieve existing PDF/A document(s)" is supported.** The
   platform is a Document Responder for the transactions Find Document Reference
   and Retrieve Document. It never receives documents.
2. **The MHD transaction Find Document Manifest is not supported.**
3. **Every document reference points at a Binary resource**, so Retrieve
   Document queries the Binary rather than an external URL.

## Server aimed set: Dataplatform

Imported from the Nictiz `XIS-Server-NoManifest` variant. That variant was
chosen over plain `XIS-Server` because of constraint 2: its DocumentManifest
scenarios do not test that manifests work, they test that a request for one is
handled gracefully. Reasoning confirmed in [#61][i61].

| Scenario | What it does | In scope | Why |
|---|---|:---:|---|
| 1.1 Serve two DocumentReference resources | search `?status=current` | yes | Core of Find Document Reference |
| 1.2 Serve zero DocumentReference resources | search with a date range that matches nothing | yes | Empty result must be a valid empty Bundle |
| 1.3 Serve zero DocumentReference and one OperationOutcome | search with invalid syntax | yes | Error handling; the only converted scenario so far |
| 1.4 Serve two PDF/A documents | retrieve two Binary resources | yes | Constraint 3 makes this the mandatory retrieve scenario. Agreed with the architects of the front runners on 18 May 2026, recorded in [#61][i61] |
| 1.5 Serve zero Binary resources and one OperationOutcome | retrieve an unknown Binary | yes | Error handling on Retrieve Document |
| 2.1 Serve one DocumentReference resource | search returning a single hit | yes | Variant of 1.1 |
| 2.2 Serve two DocumentManifest resources | request on DocumentManifest | yes | Constraint 2. Asserts HTTP 404 with an OperationOutcome |
| 2.3 Serve one DocumentManifest resource | request on DocumentManifest with a date range | yes | Same as 2.2 |
| 2.4 Serve one DocumentReference by resolving a reference from a DocumentManifest | request on DocumentManifest | yes | Same as 2.2 |
| 2.5 Serve one PDF/A document | retrieve a document through an HTTP reference instead of a Binary | optional | Replaced by 1.4 because of constraint 3. Vendors are free to support HTTP references as well, so the scenario is kept but not required. See [#61][i61] |
| 3.1 Receive one document | the server receives a document | no | Comes from [PDF/A Ontvangen][no]. The data platform is only a Document Responder, constraint 1 |
| 3.2 Receive two documents | the server receives two documents | no | Same as 3.1 |

## Client aimed set: DVA-Client

Imported from the Nictiz `PHR-Client` scripts. Here the calling party is the
system under test, which in a MedMij context is the DVA. This set is second
priority: the connectathon of 22 September 2026 is about the data platform.

| Scenario | What it does | In scope | Why |
|---|---|:---:|---|
| 1.1 Retrieve three DocumentReference resources | search | yes | Mirror image of server 1.1 |
| 1.2 Retrieve zero DocumentReference resources | search without results | yes | Mirror image of server 1.2 |
| 1.3 Retrieve two times one Binary resource | retrieve | yes | Constraint 3 |
| 1.4 Retrieve zero Binary resources | retrieve an unknown Binary | yes | Error handling |
| 2.1 Retrieve two DocumentManifest resources | search on DocumentManifest | no | Constraint 2: a conformant client never issues this request |
| 2.2 Retrieve one DocumentReference resource | search | yes | Variant of 1.1 |
| 3.1 Send one document | the client sends a document | no | Constraint 1 |
| 3.2 Send two documents | the client sends two documents | no | Constraint 1 |

## Deviations from the Nictiz scripts

These are properties of the imported scripts that do not simply carry over to
GUPZ. They are recorded here so the reason is not lost; not all of them have
been decided yet.

**The BSN assert is contested.** Every imported script asserts
`Confirm that Bundle does not use Burgerservicenummer (BSN) anywhere`. That rule
belongs to the MedMij interface between PGO and DVA. On the interface between
DVA and data platform the opposite holds: [`medmij.md`][medmij] has the BSN
travel along as the patient identifier, and the DVA is the party that filters it
out. Applied unchanged, the assert would reject conformant behaviour of the data
platform. In [#61][i61] it was suggested to filter the BSN between DVA and
platform as well, so that the same scripts can be used and there is double
assurance, while acknowledging that this may not be equally easy for every
vendor. **Not decided.**

**`status=current` is already covered.** The Nictiz search scenarios all query
`?status=current`, which matches the requirement in [`pdfa.md`][pdfa] that
documents with GUPZ status `Concept` are never served. Whether an additional
assert is needed stating that nothing other than `current` comes back is an open
question. Related: [#64 Mapping GUPZ documentstatussen naar MHD statussen][i64].

**The 404 on DocumentManifest is not specified.** Scenarios 2.2, 2.3 and 2.4
expect HTTP 404 with an OperationOutcome. [`pdfa.md`][pdfa] states that Find
Document Manifest is not supported but does not say how a request for one must
be answered. As long as that is not written down, the assert tests a Nictiz
assumption rather than a GUPZ requirement.

**The fixtures are PDF/A-2b.** The `Binary` fixtures under `_reference` contain
real PDFs whose XMP metadata says `pdfaid part=2, conformance=B`. The
connectathon asks for valid PDF/A-1b. Either the requirement or the test data
needs revisiting. Related: [#66 Afspraak t.a.v. de PDF/A validator][i66].

[i61]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/61
[i64]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/64
[i66]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/66
[pdfa]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/api/pdfa.md
[medmij]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/blob/main/docs/architecture/medmij.md
[nb]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Beschikbaarstellen
[no]: https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/PDFA_Ontvangen

# Provenance of the imported TestScripts

The PDF/A TestScripts in this repository were taken from the qualification
material published by Nictiz. This file records exactly what was imported, so
that our changes can always be separated from the original and so that we can
update from Nictiz or offer changes back to them later.

## What was imported

| Property | Value |
|---|---|
| Source | <https://github.com/Nictiz/Nictiz-testscripts> |
| Path | `output/STU3/PDFA-3-0/MedMij/Cert` |
| Commit | `0b6d8975441ab2a429dc907b55ae6adfb04f0d37` (`main`, 21 July 2026) |
| Release | patchrelease 2026.30 |
| Imported on | 14 August 2026 |
| Size | 64 files, roughly 13 MB |

Imported subdirectories:

- `XIS-Server-NoManifest` - server aimed scripts for servers without support for
  the DocumentManifest resource; this is the variant that applies to GUPZ (see
  open-GUPZ issue #61)
- `PHR-Client` - client aimed scripts
- `_reference` - fixtures (Binary, Bundle, DocumentReference, DocumentManifest,
  Patient) and the Groovy rule `assert_response_queryParamsInSelfLink.groovy`
- `_LoadResources` - provisioning script that loads the fixtures onto a server

Deliberately not imported: the `Test` directory (an exact duplicate of `Cert`)
and the `XIS-Server` and `XIS-Server-Nictiz-intern` variants. Those can still be
retrieved through the remote described below.

## Licence

Nictiz-testscripts carries no licence file. The repository is public and forking
is enabled, but formally all rights are reserved. The CC0 licence of this
repository therefore does **not** apply to the files that originate from Nictiz,
only to the work produced by GUPZ. Agreement with Nictiz on reuse and on
offering changes back is handled by the GUPZ programme.

## Keeping our changes separable

The first commit containing these files is an unmodified copy, tagged
`nictiz-baseline-2026.30`. That means

```
git diff nictiz-baseline-2026.30 HEAD -- output/STU3/PDFA-3-0/
```

always yields precisely the GUPZ changes, which is also the patch that could be
offered to Nictiz. Note that this textual comparison loses its value for every
script that has been converted to FSH, because the generated JSON no longer
resembles the original XML line by line. For those, use
`scripts/compare-testscript.py`, which compares content rather than text.

## What differs from the original

Every difference is deliberate and every one is argued in
[docs/scenario-selection.md](docs/scenario-selection.md). This table is the
index; that document holds the reasoning.

| Change | Affects | Where it is argued |
|---|---|---|
| The Groovy rule is declared with the Conformancelab extension instead of the Touchstone one | all converted scripts | Deliberate deviations |
| The assert that no BSN appears anywhere in the Bundle is removed; it rejects conformant behaviour on this interface | all converted scripts | Deliberate deviations |
| The MedMij tracing headers are no longer sent | all converted scripts | Deliberate deviations |
| The system under test is marked with a profile on `origin` and `destination` instead of the deprecated SUT extension | all converted scripts | Deliberate deviations |
| Version, publisher and `url` carry GUPZ identity instead of Nictiz identity | all 37 scripts | Deliberate deviations |
| The token is operator input; the MedMij qualification token is removed as a default and the `Bearer` prefix moved into the header | all PDF/A Dataplatform scripts and scenario 2.5 | Deliberate deviations |
| Two asserts added: a document is offered as a reference to a Binary, and not inline | scenarios 1.1, 1.4 and 2.1 | An assert open-GUPZ requires |
| The provisioning script is trimmed to what the Dataplatform scenarios need: the DocumentManifest fixtures and the data belonging to the client aimed side are gone, and it is now generated from FSH | `_LoadResources` | The _LoadResources set |
| The token assert on the client side no longer compares to a fixed value; it checks that the header exists and uses the Bearer scheme | the five DVA scripts | Client aimed testing |
| The five client scripts allow extra requests between operations | the five DVA scripts | Client aimed testing |
| `Configuration/QualificationTokens.json` is carried over, restricted to the three PDF/A patients | the whole repository | Configuration/README.md |

Nothing was removed from the set of scenarios: all ten server aimed and all five
client aimed scenarios are present. Which of them GUPZ actually runs, and which
are optional or alternatives, is a separate question that
[docs/scenario-selection.md](docs/scenario-selection.md) answers.

## What is generated and what is copied

Most imported scenarios were converted to FSH, which means we now own them: they
are generated, and a Nictiz update has to be merged into our sources by hand.
The rest sits in `input/static/` and is copied into `output/` by the build.

**The fixtures and the Groovy rule** are still exactly as they came. Data rather
than structure, and not expressible in FSH anyway; see the README. These can be
replaced wholesale when Nictiz publishes a new patch release: drop in the new
file, run the build, done.

**The provisioning script** was converted to FSH on 21 August 2026 and its XML
is gone. It was written by hand rather than run through the generator, because
the generator assumes an `origin`, a `destination` and no `copyright`, none of
which holds there, and it silently drops `setup`. The conversion was verified
with `compare-testscript.py`: every fixture, variable and action matches the
original path for path, and the only differences are the GUPZ identity, an added
title, and the long explanation no longer being repeated on the test.

**Scenario 2.5** was converted on the same day, and with it the last imported
TestScript left the repository. It now carries every deviation the other scripts
carry, including the removal of the BSN assert, which it was the last to hold. A
comparison by content shows exactly one assert missing and the other
twenty-four identical.

Nothing under `input/static/` is a TestScript any more. What is left there is
data and configuration: the fixtures, the Groovy rule and the four Test Set
property files.

## Updating from Nictiz

The source is configured as a read-only remote:

```
git remote add nictiz https://github.com/Nictiz/Nictiz-testscripts.git   # once
git config remote.nictiz.tagOpt --no-tags                                # once
git fetch --no-tags nictiz main
git diff nictiz-baseline-2026.30 nictiz/main -- output/STU3/PDFA-3-0/MedMij/Cert
```

Always fetch without tags. A plain `git fetch` also brings in the Nictiz release
tags, which then look like tags of this repository; a later `git push --tags`
would publish them, along with a large part of the Nictiz history, into this
repository.

Be aware that the `output/` directory at Nictiz is **generated** from
`src/PDFA-3-0/`, where the scripts are written in a DRY form using
`nts:include` macros and where `nts:in-targets` derives the variants
(`#default`, `NoManifest`, `Nictiz-intern`) from a single source file. Nictiz
rewrites the whole output directory on every patch release. Two consequences:

1. Taking over an update is a targeted comparison, not a merge.
2. Changes we want to contribute back to Nictiz belong in their `src/`, not in
   their `output/`.

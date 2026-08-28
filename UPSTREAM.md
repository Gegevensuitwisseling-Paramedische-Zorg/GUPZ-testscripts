# Provenance

The PDF/A TestScripts were taken from the qualification material published by
Nictiz. This file records what was imported, so that our changes stay separable
and so that an update from Nictiz, or a contribution back to them, stays
possible.

## What was imported

| Property | Value |
|---|---|
| Source | <https://github.com/Nictiz/Nictiz-testscripts> |
| Path | `output/STU3/PDFA-3-0/MedMij/Cert` |
| Commit | `0b6d8975441ab2a429dc907b55ae6adfb04f0d37` (`main`, 21 July 2026) |
| Release | patchrelease 2026.30 |
| Imported on | 14 August 2026 |
| Size | 64 files, roughly 13 MB |

Subdirectories:

- `XIS-Server-NoManifest`, server aimed scripts for servers without
  DocumentManifest support. The variant that applies to GUPZ, see decision D-02
- `PHR-Client`, client aimed scripts
- `_reference`, fixtures (Binary, Bundle, DocumentReference, DocumentManifest,
  Patient) and the Groovy rule `assert_response_queryParamsInSelfLink.groovy`
- `_LoadResources`, the provisioning script

Not imported: the `Test` directory, an exact duplicate of `Cert`, and the
`XIS-Server` and `XIS-Server-Nictiz-intern` variants. Retrievable through the
remote below.

## Licence

Nictiz-testscripts carries no licence file. The repository is public and forking
is enabled, but formally all rights are reserved. The CC0 licence of this
repository therefore does **not** apply to the files that originate from Nictiz,
only to the work produced by GUPZ. Agreement with Nictiz on reuse and on
offering changes back is handled by the GUPZ programme.

## Keeping our changes separable

The first commit containing these files is an unmodified copy, tagged
`nictiz-baseline-2026.30`.

```
git diff nictiz-baseline-2026.30 HEAD -- output/STU3/PDFA-3-0/
```

That yields precisely the GUPZ changes, which is also the patch that could be
offered to Nictiz. The textual comparison loses its value for every script
converted to FSH, because the generated JSON no longer resembles the original
XML line by line. For those use `scripts/compare-testscript.py`, which compares
content rather than text.

## What differs from the original

Every difference is deliberate and argued in
[docs/decisions.md](docs/decisions.md). This table is the index.

| Change | Affects | Decision |
|---|---|---|
| Rules are declared with the Conformancelab extension instead of the Touchstone one | all converted scripts | D-06 |
| The assert that no BSN appears anywhere in the Bundle is removed | all converted scripts | D-07 |
| The MedMij tracing headers are no longer sent | all converted scripts | D-08 |
| The system under test is marked with a profile instead of the deprecated SUT extension | all converted scripts | D-09 |
| Version, publisher and `url` carry GUPZ identity | all scripts | D-10 |
| The token is operator input; the MedMij qualification token is gone and the `Bearer` prefix moved into the header | all PDF/A Dataplatform scripts and scenario 2.5 | D-11 |
| Two asserts added: a document is offered as a reference to a Binary, not inline | scenarios 1.1, 1.4, 2.1 | D-12 |
| The provisioning script is trimmed to what the scenarios need, and generated from FSH | `_LoadResources` | D-13 |
| The client side token assert checks presence and scheme instead of a fixed value | the five PDF/A DVA scripts | D-15 |
| The client scripts allow extra requests between operations | the five PDF/A DVA scripts | D-16 |
| `Configuration/QualificationTokens.json` is carried over, restricted to the PDF/A patients | the whole repository | D-14 |

No scenario was removed from the import: all ten server aimed and all five
client aimed scenarios are present. Which of them GUPZ runs is in
[docs/test-sets.md](docs/test-sets.md).

## What is generated and what is copied

Every imported scenario was converted to FSH, so we own them: they are
generated, and a Nictiz update has to be merged into our sources by hand.
Nothing under `input/static/` is a TestScript any more. What is left there is
data and configuration: the fixtures, the Groovy rule, the stub mappings and the
Test Set property files.

The fixtures and the Groovy rule are exactly as they came. Data rather than
structure, and not expressible in FSH (D-18). They can be replaced wholesale
when Nictiz publishes a new patch release: drop in the new file, run the build.

Two conversions are worth recording. The provisioning script was converted on 21
August 2026 by hand, because the generator assumes an `origin`, a `destination`
and no `copyright`, none of which holds there, and it silently drops `setup`.
Every fixture, variable and action matches the original path for path. Scenario
2.5 was converted the same day and now carries every deviation the other scripts
carry, including the removal of the BSN assert, which it was the last to hold;
comparison shows exactly one assert missing and the other twenty-four identical.

## Updating from Nictiz

The source is configured as a read-only remote:

```
git remote add nictiz https://github.com/Nictiz/Nictiz-testscripts.git   # once
git config remote.nictiz.tagOpt --no-tags                                # once
git fetch --no-tags nictiz main
git diff nictiz-baseline-2026.30 nictiz/main -- output/STU3/PDFA-3-0/MedMij/Cert
```

Always fetch without tags. A plain `git fetch` brings in the Nictiz release
tags, which then look like tags of this repository; a later `git push --tags`
would publish them, along with a large part of the Nictiz history.

The `output/` directory at Nictiz is generated from `src/PDFA-3-0/`, where the
scripts are written in a DRY form using `nts:include` macros and where
`nts:in-targets` derives the variants (`#default`, `NoManifest`,
`Nictiz-intern`) from a single source file. Nictiz rewrites the whole output
directory on every patch release. Two consequences:

1. Taking over an update is a targeted comparison, not a merge.
2. Changes we want to contribute back belong in their `src/`, not their
   `output/`.

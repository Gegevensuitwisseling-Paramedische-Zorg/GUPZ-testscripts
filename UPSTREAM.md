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

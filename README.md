# GUPZ-testscripts

FHIR TestScripts for testing the GUPZ data platform on
[Conformancelab](https://fhir.interoplab.eu/ig/), the TestScript engine built by
Interoplab. The first target is the connectathon of 22 September 2026.

## Language

Everything in this repository is written in English: documentation, comments,
commit messages and the TestScripts themselves.

## Authoring in FSH

TestScripts are written in [FHIR Shorthand](https://fshschool.org) and built
with SUSHI. `input/fsh` is the source, `output/` is generated and is what
Conformancelab reads.

```
sushi-config.yaml    SUSHI configuration, FHIR R5, FSHOnly
build.sh             runs sushi build and installs the results into output/
input/fsh/
  aliases.fsh
  components/        reusable RuleSets
  Dataplatform/      one file per scenario, producing the JSON and XML variant
scripts/             helpers, see below
```

Build with `./build.sh`. It runs SUSHI, removes previously generated
`TestScript-*.json` files and installs the new ones into the right Test Set
based on the id of the Instance.

The TestScript resources are **R5**, even though the material under test is
STU3. Those two are independent: Conformancelab only officially supports
TestScript R5. The FHIR version of the material under test is declared in
`properties.json`.

Not part of the build: `_reference/` (fixtures and Groovy rules) and the
`properties.json` files. Those are maintained by hand in `output/`, the same way
Interoplab does it in ntv-testscripts. The fixtures add up to more than 12 MB
and would otherwise be stored in the repository twice.

### Converting the Nictiz scripts

Conversion of the imported XML to FSH is done scenario by scenario.
[GoFSH](https://fshschool.org/docs/gofsh/) is useful as a scaffold:

```
gofsh <directory-with-xml> -t xml-only -u 5.0.0 --indent -o <output-directory>
```

Treat GoFSH as a helper, not as a translator: on these files it demonstrably
drops two things. `stopTestOnFail` disappears entirely, including where the
value is `false` (you will notice, because the element is 1..1 in R5 and SUSHI
refuses to build), and for a `profile` carrying an element id only the id
survives while the canonical is lost (you will not notice). So verify every
converted script against its original:

```
python3 scripts/compare-testscript.py <original.xml> fsh-generated/resources/TestScript-<id>.json
```

That script flattens both sides to path and value and ignores the difference
between a single value and an array, so only real differences in content remain.

## Layout

Conformancelab scans the repository for directories containing a
`properties.json`. Such a directory is a Test Set: a group of TestScripts for
one role within an information standard. The name of the directory above the
Test Set is free; the contents of `properties.json` determine what appears in
the user interface.

```
output/STU3/PDFA-3-0/GUPZ/Test/
  Dataplatform/      server aimed: the data platform is the system under test
  DVA-Client/        client aimed: the calling party is the system under test
  _reference/        fixtures (resources) and Groovy rules
  _LoadResources/    provisioning script that loads the fixtures onto a server
```

TestScripts refer to `../_reference/...`, so a Test Set directory has to stay
exactly one level below `_reference`.

Only the default branch (`main`) is visible to regular users in Conformancelab;
other branches are available to administrators only. Adding this repository to a
Conformancelab instance is arranged through Interoplab.

## Provenance

The PDF/A scripts were imported from the qualification material published by
Nictiz and adapted for GUPZ. See [UPSTREAM.md](UPSTREAM.md) for the exact
source, the commit that was imported, the licensing situation and how to pull in
changes from Nictiz or offer changes back to them.

## About this documentation

The documentation in this repository is written with the help of AI. Every text
is read by a human before it is merged and corrected where needed;
responsibility for the content rests with the authors. If you do find a mistake,
please report it as an issue.

## How we work

Changes go through a branch and a pull request, never straight onto `main`.
Branch name: issue number plus a short description in kebab-case, or `noref-`
when there is no issue.

The licence of this repository (CC0 1.0) covers the work produced by GUPZ, not
the imported Nictiz files.

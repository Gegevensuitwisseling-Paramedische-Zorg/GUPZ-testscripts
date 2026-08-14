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
  Dataplatform/      PDF/A, server aimed. One file per scenario, two variants
  DVA-Client/        PDF/A, client aimed
  Auth/              token and authentication, one file per case
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

### Test sets

Three Test Sets, all of them built.

- **PDF/A Dataplatform** and **PDF/A DVA-Client**, testing the document
  interface from either side. Which scenarios are in scope and why is in
  [docs/scenario-selection.md](docs/scenario-selection.md).
- **Auth Dataplatform**, testing the token and authentication part of the
  interface. The model, with the requirement each case tests and the open
  points that still limit some of them, is in
  [docs/auth-test-design.md](docs/auth-test-design.md).

[docs/auth-situations.md](docs/auth-situations.md) places both in the wider
picture: which authentication situations exist on this interface at all, who is
the system under test in each, and where each situation is described in
open-GUPZ.

Not every imported scenario applies to GUPZ, and not every requirement can be
tested from a TestScript. Both documents record what is in scope, what is not
and on what grounds, with references to the issues and specification sections
the decisions rest on.

### Converting a Nictiz script

Conversion of imported XML to FSH is done with `scripts/nictiz-to-fsh.py`:

```
python3 scripts/nictiz-to-fsh.py <script.xml> > input/fsh/<set>/<name>.fsh
```

It recognises the blocks that are identical across scripts and emits an
`insert` for them, and writes everything else out literally. The FHIRPath
expressions are generated rather than typed, because their backslash escaping
survives three layers of quoting and is easy to get wrong. When it meets an
element it does not handle it stops with an error instead of silently dropping
it.

Then verify the built result against the original, always:

```
python3 scripts/compare-testscript.py <original.xml> fsh-generated/resources/TestScript-<id>.json
```

That script flattens both sides to path and value and ignores the difference
between a single value and an array, so only real differences in content remain.
Only delete the original XML once it reports `IDENTICAL`.

[GoFSH](https://fshschool.org/docs/gofsh/) is the general purpose alternative
and works on these files with `-t xml-only -u 5.0.0`, but it is not lossless
here: it drops `stopTestOnFail` everywhere, including where the value is `false`
(you will notice, because the element is 1..1 in R5 and SUSHI refuses to build),
and for a `profile` carrying an element id it keeps the id and loses the
canonical (you will not notice).

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
output/STU3/Auth/GUPZ/Test/
  Dataplatform/      server aimed: token and authentication behaviour
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

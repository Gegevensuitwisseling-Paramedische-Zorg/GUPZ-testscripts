# Working on the material

How the build works, how to add a fixture and how to convert an imported Nictiz
script. The [README](../README.md) covers what this repository is and what is in
it; this page is for changing it.

## The build

TestScripts are written in [FHIR Shorthand](https://fshschool.org) and built with
SUSHI. Everything else is copied. One command does both:

```
./build.sh
```

**Everything under `output/` is derived.** `./build.sh` empties the directory and
rebuilds it: first it copies `input/static/` over it, then it runs SUSHI and
installs the generated TestScripts into the right Test Set based on the id of
the Instance. Edit anything in `output/` and the next build silently throws your
change away. The directory is committed regardless, because Conformancelab reads
the repository.

`input/static/` holds what is not generated: the `properties.json` files, the
fixtures and the Groovy rule under `_reference/`, the provisioning script, and
the Nictiz scripts that have not been converted. Its layout mirrors `output/`,
so where a file ends up follows from where it sits.

The line between the two directories is not "TestScripts are FSH". It is that
what we author lives in `input/fsh/`, and what we import stays verbatim in
`input/static/`. That is why the provisioning script sits there next to the
fixtures even though it is a TestScript too. See
[UPSTREAM.md](UPSTREAM.md#what-stays-verbatim).

The TestScript resources are **R5**, even though the material under test is
STU3. Those two are independent: Conformancelab only officially supports
TestScript R5. The FHIR version of the material under test is declared in
`properties.json`.

The TestScript resources are **R5**, even though the material under test is
STU3. Those two are independent, and the FHIR version of the material under test
is declared in `properties.json`.

Two checks before committing. `rm -rf output && ./build.sh` has to reproduce
`output/` exactly, and for anything converted from Nictiz the comparison below
has to report `IDENTICAL`.

## Adding or changing a fixture

Fixtures are STU3 resources and they are written by hand, as XML or JSON, in
`input/static/.../_reference/resources/`. They are not written in FSH, for two
reasons that are worth knowing before anyone tries.

SUSHI does not do STU3. Setting `fhirVersion: 3.0.2` produces
`The sushi-config.yaml must specify a supported version of FHIR. Found 3.0.2.`

And the fixtures are templates rather than resources. They contain
Conformancelab placeholders in typed fields, for example
`<indexed value="${DATE, T, D, -355}T00:00:00+01:00"/>`, which the engine
substitutes at runtime. Any tool that type checks rejects that; SUSHI answers
`Cannot assign string value: ${DATE, T, D, -355}. Value does not match element
type: date` and writes the resource without the field. So even a version of
SUSHI that spoke STU3 could not produce these files.

That is not a loss. A fixture is data, not structure: there is no repetition in a
Binary carrying a base64 PDF that a RuleSet could factor out. The value of FSH
sits in the TestScripts, where the same seventeen asserts appear in every search
scenario.

To check a fixture, the HL7 validator does speak STU3:

```
java -jar validator_cli.jar -version 3.0 -ig nictiz.fhir.nl.stu3.zib2017#2.3.2 <file>
```

Expect two kinds of false alarm. The placeholders above are reported as invalid
values, and LOINC display names are reported as wrong when the validator prefers
Dutch. Triage both before concluding anything.

## Converting a Nictiz script

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

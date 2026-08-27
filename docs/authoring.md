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

`input/static/` holds what is not generated: the Test Set properties, the
fixtures and the Groovy rule under `_reference/`, the provisioning script, and
the Nictiz scripts that have not been converted. Its layout mirrors `output/`,
so where a file ends up follows from where it sits.

One file is renamed on the way out. Conformancelab treats every directory that
holds a `properties.json` as a Test Set, and it scans the whole repository, so a
copy under `input/` is picked up as a second Test Set pointing at source files
rather than built ones. The file is therefore called `src-properties.json` in
`input/static/` and the build renames it while copying. Nictiz solved it the
same way. If you add a Test Set, name its properties file `src-properties.json`
and nothing else has to change.

The line between the two directories is not "TestScripts are FSH". It is that
what we author lives in `input/fsh/`, and what we import stays verbatim in
`input/static/`. That is why the provisioning script sits there next to the
fixtures even though it is a TestScript too. See
[UPSTREAM.md](UPSTREAM.md#what-stays-verbatim).

The TestScript resources are **R5**, even though the material under test is
STU3. Those two are independent: Conformancelab only officially supports
TestScript R5. The FHIR version of the material under test is declared in
`properties.json`.

Two checks before committing. `rm -rf output && ./build.sh` has to reproduce
`output/` exactly, and for anything converted from Nictiz the comparison below
has to report `IDENTICAL`.

## Adding or changing a fixture

Fixtures are STU3 resources and they are written by hand, as XML or JSON, in
`input/static/.../_reference/resources/`. They are not written in FSH, for two
reasons that should be understood before anyone tries.

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

**With one exception: `setup` and `teardown` disappear without a word.** They
are listed among the elements the generator knows, so it does not stop, but
nothing writes them out. Nothing has been lost to this so far. Check by hand
whether the source has a `<setup>` or a `<teardown>` before you trust the
output, or fix the generator first. `compare-testscript.py` also catches it,
which is the reason to run it every time.

Two more things the generator assumes: that a script has an `origin` and a
`destination` carrying the SUT extension, and that it has no `copyright`. The
provisioning script breaks all three assumptions, which is why it was written as
FSH by hand instead, in `input/fsh/LoadResources/`. Handwritten FSH is fine as
long as `compare-testscript.py` still says `IDENTICAL` on everything that was
meant to stay the same.

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

## Authoring for the client aimed set

Conformancelab does not answer the requests in a client aimed test. The system
under test calls the address it is given, the proxy forwards the request to a
FHIR server and returns that answer, and the engine watches: it matches the
request against the operation that is active and evaluates the asserts. Three
things follow.

**No stubs for ordinary FHIR traffic.** What decides the answer is the content of
the server the proxy forwards to, which the provisioning set fills, and which
`serverAlias` in `properties.json` names. The `stub` operation type exists for
non-FHIR endpoints, an authorization or token endpoint for instance: the
operation waits for a request and answers from a WireMock mapping held in a
fixture. Nothing on this interface needs one, because a caller here sends a FHIR
request straight away with a token it made itself.

**Assert on the request, not on a fixed token.** `headerField` accepts `exists`
and `notExists`, carried by the Conformancelab extension for additional
operators, and `contains`, which is standard. That is enough to say a token is
present and uses the Bearer scheme. It is not enough to say what is inside it: a
GUPZ token is a JWS inside a JWE, so only the outer header is readable at all,
and reading even that means chaining the regex mapper, `assert-input-variable`
and the `base64Decode` mapper function.

**Allow extra requests.** By default the order of requests is fixed and anything
in between fails the operation that was active, which says nothing about
conformance. `Interoplab-CL-ext-test-request-mode` on `TestScript.test` takes
`default`, `extra-allowed` or `random-order`. Use `extra-allowed` unless there is
a reason not to; a real client resolves a reference when it needs to.

To try a client aimed set without a client, a monitor can mark the tests as
Automated at setup, after which Conformancelab sends the requests itself.

## Which source to follow

Three sources describe what a TestScript may contain, and they serve different
purposes.

The [Interoplab implementation guide](https://fhir.interoplab.eu/ig/) carries the
profile, the extensions and the value sets. That is the contract, so build on it
by default: what is in there is what the platform commits to.

The [Conformancelab manual](https://interoplab.atlassian.net/wiki/spaces/SUP/pages/4085317648)
explains what the platform does with a script at run time, which the guide does
not cover. Two things in it are easy to miss and useful here: `headerField`,
`queryParam` and `path` accept the operators `exists` and `notExists` while
`expression` does not, and `defaultManualCompletion` with the operator
`manualEval` pauses a run until somebody judges the outcome by hand. That last
one is a way to put a check that cannot be automated inside the run rather than
beside it.

A run itself is the third source, and the most direct one. The imported
provisioning script uses the operation code `purge`, which is not in the
published value set and works. Where something like that turns out to be needed,
say so in the script and raise it with Interoplab, so the behaviour a test
depends on ends up in the guide rather than only in a comment here.

## A tidy-up still to do

The directories under `input/fsh/` do not name the four Test Sets consistently.
`Dataplatform` and `DVA` are the two PDF/A sets and `Auth` and `DVA-Auth` the two
authentication ones, so the same word means a role in one place and a standard in
another. Nothing depends on it, because `build.sh` routes on the filename prefix
and not on the directory, but it is worth straightening when the branch is
merged.

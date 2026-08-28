# Authoring

How to change the material. What the repository is and what is in it is in the
[README](../README.md).

## The build

```
./build.sh
```

Everything under `output/` is derived. The build empties the directory, copies
`input/static/` over it, runs SUSHI and installs the generated TestScripts into
the right Test Set based on the id of the Instance. Edit anything in `output/`
and the next build throws the change away. The directory is committed
regardless, because Conformancelab reads the repository.

`input/static/` holds what is not generated: the Test Set properties, the
fixtures and the Groovy rule under `_reference/`, and the stub mappings. Its
layout mirrors `output/`, so where a file ends up follows from where it sits.

A Test Set properties file is called `src-properties.json` in `input/static/`
and the build renames it, because Conformancelab treats every directory holding
a `properties.json` as a Test Set and scans the whole repository. Add a Test
Set, name its properties file `src-properties.json`, and nothing else has to
change.

Two checks before committing:

1. `rm -rf output && ./build.sh` reproduces `output/` exactly.
2. For anything converted from Nictiz, `compare-testscript.py` reports
   `IDENTICAL`.

## Adding or changing a fixture

Fixtures are STU3 resources, written by hand as XML or JSON in
`input/static/.../_reference/resources/`. Not in FSH, see D-18.

To check one, the HL7 validator does speak STU3:

```
java -jar validator_cli.jar -version 3.0 -ig nictiz.fhir.nl.stu3.zib2017#2.3.2 <file>
```

Expect two false alarms: the Conformancelab placeholders are reported as invalid
values, and LOINC display names are reported as wrong when the validator prefers
Dutch. Triage both before concluding anything.

## Converting a Nictiz script

```
python3 scripts/nictiz-to-fsh.py <script.xml> > input/fsh/<set>/<name>.fsh
```

The generator recognises the blocks that are identical across scripts and emits
an `insert` for them, and writes everything else out literally. FHIRPath
expressions are generated rather than typed, because their backslash escaping
survives three layers of quoting. When it meets an element it does not handle it
stops with an error rather than dropping it.

Three things to know before trusting the output:

- **`setup` and `teardown` disappear without a word.** They are listed among the
  elements the generator knows, so it does not stop, but nothing writes them
  out. Check by hand whether the source has either, or fix the generator.
- **It assumes an `origin` and a `destination` carrying the SUT extension, and
  no `copyright`.** The provisioning script breaks all three assumptions, which
  is why it was written as FSH by hand.
- **Handwritten FSH is fine** as long as the comparison below still says
  `IDENTICAL` for everything meant to stay the same.

Then verify, always:

```
python3 scripts/compare-testscript.py <original.xml> fsh-generated/resources/TestScript-<id>.json
```

The script flattens both sides to path and value and ignores the difference
between a single value and an array, so only real differences in content remain.
Delete the original XML only once it reports `IDENTICAL`.

[GoFSH][gofsh] is the general purpose alternative and works on these files with
`-t xml-only -u 5.0.0`, but it is not lossless here: it drops `stopTestOnFail`
everywhere, including where the value is `false` (you notice, because the
element is 1..1 in R5 and SUSHI refuses to build), and for a `profile` carrying
an element id it keeps the id and loses the canonical (you do not notice).

## Writing a TestScript

What a script here relies on. The extensions named below are published in the
[Interoplab implementation guide][ig]; the manual describes how a run behaves.

### Test Sets

A directory holding a `properties.json` is a Test Set: a group of TestScripts
for one role within an information standard. The name of the directory above it
is free. TestScripts refer to `../_reference/...`, so a Test Set directory stays
exactly one level below `_reference`.

`serverAlias` in `properties.json` names the FHIR server behind the proxy. For
GUPZ that is `gupz`, which is also the server the client aimed sets read from
and the one `_LoadResources` writes to, so provisioning from any branch moves
the data for every branch.

Only the default branch is visible to regular users; other branches are
available to administrators. The default branch is set in the repository
configuration and does not have to be `main`.

### Server aimed sets

Conformancelab sends the requests and the platform under test answers. It
presents a client certificate configured per instance, not per TestScript, so
every case that succeeds also shows that an mTLS connection was established. The
other half of that requirement is
[OP-09](open-points.md#op-09-transport-checks).

### Client aimed sets

The system under test calls the address it is given, the proxy forwards the
request to the FHIR server and returns that answer, and the run matches the
request against the operation that is active. Four consequences for authoring:

- **No stubs for ordinary FHIR traffic.** What decides the answer is the content
  of the server the proxy forwards to, which `_LoadResources` fills.
- **Keep the `Authorization` header on the operation**, even though its value is
  never compared (D-15). The header is what scopes the answer to one patient,
  and an Automated run builds its request from the operation description.
- **Set the request mode to `extra-allowed`.** Under the default,
  `Interoplab-CL-ext-test-request-mode` fails the active operation on anything
  sent in between, which says nothing about conformance (D-16).
- **A set can be tried without a client.** A monitor or admin can mark client
  tests as Automated. That does not work for Auth DVA, which prescribes no token
  (D-20).

### Where a request goes

| Traffic | Address |
|---|---|
| FHIR request | `/q/<organization id>/<usecase>/<version>/fhir` |
| Stub | `/cl/<organization id>/` |

Only a request arriving at the second address is answered from a WireMock
mapping. Both are on the same host and share the organization id, so one base
URL yields the other; `tools/dva-sim` derives it and shows it before sending.

### Reading a token

Three extensions in a chain:

1. A variable with `headerField` `Authorization` and a `sourceId` pointing at
   the operation's `requestId`, carrying
   `Interoplab-CL-ext-variable-regex-mapper` with the pattern `(?<=Bearer
   )[A-Za-z0-9_-]+`. The lookbehind skips the scheme; the character class stops
   at the first dot, so the match is the first segment of the compact
   serialization, which is the protected header.
2. An assert carrying `Interoplab-CL-ext-assert-input-variable` with that
   variable's name and `Interoplab-CL-ext-assert-mapper-function`
   `base64Decode`.
3. `Interoplab-CL-ext-assert-regex-matches` on the assert's `value`, so the
   check is a pattern and not an exact string. `"alg"\s*:\s*"RSA-OAEP"`
   tolerates the whitespace a serialiser may or may not add.

The regex mapper keeps only the first full match and does not support capture
groups, so a segment has to be isolated with lookaround. For a JWE only the
protected header is readable; the claims need the private key. A second variable
holds the whole token, `(?<=Bearer ).*$`, to count the segments.

Mapper functions: `length`, `urlDecode`, `urlEncode`, `base64Decode`,
`base64Encode`.

### Asserts

- `headerField`, `queryParam` and `path` accept `exists` and `notExists`,
  carried by `Interoplab-CL-ext-assert-additional-operators`; `expression` does
  not. `contains` is standard.
- The operator `manualEval` pauses a run until somebody judges the outcome by
  hand, and the answer lands in the report like any other result (D-22).
- Groovy rules are the fallback for what an assert cannot express, with access
  to request, response and FHIRPath. Declared with `Interoplab-CL-ext-rule` and
  `Interoplab-CL-ext-assert-rule` (D-06).

### Tokens

A token cannot be minted in a run, so every set that reads from the data
platform takes it as operator input: a variable with no default, sent as
`Authorization: Bearer ${auth-01-token}` and filled in when the run is set up
(D-11). Variable naming follows D-19.

## Writing

Documentation here is written as a specification, not as an account of how it
came about.

- A heading names a subject. It is not a claim, a question or a sentence.
- State what holds. Put the ground on one line, or cite a decision by its
  number.
- Use the key words of [RFC 2119][rfc2119] where something is normative.
- Anything enumerable becomes a table.
- No dates in running text unless the date is the fact. Git carries the history.
- No sentences about the document itself.
- Wrap at 80 characters. Not headings, not tables, not links.
- English throughout, including commit messages (D-25).

Where a document belongs:

| Content | File |
|---|---|
| What a set tests, which scenarios and cases | [test-sets.md](test-sets.md) |
| A requirement and what covers it | [requirements.md](requirements.md) |
| Why something is the way it is | [decisions.md](decisions.md) |
| What is not decided | [open-points.md](open-points.md) |
| What was imported and how to update it | [../UPSTREAM.md](../UPSTREAM.md) |

[gofsh]: https://fshschool.org/docs/gofsh/
[ig]: https://fhir.interoplab.eu/ig/
[rfc2119]: https://www.rfc-editor.org/rfc/rfc2119

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
| What the engine does | [conformancelab.md](conformancelab.md) |
| What was imported and how to update it | [../UPSTREAM.md](../UPSTREAM.md) |

[gofsh]: https://fshschool.org/docs/gofsh/
[rfc2119]: https://www.rfc-editor.org/rfc/rfc2119

# GUPZ-testscripts

Test specification, TestScripts and fixtures that test a data platform, and the
party calling it, against the [open-GUPZ][opengupz] specification.

The scripts are FHIR TestScript resources and need an engine that runs them, in
this case Conformancelab.

## Test sets

| Test Set | What it tests |
|---|---|
| PDF/A Data platform | The document interface of the data platform |
| PDF/A DVA | The document interface of the calling party |
| PDF/A _LoadResources | Provisioning, run this one first |
| Auth Data platform | How the data platform handles a token |
| Auth DVA | The token the calling party produces |

Scenarios and cases: [docs/test-sets.md](docs/test-sets.md). That file also
describes three self test sets, for an admin to run: they check the asserts of
this repository against stubbed answers instead of a real system, and
`adminOnly` hides them from everyone else.

## Layout

```
sushi-config.yaml    SUSHI configuration, FHIR R5, FSHOnly
build.sh             builds output/ from input/
input/
  fsh/               TestScripts in FSH
    aliases.fsh
    components/      reusable RuleSets
    Dataplatform/    PDF/A, server aimed
    DVA/             PDF/A, client aimed
    Auth/            token and authentication, server aimed
    DVA-Auth/        token and authentication, client aimed
    LoadResources/   the script that writes the fixtures to a server
    SelfTest/        the self test sets, adminOnly
  static/            copied as is, mirroring the output tree
Configuration/       token map the engine reads when the repository loads
output/              generated, and what Conformancelab reads
scripts/             conversion and comparison helpers
```

`output/` comes from `./build.sh`. Do not edit it; the next build overwrites it.

## Documentation

| File | Content |
|---|---|
| [docs/test-sets.md](docs/test-sets.md) | What each set tests, which scenarios and cases |
| [docs/requirements.md](docs/requirements.md) | Every requirement and what covers it |
| [docs/decisions.md](docs/decisions.md) | Every deliberate choice |
| [docs/open-points.md](docs/open-points.md) | What is not decided yet |
| [docs/authoring.md](docs/authoring.md) | Build, fixtures, conversion |
| [UPSTREAM.md](UPSTREAM.md) | What was imported from Nictiz, and how to update it |
| [CHANGELOG.md](CHANGELOG.md) | What changed per release |

## Versions

[Semantic Versioning][semver]. Every TestScript carries the repository version,
so a run shows which release it came from. See [D-29][d29] and
[authoring.md][releasing].

## How we work

Work on a branch and open a pull request; nothing goes straight onto the default
branch. Branch name: issue number plus a short description in kebab-case, or
`noref-` when there is no issue.

CC0 1.0 covers what GUPZ made, not the files imported from Nictiz. See
[UPSTREAM.md](UPSTREAM.md).

[semver]: https://semver.org/spec/v2.0.0.html
[d29]: docs/decisions.md#d-29-semantic-versioning
[releasing]: docs/authoring.md#releasing
[opengupz]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ

# GUPZ-testscripts

FHIR TestScript resources and fixtures for conformance testing against the
[open-GUPZ][opengupz] specification. Two interfaces are covered, the MHD
document interface and the token and authentication behaviour, each from both
sides: the data platform that answers, and the party that calls it. The material
under test is STU3; the TestScript resources themselves are R5.

Written against open-GUPZ commit `0a273ae`. The first target is the connectathon
of 22 September 2026.

## Where the material is

`main` carries this page and the licence. All TestScripts, fixtures and
documentation are on `noref-import-nictiz-and-set-up-fsh`, open as [PR #1][pr1].
Conformancelab loads the material from that branch. It merges into `main` once
the material has run against a data platform.

## Test sets

Thirty-nine TestScripts in five Test Sets.

| Test Set | Aim | System under test | Scripts |
|---|---|---|---|
| PDF/A Dataplatform | Document interface | Data platform | 20 |
| PDF/A DVA | Document interface | Calling party | 5 |
| PDF/A _LoadResources | Provisioning, run it first | none | 1 |
| Auth Dataplatform | Token and authentication | Data platform | 11 |
| Auth DVA | Token and authentication | Calling party | 2 |

## Tokens

The nested JWT that open-GUPZ prescribes is produced outside the test engine,
with the `jwtcli` tool in open-GUPZ, and pasted in. A token used in a patient
bound request is patient specific, so a set that reads two patients takes two
tokens.

| Set | Token source |
|---|---|
| PDF/A Dataplatform | operator input, one per test patient (two) |
| Auth Dataplatform | operator input, one per case |
| PDF/A DVA | sent by the system under test, fixed value, selects the patient |
| Auth DVA | sent by the system under test, and is itself the subject |
| PDF/A _LoadResources | fixed in the script, resolved through `Configuration/` |

## Documentation

On the working branch.

| File | Content |
|---|---|
| [test-sets.md][d-sets] | What each set tests, which scenarios and cases |
| [requirements.md][d-req] | Every requirement and what covers it |
| [decisions.md][d-dec] | Every deliberate choice, numbered |
| [open-points.md][d-open] | What is not decided, and what it blocks |
| [authoring.md][d-auth] | Build, fixtures, conversion, writing a script |
| [UPSTREAM.md][d-up] | What was imported from Nictiz and how to update it |
| [CHANGELOG.md][d-log] | What changed per release |

## Versions

[Semantic Versioning][semver]. Every TestScript carries the repository version,
so a run shows which release produced a verdict.

## Conventions

English throughout, including commit messages. Changes go through a branch and a
pull request, never straight onto the default branch. Branch name: issue number
plus a short description in kebab-case, or `noref-` when there is no issue.

Documentation is written with the help of AI and read by a human before it is
merged; responsibility for the content rests with the authors. Report a mistake
as an issue.

## Licence

CC0 1.0 covers the work produced by GUPZ. Files derived from Nictiz material are
not covered by it; [UPSTREAM.md][d-up] on the working branch records what was
imported and under which terms.

[opengupz]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ
[pr1]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/pull/1
[semver]: https://semver.org/spec/v2.0.0.html
[d-sets]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/docs/test-sets.md
[d-req]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/docs/requirements.md
[d-dec]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/docs/decisions.md
[d-open]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/docs/open-points.md
[d-auth]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/docs/authoring.md
[d-up]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/UPSTREAM.md
[d-log]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/blob/noref-import-nictiz-and-set-up-fsh/CHANGELOG.md

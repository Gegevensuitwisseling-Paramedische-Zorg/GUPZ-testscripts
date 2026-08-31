# Changelog

All notable changes to this repository are documented here. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and
[Common Changelog](https://common-changelog.org/), and this repository adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Every release names the open-GUPZ version it was written against. See
[decisions.md D-29][d29].

## Unreleased

### Changed

- A refused token is now asserted on the status, the `WWW-Authenticate`
  challenge and the `OperationOutcome`, instead of only on the request having
  failed. open-GUPZ [#70](https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/70)
  closed and `security.md` settles all three.

### Added

- Five Test Sets with 39 TestScripts: the MHD document interface and the token
  and authentication behaviour, each from both sides of the interface, plus the
  script that provisions the fixtures.
- Documentation in `docs/`: test sets, requirement coverage, decisions, open
  points and authoring.

Tested against: open-GUPZ `0a273ae`.

[d29]: docs/decisions.md#d-29-semantic-versioning

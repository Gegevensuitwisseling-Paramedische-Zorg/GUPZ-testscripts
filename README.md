# GUPZ-testscripts

FHIR TestScript resources and fixtures that test the GUPZ data platform against
the [open-GUPZ][opengupz] specification. Both sides of the interface are
covered: the platform that answers, and the party that calls it.

## Where the material is

`main` holds this page and the licence, nothing else. All TestScripts, fixtures
and documentation live on `noref-import-nictiz-and-set-up-fsh`, open as
[PR #1][pr1]. Conformancelab loads the material from that branch. It merges into
`main` once the material has run against a data platform.

| Test Set | Aim | System under test |
|---|---|---|
| PDF/A Dataplatform | Document interface | Data platform |
| PDF/A DVA | Document interface | Calling party |
| Auth Dataplatform | Token and authentication | Data platform |
| Auth DVA | Token and authentication | Calling party |

The engine is [Conformancelab][cl], built by Interoplab. The first target is the
connectathon of 22 September 2026.

## Licence

CC0 1.0 covers the work produced by GUPZ. Material derived from Nictiz is marked
in `UPSTREAM.md` on the branch and is not covered by it.

[opengupz]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ
[pr1]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/GUPZ-testscripts/pull/1
[cl]: https://fhir.interoplab.eu/ig/

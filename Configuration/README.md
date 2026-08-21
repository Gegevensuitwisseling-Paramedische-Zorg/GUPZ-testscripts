# Configuration

Picked up by Conformancelab when the repository is loaded.

## QualificationTokens.json

Maps an access token to the test patient it belongs to. The structure is taken
from the Nictiz material, restricted to the two patients that GUPZ actually uses;
the entries for the other information standards, and the one for XXX_Ellens, are
left out. Ellens appears in no scenario on either side and is no longer loaded.

**The tokens themselves are new and must stay different from the Nictiz ones.**
Reusing theirs would mean two entries claiming the same token on an engine that
holds both sets, and the resolution would depend on which one happened to be
loaded. The patients they point at are still the Nictiz ones, with Nictiz
resource ids and BSNs, because the fixtures are; the token is the only part that
had to change.

This is the mechanism the provisioning script in `_LoadResources` relies on. Its
tokens are fixed in the script and are resolved here, which is why that one set
does not take its token as operator input the way every other set does. The
distinction is deliberate: `_LoadResources` writes test data and is not a
conformance test, so a fixed opaque token there is a label rather than a
credential.

Nothing in the GUPZ token model comes through this file. A GUPZ token is a JWS
inside a JWE, it is minted per run and it is valid for fifteen minutes, so it
cannot live in a file that is committed. Every set that tests the data platform
therefore takes its token as operator input. See
[docs/scenario-selection.md](../docs/scenario-selection.md).

`qualificationScript` reads `GUPZ PDF/A`, matching the information standard in
`properties.json`. The engine does nothing with it, so it is a label for whoever
opens this file.

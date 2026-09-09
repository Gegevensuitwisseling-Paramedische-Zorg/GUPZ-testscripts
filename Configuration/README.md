# Configuration

Read by Conformancelab when the repository is loaded.

## QualificationTokens.json

Maps an access token to the test patient it belongs to. The structure comes from
the Nictiz material, restricted to the two patients GUPZ uses; the entries for
other information standards, and the one for XXX_Ellens, are left out.

**The tokens themselves are new and must stay different from the Nictiz ones.**
Reusing theirs would mean two entries claiming the same token on an engine that
holds both sets, and resolution would depend on which was loaded last. The
patients they point at are still the Nictiz ones, with Nictiz resource ids and
BSNs, because the fixtures are.

This is the mechanism `_LoadResources` relies on, and the reason that one set
keeps its tokens fixed in the script while every other set takes the token as
operator input. See decisions D-11 and D-14.

Nothing in the GUPZ token model comes through this file. A GUPZ token is a JWS
inside a JWE, minted per run and valid for fifteen minutes, so it cannot live in
a committed file.

`qualificationScript` reads `GUPZ PDF/A`, matching the information standard in
`properties.json`. The engine does nothing with it; it is a label for whoever
opens the file.

## Target server

`_LoadResources` writes to the FHIR server named by `serverAlias` in its
`properties.json`, which is `gupz`. That is a default: when a provisioning is
created from the Manage screen the target server can be overruled there. The
same server sits behind the client aimed tests, so what this set writes is what
a client under test reads back.

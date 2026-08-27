# Testing the token a caller produces

The authentication set aimed at the calling party. Where
[auth-test-design.md](auth-test-design.md) judges what a data platform does with
a token it receives, this one judges the token itself, from the side that
receives it.

The distinction matters because the obligations run the other way. Everything
`security.md` says about the content of a token is a requirement on the party
that builds it. A platform can only accept or refuse. So for a DVA this is the
set that says something about their implementation, and the PDF/A set is not.

## How far this can reach, and why

A GUPZ token is a nested JWT: a JWS signed by the caller, encrypted into a JWE
addressed to the receiving platform. Conformancelab holds no decryption key, so
everything inside stays closed. That includes every claim: `sub`, `patient`,
`aud`, `scope`, `iat`, `exp` and the fifteen minute rule, and the whole JWS
header with its `alg` and `kid`.

What is readable is the JWE protected header, because that part is base64url and
not encrypted. It carries `alg`, `enc` and `cty`, which happens to be exactly
the three fields `GUPZ-TOK-002` prescribes.

So this set proves that a caller builds the right kind of envelope, and that it
does not leak a BSN into the url. It cannot prove what is in the envelope. That
needs a receiver with the private key, which on this interface is the data
platform and never the test tool. Anything beyond the envelope has to be tested
by a platform refusing a token, which is what the Dataplatform set does.

## How the token is read

Three Conformancelab extensions in a chain, available since the IG update of
18 August 2026. Before that a token was an opaque string to the engine.

1. A variable with `headerField` `Authorization` and a `sourceId` pointing at
   the operation's `requestId`, carrying
   `Interoplab-CL-ext-variable-regex-mapper`
   with the pattern `(?<=Bearer )[A-Za-z0-9_-]+`. The lookbehind skips the
   scheme; the character class stops at the first dot, so the match is exactly
   the first segment of the compact serialization, which is the protected
   header. Regex groups are not supported, so the pattern has to match the
   wanted text and nothing else.
2. An assert carrying `Interoplab-CL-ext-assert-input-variable` with that
   variable's name and `Interoplab-CL-ext-assert-mapper-function`
   `base64Decode`.
3. `Interoplab-CL-ext-assert-regex-matches` on the assert's `value`, so the
   check is a pattern and not an exact string. `"alg"\s*:\s*"RSA-OAEP"`
   tolerates the whitespace a serialiser may or may not add.

A second variable holds the whole token, `(?<=Bearer ).*$`, to count the
segments.

## The cases

| Case | What is checked | Requirement | Weight |
|---|---|---|---|
| DVA-01 | An `Authorization` header is present | GUPZ-TOK-001 | hard |
| | It uses the Bearer scheme | GUPZ-TOK-001 | hard |
| | The token has five dot separated parts, so it is a JWE and not a bare JWS | GUPZ-TOK-002 | hard, stops the test |
| | The JWE header declares `alg` `RSA-OAEP` | GUPZ-TOK-002 | hard |
| | The JWE header declares `enc` `A256CBC-HS512` | GUPZ-TOK-002 | hard |
| | The JWE header declares `cty` `JWT` | GUPZ-TOK-002 | hard |
| | The JWE header names a key | none yet | warning |
| | No `patient=` in the url | GUPZ-URL-001 | hard |
| | No `subject=` in the url | GUPZ-URL-001 | hard |
| | The BSN naming system does not appear in the url | GUPZ-URL-001 | hard |

The part count stops the test when it fails, because decoding a header out of
something that is not a JWE says nothing.

The key id is the one warning, and the reason is worth keeping. `GUPZ-JWS-001`
requires a `kid`, but on the JWS header, which is inside the encryption and
unreadable from here. The JWE header table in `security.md` lists only `alg`,
`enc` and `cty`. So a `kid` on the JWE is required by nothing, and failing a
caller over it would make a tool's habit into a rule. It is still worth
reporting, because key rotation under [#27][i27] has the platform resolve its
encryption key from a JWKS and a `kid` is how that lookup finds the right one.
That gap is raised in [#75][i75].

## No token is prescribed, and this set is the only one where that is right

Every other set names a fixed qualification token on the operation. That tells
the caller what to send and lets the server behind the test scope its answer to
one patient. Here the caller's own token is the subject, so prescribing one
would replace the thing being judged.

Two consequences follow. Conformancelab shows the expected request without an
`Authorization` header, and the caller sends the token it would send to a real
platform. And an Automated dry run cannot validate this set: with no header
described, the engine sends no token, and every assert here fails. Only a real
caller can exercise it.

## What is not covered

**Every claim.** See above; they are encrypted. The Dataplatform set covers them
from the other side, by checking that a platform refuses a token that is wrong.

**The signature.** Whether the JWS is signed with RS256, and whether it verifies
against the caller's published key, needs the decrypted inner token.

**One token per patient.** [#73][i73] requires a patient specific token. Two
requests with two different patients would have to carry two different tokens,
which is observable in principle: capture both and assert they differ. Not
built, because it needs a second operation and a caller willing to drive it.

**Whether the caller validates the server certificate.** Not visible in a
request. The Proxy records what was presented in the other direction, which is
the closest thing available.

[i27]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/27
[i73]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/73
[i75]: https://github.com/Gegevensuitwisseling-Paramedische-Zorg/open-GUPZ/issues/75

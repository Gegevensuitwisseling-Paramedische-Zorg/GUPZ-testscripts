# dva-sim

Stands in for a DVA calling a GUPZ data platform. One request per run, printing
what went out and what came back.

## Why this exists

Conformancelab can run a client aimed Test Set on its own, through the Automated
option, by sending the requests the system under test would have sent. That works
for the PDF/A client set, where the operation prescribes the token.

It does not work for the authentication client set, which prescribes no token on
purpose: there the caller's own token is what is being judged. With nothing
described, an automated run sends nothing, and every assert fails for want of a
request. So something has to make the call, and until a real DVA connects, this
is that something.

It asserts nothing. The asserts are in the TestScripts. This only puts a request
in front of them.

## Two ways to run it

A page in the browser, which is the easier one:

```bash
cd tools/dva-sim && python3 serve.py
```

Then open <http://127.0.0.1:8765>. It listens on localhost and nowhere else.

The page groups the scenarios the way the Kickstart screen does, first the Test
Set and then the role, and says how to get from there to a running test. Under each
heading is one card per scenario: what it judges, which token to use and why, the
request it is waiting for, and a button.

Only one field is global, the destination base URL. Everything else sits on the
card it belongs to, already set the way that scenario needs it. Three ways the
choice differs, and the card says which applies:

- **Mint a token.** For a scenario that judges the token itself, so it has to be
  one you made rather than one handed to you.
- **The token the script prescribes.** For a scenario that counts documents. The
  server scopes its answer to the patient the token belongs to, so the counts
  only add up with that one. The card names the patient.
- **It does not matter.** For a scenario Conformancelab answers itself from a
  stub, where nothing about the token decides anything.

A scenario answered by a stub goes somewhere else, and the page says so on the
card. A FHIR request travels to `/q/<organization id>/.../fhir`, which the proxy
routes to a FHIR server. A stub is served by the engine itself, at
`/cl/<organization id>/`. Only the second address reaches the code that answers
from a WireMock mapping, so sending a stub scenario down the FHIR path leaves the
operation waiting for a request that will never arrive. Both are worked out from
the one base url you paste.

Start the run in Conformancelab before sending. A request that arrives while no
run is active is not attached to anything, and the page says so.

Everything on the cards is read from the built TestScripts under `output/`, down
to the Test Set name and the list of asserts, so it cannot drift: add a script,
run `./build.sh`, refresh the page.

## Running one request from the command line

Standard library Python, no install. Minting a token needs `dotnet` and the
`jwtcli` tool from the open-GUPZ repository, plus a key pair.

```bash
python3 dva_sim.py --endpoint <destination base url from the Test setup screen>
```

That mints a token for `XXX_Baltus` and sends
`GET DocumentReference?status=current`, which is what `dva-01` expects.

Other things to send:

```bash
# the other test patient
python3 dva_sim.py --endpoint <url> --patient schulte

# a token somebody else made, or one from a file
python3 dva_sim.py --endpoint <url> --token-file ~/Claude/GUPZ/testkeys/T1-baltus.txt

# something else entirely
python3 dva_sim.py --endpoint <url> --path 'Binary/pdfa-binary1'
```

## Sending it wrong on purpose

An assert that never fails proves nothing. These make each one fail, which is how
you tell a working assert from one that is quietly passing.

| Flag | What arrives | Which assert should fail |
|---|---|---|
| `--header none` | no `Authorization` at all | the header exists |
| `--header no-bearer` | the token without the scheme | the header uses Bearer |
| `--header signed-only` | the inner three segments, so a bare JWS | the token is a nested JWT |
| `--header garbled` | five segments, last one damaged | nothing here; the platform should refuse it |
| `--bsn-in-url` | a `patient=` parameter carrying the BSN | no BSN in the url |
| `--age 1200` | `iat` backdated past the fifteen minute limit | nothing here; the platform should refuse it |

The last two rows are worth reading twice. This tool talks to Conformancelab,
which judges the request, so a token that is merely invalid still passes the
envelope checks. Refusing an expired or damaged token is a platform's job, and
that is tested from the other side, by the Auth Dataplatform set.

## Reading the output

The `Authorization` line is shortened to the first segment with the length and
the number of parts, because that is what matters and the whole thing is
unreadable anyway. Five parts is a JWE, three is a JWS.

The response is printed with the headers that carry meaning, so
`WWW-Authenticate` shows up in full when a stub refuses the request.

## Defaults you may need to change

`--jwtcli` and `--keys` point at a checkout of open-GUPZ and at a key directory
outside this repository. `--issuer`, `--audience`, `--provider` and `--scope`
carry example values; a real run against a platform needs the ones that platform
trusts.

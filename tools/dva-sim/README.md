# dva-sim

Stands in for a DVA calling a GUPZ data platform. One request per run, printing
what went out and what came back. It asserts nothing; the asserts are in the
TestScripts.

Conformancelab can drive a client aimed set on its own through the Automated
option, by sending the requests the system under test would have sent. That
works for the PDF/A DVA set, where the operation prescribes the token. It does
not work for Auth DVA, which prescribes no token on purpose (decision D-20):
with nothing described the engine sends nothing and every assert fails for want
of a request. Until a real DVA connects, this makes the call.

## Browser

```bash
cd tools/dva-sim && python3 serve.py
```

Open <http://127.0.0.1:8765>. It listens on localhost and nowhere else.

The page groups the scenarios the way the Kickstart screen does, Test Set then
role, with one card per scenario: what it judges, which token to use, the
request it is waiting for, and a button. Only the destination base URL is
global; everything else sits on the card, set the way that scenario needs it.

Three ways the token choice differs, and the card says which applies:

| Choice | When |
|---|---|
| Mint a token | The scenario judges the token itself, so it has to be one you made |
| The token the script prescribes | The scenario counts documents. The server scopes its answer to the patient the token belongs to. The card names the patient |
| It does not matter | Conformancelab answers from a stub; nothing about the token decides anything |

A stub scenario goes to a different address than a FHIR request, and the page
derives both from the one base URL you paste. See
[docs/authoring.md](../../docs/authoring.md#where-a-request-goes).

Start the run in Conformancelab before sending. A request arriving while no run
is active is not attached to anything, and the page says so.

Everything on the cards is read from the built TestScripts under `output/`, down
to the Test Set name and the list of asserts, so it cannot drift: add a script,
run `./build.sh`, refresh.

## Command line

Standard library Python, no install. Minting a token needs `dotnet` and the
`jwtcli` tool from open-GUPZ, plus a key pair.

```bash
python3 dva_sim.py --endpoint <destination base url from the Test setup screen>
```

That mints a token for `XXX_Baltus` and sends `GET
DocumentReference?status=current`, which is what `dva-01` expects.

```bash
# the other test patient
python3 dva_sim.py --endpoint <url> --patient schulte

# a token somebody else made, or one from a file
python3 dva_sim.py --endpoint <url> --token-file <path>

# something else entirely
python3 dva_sim.py --endpoint <url> --path 'Binary/pdfa-binary1'
```

`--jwtcli` and `--keys` point at a checkout of open-GUPZ and at a key directory
outside this repository. `--issuer`, `--audience`, `--provider` and `--scope`
carry example values; a real run needs the ones the platform trusts.

## Failing on purpose

An assert that never fails proves nothing. These make each one fail.

| Flag | What arrives | Which assert should fail |
|---|---|---|
| `--header none` | no `Authorization` at all | the header exists |
| `--header no-bearer` | the token without the scheme | the header uses Bearer |
| `--header signed-only` | the inner three segments, so a bare JWS | the token is a nested JWT |
| `--header garbled` | five segments, last one damaged | nothing here; the platform should refuse it |
| `--bsn-in-url` | a `patient=` parameter carrying the BSN | no BSN in the url |
| `--age 1200` | `iat` backdated past the fifteen minute limit | nothing here; the platform should refuse it |

The last two rows: this tool talks to Conformancelab, which judges the request,
so a token that is merely invalid still passes the envelope checks. Refusing an
expired or damaged token is a platform's job, tested from the other side by the
Auth Dataplatform set.

## Output

The `Authorization` line is shortened to the first segment with the length and
the number of parts. Five parts is a JWE, three is a JWS. The response is
printed with the headers that carry meaning, so `WWW-Authenticate` shows up in
full when a stub refuses the request.

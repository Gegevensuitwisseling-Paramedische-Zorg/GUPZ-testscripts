#!/usr/bin/env python3
"""Stand in for a DVA calling a GUPZ data platform.

The client aimed Test Sets cannot be tried with Conformancelab's Automated mode,
because they deliberately prescribe no token: the caller's own token is what is
being judged. So something has to make the call. This is that something.

It sends one request, prints exactly what went out and what came back, and stops.
Nothing is asserted here; the asserts live in the TestScripts. This only makes
sure the engine has a request to look at.

Standard library only. Python 3.9 or later.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

# Test patients from the imported fixtures. The BSN is what goes in the token;
# it must never appear in a url.
PATIENTS = {
    "baltus": {"bsn": "999910796", "name": "XXX_Baltus"},
    "schulte": {"bsn": "999910784", "name": "XXX_Schulte"},
}

BSN_SYSTEM = "http://fhir.nl/fhir/NamingSystem/bsn"
AGB_SYSTEM = "http://fhir.nl/fhir/NamingSystem/agb-z"


def mint_token(args, patient):
    """Build a nested JWT with jwtcli, the tool in the open-GUPZ repository.

    Shelling out rather than signing here on purpose: jwtcli is what GUPZ
    publishes, so what it produces is the profile a supplier will meet.
    """
    if not shutil.which("dotnet"):
        sys.exit("dotnet not found, needed to run jwtcli. Pass --token instead.")

    now = int(time.time())
    bsn = f"{BSN_SYSTEM}|{PATIENTS[patient]['bsn']}"
    cmd = [
        "dotnet", "run", "--project", args.jwtcli, "--no-build", "--",
        "--signing-key", os.path.join(args.keys, "signing_private.pem"),
        "--encryption-key", os.path.join(args.keys, "encryption_public.pem"),
        "--iat", str(now - args.age),
        "--exp", str(now - args.age + 900),
        "--iss", args.issuer,
        "--aud", args.audience,
        "--sub", bsn,
        "--patient", bsn,
        "--provider", f"{AGB_SYSTEM}|{args.provider}",
        "--scope", args.scope,
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"jwtcli failed:\n{result.stdout}{result.stderr}")
    token = result.stdout.strip().splitlines()[-1]
    if token.count(".") != 4:
        sys.exit(f"jwtcli did not return a compact JWE:\n{token[:200]}")
    return token


def stub_endpoint(base):
    """Turn the destination base url into the address a stub listens on.

    A stub does not hang off the FHIR path. The proxy routes
    /q/<id>/<usecase>/<version>/fhir to the FHIR server, and /cl/<id>/... to the
    engine, stripping the id into a header on the way. Only the second one
    reaches the filter that answers from a WireMock mapping, so a request meant
    for a stub has to go there.

    Both are derived from the same organization id, so the one address the
    operator pastes is enough for both.
    """
    m = re.match(r"(https?://[^/]+)/[qd]/([^/]+)/", base.rstrip("/") + "/")
    if not m:
        raise ValueError(
            "cannot work out the stub endpoint from " + base + ". Expected a "
            "destination base url of the form https://host/q/<organization id>/...")
    return f"{m.group(1)}/cl/{m.group(2)}"


def authorization_header(token, flavour):
    """The header, or a deliberately wrong version of it.

    The broken variants exist so that a refusal case can be shown to fail. An
    assert that never fails proves nothing, which is the same reason the server
    aimed set was first run against a server that ignores tokens.
    """
    if flavour == "none":
        return None
    if flavour == "no-bearer":
        return token
    if flavour == "signed-only":
        parts = token.split(".")
        return "Bearer " + ".".join(parts[:3])  # looks like a JWS, three parts
    if flavour == "garbled":
        return "Bearer " + token[:-8] + "AAAAAAAA"
    return "Bearer " + token


def build_url(base, args):
    path = args.path
    if args.bsn_in_url:
        # What GUPZ-URL-001 forbids, so that the assert against it can be seen
        # to fail rather than merely to pass.
        joiner = "&" if "?" in path else "?"
        path = f"{path}{joiner}patient={BSN_SYSTEM}|{PATIENTS[args.patient]['bsn']}"
    return base.rstrip("/") + "/" + path.lstrip("/")


def show(title, lines):
    print(f"\n{title}")
    print("-" * len(title))
    for line in lines:
        print(line)


def send(url, headers, timeout=90):
    """Perform the request and return status, headers and body as text.

    Shared with the browser front end, so that both ways of driving a scenario
    go through the same code and cannot drift apart.
    """
    req = urllib.request.Request(url, headers=headers, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, dict(r.headers), r.read()
    except urllib.error.HTTPError as e:
        return e.code, dict(e.headers), e.read()


def main():
    p = argparse.ArgumentParser(
        description="Send one request to Conformancelab as a DVA would.")
    p.add_argument("--endpoint", required=True,
                   help="the destination base url Conformancelab shows for a client test")
    p.add_argument("--path", default="DocumentReference?status=current",
                   help="what to request, relative to the endpoint")
    p.add_argument("--accept", default="application/fhir+json")

    tok = p.add_argument_group("the token")
    tok.add_argument("--token", help="use this token instead of minting one")
    tok.add_argument("--token-file", help="read the token from a file")
    tok.add_argument("--patient", choices=sorted(PATIENTS), default="baltus")
    tok.add_argument("--header", default="valid",
                     choices=["valid", "none", "no-bearer", "signed-only", "garbled"],
                     help="send a correct header, or a specific kind of wrong one")
    tok.add_argument("--bsn-in-url", action="store_true",
                     help="also put the BSN in a query parameter, which the specification forbids")

    mint = p.add_argument_group("minting with jwtcli")
    mint.add_argument("--jwtcli", default=os.path.expanduser("~/GitHub/open-GUPZ/src/JwtCliTool"))
    mint.add_argument("--keys", default=os.path.expanduser("~/Claude/GUPZ/testkeys"))
    mint.add_argument("--issuer", default="https://dva.example.nl")
    mint.add_argument("--audience", default="https://dataplatform.example.nl")
    mint.add_argument("--provider", default="20000001")
    mint.add_argument("--scope", default="medmij.gegevensdienst.51")
    mint.add_argument("--age", type=int, default=0,
                      help="seconds to backdate iat, to make a token too old")

    args = p.parse_args()

    if args.token_file:
        token = open(args.token_file).read().strip()
    elif args.token:
        token = args.token
    else:
        token = mint_token(args, args.patient)

    url = build_url(args.endpoint, args)
    headers = {"Accept": args.accept}
    auth = authorization_header(token, args.header)
    if auth is not None:
        headers["Authorization"] = auth

    shown = dict(headers)
    if "Authorization" in shown and len(shown["Authorization"]) > 60:
        head = shown["Authorization"].split(".")[0]
        shown["Authorization"] = f"{head}... ({len(shown['Authorization'])} chars, "\
                                 f"{shown['Authorization'].count('.') + 1} parts)"
    show("Request", [f"GET {url}"] + [f"{k}: {v}" for k, v in shown.items()])

    try:
        status, resp_headers, body = send(url, headers)
    except urllib.error.URLError as e:
        sys.exit(f"\nCould not reach {url}: {e.reason}")

    interesting = {k: v for k, v in resp_headers.items()
                   if k.lower() in ("content-type", "www-authenticate", "location")}
    show(f"Response {status}", [f"{k}: {v}" for k, v in interesting.items()] or ["(no headers of note)"])

    text = body.decode("utf-8", "replace")
    try:
        text = json.dumps(json.loads(text), indent=2)
    except ValueError:
        pass
    show("Body", [text[:2000] + ("\n... truncated" if len(text) > 2000 else "")]
         if text.strip() else ["(empty)"])


if __name__ == "__main__":
    main()

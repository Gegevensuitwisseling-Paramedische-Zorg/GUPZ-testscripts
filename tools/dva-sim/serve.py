#!/usr/bin/env python3
"""A local page for driving the client aimed scenarios by hand.

The scenarios are read from the built TestScripts under output/, not written out
here, so the instructions cannot drift from what the engine actually expects. Add
a script, rebuild, refresh the page.

Standard library only. Listens on localhost and nowhere else.
"""

import argparse
import glob
import json
import os
import re
import urllib.error
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import dva_sim

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PLACEHOLDER = re.compile(r"\$\{[^}]*\}")


def qualification_tokens():
    """Map a fixed qualification token to the patient it selects.

    Read from Configuration/QualificationTokens.json, the same file Conformancelab
    reads, so a card can say whose documents a prescribed token will return.
    """
    path = os.path.join(REPO, "Configuration", "QualificationTokens.json")
    try:
        entries = json.load(open(path))
    except (OSError, ValueError):
        return {}
    return {e["accessToken"].replace("Bearer ", ""): e.get("familyName", "")
            for e in entries}


def read_scenarios():
    """Group the client aimed TestScripts by the Test Set they belong to.

    Everything here comes out of output/, including the Test Set name, so the
    page says what Conformancelab says and cannot drift from it.
    """
    tokens = qualification_tokens()
    sets = []
    pattern = os.path.join(REPO, "output", "STU3", "*", "GUPZ", "Test",
                           "DVA-Client", "properties.json")
    for props_path in sorted(glob.glob(pattern)):
        props = json.load(open(props_path))
        folder = os.path.dirname(props_path)
        # The Kickstart screen shows the information standard and then the role;
        # goal and usecase do not appear in the picker, so they are not repeated
        # in the instruction here.
        name = f"{props['informationStandard']} / {props.get('role', {}).get('name', '')}"
        scenarios = []
        for path in sorted(glob.glob(os.path.join(folder, "TestScript-*.json"))):
            d = json.load(open(path))
            for test in d.get("test", []):
                scenarios.append(describe_test(d, test, tokens))
        sets.append({
            "name": name,
            "standard": props["informationStandard"],
            "role": props.get("role", {}).get("name", ""),
            "description": props.get("role", {}).get("description", ""),
            "scenarios": scenarios,
        })
    return sets


def describe_test(script, test, tokens):
    """One card: what it judges, what to send, and what to pick before sending."""
    steps, request, stub = [], None, None
    for action in test.get("action", []):
        if "operation" in action:
            step = describe_operation(action["operation"], tokens)
            if step["kind"] == "request" and request is None:
                request = step
            if step["kind"] == "stub" and stub is None:
                stub = step
            steps.append(step)
        else:
            a = action["assert"]
            steps.append({"kind": "assert", "text": a.get("description", ""),
                          "weight": weight_of(a)})

    if stub is not None:
        mode, patient, why = "mint", "baltus", (
            "Conformancelab answers this one itself, from a WireMock mapping, so "
            "the token does not decide anything. Send any GET and look at what "
            "comes back.")
        path = "DocumentReference?status=current"
    elif request and request.get("prescribed_token"):
        who = tokens.get(request["prescribed_token"].replace("Bearer ", ""), "")
        mode, patient = "prescribed", "baltus"
        why = (f"Use the token the script prescribes. It selects {who}, and the "
               "counts in this scenario only add up with that patient's documents.")
        path = request["path"]
    else:
        mode, patient = "mint", "baltus"
        why = ("Mint a token. This scenario judges the token you send, so it has "
               "to be one you made yourself, not a prescribed one.")
        path = request["path"] if request else ""

    return {
        "script": script["id"],
        "test": test["id"],
        "name": test.get("name", test["id"]),
        "description": test.get("description", ""),
        "steps": steps,
        "path": path,
        "unresolved": bool(request and request.get("unresolved")),
        "prescribed": (request or {}).get("prescribed_token", ""),
        "mode": mode,
        "patient": patient,
        "why": why,
    }


def weight_of(a):
    if a.get("defaultManualCompletion"):
        return "manual"
    return "warning" if a.get("warningOnly") else "hard"


def describe_operation(o, tokens):
    """What request this operation expects, and whether it can be sent as is."""
    code = o.get("type", {}).get("code", "")
    if code == "stub":
        return {"kind": "stub",
                "text": o.get("description", ""),
                "note": "Conformancelab answers this one from a WireMock mapping. "
                        "Send anything the mapping matches; here that is any GET."}
    path = (o.get("resource") or "") + (o.get("params") or "")
    if o.get("url"):
        path = o["url"]
    header = next((h["value"] for h in o.get("requestHeader", [])
                   if h["field"].lower() == "authorization"), None)
    _ = tokens
    return {"kind": "request",
            "text": o.get("description", ""),
            "path": path.lstrip("/") if not path.startswith("?") else path,
            "prescribed_token": header,
            "unresolved": bool(PLACEHOLDER.search(path))}


PAGE = """<!doctype html>
<meta charset="utf-8">
<title>DVA simulator</title>
<style>
 :root { color-scheme: light dark; --line:#8883; --bad:#b3261e; --warn:#8a6d00; --accent:#4a7ebb; }
 body { font: 15px/1.55 system-ui, sans-serif; margin:0 auto; max-width:62rem; padding:2rem 1.5rem 6rem; }
 h1 { font-size:1.4rem; margin:0 0 .3rem; }
 .sub { opacity:.75; margin:0 0 1.5rem; }
 fieldset { border:1px solid var(--line); border-radius:8px; margin:0 0 2rem; padding:1rem 1.2rem; }
 legend { padding:0 .4rem; font-weight:600; }
 label { display:block; margin:.6rem 0 .15rem; font-size:.85rem; opacity:.8; }
 input, select { width:100%; padding:.45rem .6rem; border:1px solid var(--line); border-radius:6px;
                 font:inherit; background:transparent; color:inherit; box-sizing:border-box; }
 .row { display:flex; gap:1rem; flex-wrap:wrap; } .row>* { flex:1; min-width:12rem; }
 .setgroup { margin:0 0 2.5rem; }
 .sethead { border-left:4px solid var(--accent); padding:.1rem 0 .1rem .9rem; margin:0 0 1rem; }
 .sethead h2 { font-size:1.15rem; margin:0 0 .2rem; }
 .setname { font-family:ui-monospace,monospace; font-size:.9rem; }
 .steps-to-open { font-size:.87rem; opacity:.85; margin:.5rem 0 0; padding-left:1.1rem; }
 .card { border:1px solid var(--line); border-radius:8px; padding:1rem 1.2rem; margin:0 0 1rem; }
 .card h3 { font-size:1.02rem; margin:0 0 .1rem; }
 .tag { font-size:.72rem; text-transform:uppercase; letter-spacing:.04em; opacity:.6; }
 .desc { margin:.5rem 0 .9rem; font-size:.94rem; }
 .why { border-left:3px solid var(--accent); padding:.45rem .8rem; margin:.2rem 0 .9rem; font-size:.89rem; }
 ul.judged { margin:.3rem 0 .9rem; padding-left:1.1rem; font-size:.9rem; }
 ul.judged li { margin:.12rem 0; }
 .hard::marker { color:var(--bad); } .warning::marker, .manual::marker { color:var(--warn); }
 .out { white-space:pre-wrap; font-family:ui-monospace,monospace; font-size:.82rem;
        border-left:3px solid var(--line); padding:.6rem .8rem; margin-top:.9rem; overflow-x:auto; }
 button { font:inherit; padding:.45rem 1.1rem; border-radius:6px; border:1px solid var(--line);
          background:#8881; color:inherit; cursor:pointer; }
 button:hover { background:#8882; }
 .warnbox { border-left:3px solid var(--warn); padding:.45rem .8rem; margin:.5rem 0; font-size:.87rem; }
</style>
<h1>DVA simulator</h1>
<p class="sub">Sends the requests a client aimed scenario is waiting for. Every card is read from
the built TestScripts, so it says what the engine expects and nothing else.</p>

<fieldset>
 <legend>The one thing to fill in</legend>
 <label>Destination base URL. Conformancelab shows it on the Test setup screen once you pick a
 client role, and it holds your organization id.</label>
 <input id="endpoint" placeholder="https://gupz.proxy.interoplab.eu/q/&lt;id&gt;/gupz/stu3/fhir">
 <p class="warnbox">The run has to be started in Conformancelab before anything sent here is
 picked up. A request that arrives while no run is active is not attached to anything.</p>
</fieldset>

<div id="sets">loading...</div>

<script>
const esc = s => (s||"").replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
let SETS = [];

fetch('/api/scenarios').then(r => r.json()).then(sets => {
  SETS = sets;
  document.getElementById('sets').innerHTML = sets.map((st, si) => `
    <div class="setgroup">
      <div class="sethead">
        <h2>${esc(st.standard)} &middot; ${esc(st.role)}</h2>
        <ol class="steps-to-open">
          <li>On the Kickstart screen, pick Test set <b>${esc(st.standard)}</b>,
              then role <b>${esc(st.role)}</b>.</li>
          <li>Copy the destination base URL it shows into the field above.</li>
          <li>Press <b>Create test run</b>, then <b>Start test run</b>.</li>
          <li>Work down the cards below in order, and watch the run while you do.</li>
        </ol>
      </div>
      ${st.scenarios.map((s, i) => card(st, s, si, i)).join('')}
    </div>`).join('');
});

function card(st, s, si, i) {
  const judged = s.steps.filter(x => x.kind === 'assert');
  return `<div class="card" id="c${si}-${i}">
    <div class="tag">${esc(s.script)}</div>
    <h3>${esc(s.name)}</h3>
    <p class="desc">${esc(s.description)}</p>
    <div class="why">${esc(s.why)}</div>
    <div class="tag">What this scenario judges</div>
    <ul class="judged">${judged.map(a => `<li class="${a.weight}">${esc(a.text)}</li>`).join('')}</ul>
    <div class="row">
      <div><label>Token</label>
        <select class="mode">
          <option value="mint"${s.mode==='mint'?' selected':''}>mint one with jwtcli</option>
          <option value="prescribed"${s.mode==='prescribed'?' selected':''}${s.prescribed?'':' disabled'}>the one this script prescribes</option>
          <option value="own">one I paste below</option>
        </select></div>
      <div><label>Patient, when minting</label>
        <select class="patient">
          <option${s.patient==='baltus'?' selected':''}>baltus</option>
          <option${s.patient==='schulte'?' selected':''}>schulte</option>
        </select></div>
      <div><label>Send it wrong on purpose</label>
        <select class="flavour">
          <option value="valid">no, send it correctly</option>
          <option value="none">leave out the Authorization header</option>
          <option value="no-bearer">drop the Bearer prefix</option>
          <option value="signed-only">send the inner JWS, not the JWE</option>
          <option value="garbled">damage the token</option>
        </select></div>
    </div>
    <label>Request</label>
    <input class="path" value="${esc(s.path)}">
    ${s.unresolved ? `<div class="warnbox">This path holds a variable that Conformancelab fills in
      during a run, so it cannot be sent as it stands. Read the value the engine used off the run
      and paste it in.</div>` : ''}
    <label>A token of your own, if you picked that</label>
    <input class="own" placeholder="paste a token">
    <label><input type="checkbox" class="bsn" style="width:auto"> also put the BSN in the url, which the specification forbids</label>
    <p><button onclick="go(${si},${i},this)">Send</button></p>
    <div class="out" hidden></div></div>`;
}

function go(si, i, btn) {
  const c = btn.closest('.card'), out = c.querySelector('.out');
  const endpoint = document.getElementById('endpoint').value.trim();
  if (!endpoint) { out.hidden = false; out.textContent = 'Fill in the destination base URL first.'; return; }
  out.hidden = false; out.textContent = 'sending...';
  fetch('/api/send', {method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({
      endpoint,
      path: c.querySelector('.path').value,
      flavour: c.querySelector('.flavour').value,
      tokenmode: c.querySelector('.mode').value,
      token: c.querySelector('.own').value.trim(),
      prescribed: SETS[si].scenarios[i].prescribed || '',
      patient: c.querySelector('.patient').value,
      bsn_in_url: c.querySelector('.bsn').checked
    })})
   .then(r => r.json()).then(d => out.textContent = d.text)
   .catch(e => out.textContent = 'failed: ' + e);
}
</script>
"""


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _send(self, code, body, ctype):
        data = body.encode() if isinstance(body, str) else body
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/":
            self._send(200, PAGE, "text/html; charset=utf-8")
        elif self.path == "/api/scenarios":
            self._send(200, json.dumps(read_scenarios()), "application/json")
        else:
            self._send(404, "not found", "text/plain")

    def do_POST(self):
        if self.path != "/api/send":
            return self._send(404, "not found", "text/plain")
        n = int(self.headers.get("Content-Length", 0))
        req = json.loads(self.rfile.read(n) or b"{}")
        self._send(200, json.dumps({"text": run(req)}), "application/json")


def run(req):
    """One request, reported the way the command line reports it."""
    if not req.get("endpoint"):
        return "Fill in the destination base URL first."

    mode = req.get("tokenmode")
    if mode == "own":
        token = req.get("token") or ""
        if not token:
            return "Pick a token, or choose another way of getting one."
    elif mode == "prescribed":
        token = (req.get("prescribed") or "").replace("Bearer ", "")
        if not token:
            return "This scenario prescribes no token. Mint one or paste your own."
    else:
        try:
            token = dva_sim.mint_token(ARGS, req.get("patient", "baltus"))
        except SystemExit as e:
            return str(e)

    args = argparse.Namespace(path=req.get("path", ""),
                              bsn_in_url=req.get("bsn_in_url", False),
                              patient=req.get("patient", "baltus"))
    url = dva_sim.build_url(req["endpoint"], args)
    headers = {"Accept": "application/fhir+json"}
    auth = dva_sim.authorization_header(token, req.get("flavour", "valid"))
    if auth is not None:
        headers["Authorization"] = auth

    shown = auth or "(no Authorization header)"
    if len(shown) > 60:
        shown = f"{shown.split('.')[0]}... ({len(shown)} chars, {shown.count('.') + 1} parts)"
    lines = [f"GET {url}", f"Authorization: {shown}", ""]

    try:
        status, resp_headers, body = dva_sim.send(url, headers)
    except urllib.error.URLError as e:
        return "\n".join(lines + [f"Could not reach it: {e.reason}"])

    lines.append(f"Response {status}")
    for k, v in resp_headers.items():
        if k.lower() in ("content-type", "www-authenticate", "location"):
            lines.append(f"{k}: {v}")
    text = body.decode("utf-8", "replace")
    try:
        text = json.dumps(json.loads(text), indent=2)
    except ValueError:
        pass
    lines += ["", text[:4000] + ("\n... truncated" if len(text) > 4000 else "")]
    return "\n".join(lines)


ARGS = None

if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Serve the DVA simulator on localhost.")
    p.add_argument("--port", type=int, default=8765)
    p.add_argument("--jwtcli", default=os.path.expanduser("~/GitHub/open-GUPZ/src/JwtCliTool"))
    p.add_argument("--keys", default=os.path.expanduser("~/Claude/GUPZ/testkeys"))
    p.add_argument("--issuer", default="https://dva.example.nl")
    p.add_argument("--audience", default="https://dataplatform.example.nl")
    p.add_argument("--provider", default="20000001")
    p.add_argument("--scope", default="medmij.gegevensdienst.51")
    p.add_argument("--age", type=int, default=0)
    ARGS = p.parse_args()
    print(f"DVA simulator on http://127.0.0.1:{ARGS.port}  (ctrl-c to stop)")
    ThreadingHTTPServer(("127.0.0.1", ARGS.port), Handler).serve_forever()

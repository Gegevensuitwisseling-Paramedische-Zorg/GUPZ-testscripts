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


def read_scenarios():
    """Turn every client aimed TestScript into cards the page can show."""
    out = []
    pattern = os.path.join(REPO, "output", "STU3", "*", "GUPZ", "Test",
                           "DVA-Client", "TestScript-*.json")
    for path in sorted(glob.glob(pattern)):
        d = json.load(open(path))
        standard = path.split(os.sep)[-5]
        for test in d.get("test", []):
            steps = []
            for action in test.get("action", []):
                if "operation" in action:
                    steps.append(describe_operation(action["operation"]))
                else:
                    a = action["assert"]
                    steps.append({"kind": "assert",
                                  "text": a.get("description", ""),
                                  "weight": weight_of(a)})
            out.append({
                "script": d["id"],
                "test": test["id"],
                "set": f"{d.get('title', d['id'])}",
                "standard": standard,
                "name": test.get("name", test["id"]),
                "description": test.get("description", ""),
                "steps": steps,
            })
    return out


def weight_of(a):
    if a.get("defaultManualCompletion"):
        return "manual"
    return "warning" if a.get("warningOnly") else "hard"


def describe_operation(o):
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
    return {"kind": "request",
            "text": o.get("description", ""),
            "path": path.lstrip("/") if not path.startswith("?") else path,
            "prescribed_token": header,
            "unresolved": bool(PLACEHOLDER.search(path))}


PAGE = """<!doctype html>
<meta charset="utf-8">
<title>DVA simulator</title>
<style>
 :root { color-scheme: light dark; --line:#8883; --ok:#1a7f37; --bad:#b3261e; --warn:#8a6d00; }
 body { font: 15px/1.55 system-ui, sans-serif; margin: 0 auto; max-width: 60rem; padding: 2rem 1.5rem 5rem; }
 h1 { font-size: 1.4rem; margin: 0 0 .3rem; }
 .sub { opacity:.7; margin:0 0 1.5rem; }
 fieldset { border:1px solid var(--line); border-radius:8px; margin:0 0 1.5rem; padding:1rem; }
 legend { padding:0 .4rem; font-weight:600; }
 label { display:block; margin:.5rem 0 .15rem; font-size:.85rem; opacity:.8; }
 input, select { width:100%; padding:.45rem .6rem; border:1px solid var(--line); border-radius:6px;
                 font:inherit; background:transparent; color:inherit; box-sizing:border-box; }
 .row { display:flex; gap:1rem; } .row>* { flex:1; }
 .card { border:1px solid var(--line); border-radius:8px; padding:1rem 1.2rem; margin:0 0 1rem; }
 .card h2 { font-size:1.05rem; margin:0 0 .1rem; }
 .tag { font-size:.72rem; text-transform:uppercase; letter-spacing:.04em; opacity:.65; }
 .desc { margin:.5rem 0 .8rem; }
 ul.steps { margin:.4rem 0 .9rem; padding-left:1.1rem; }
 ul.steps li { margin:.15rem 0; }
 .hard::marker { color:var(--bad); } .warning::marker { color:var(--warn); } .manual::marker { color:var(--warn); }
 code { background:#8881; padding:.1rem .3rem; border-radius:4px; font-size:.88em; }
 button { font:inherit; padding:.45rem 1rem; border-radius:6px; border:1px solid var(--line);
          background:#8881; color:inherit; cursor:pointer; }
 button:hover { background:#8882; }
 .out { white-space:pre-wrap; font-family:ui-monospace,monospace; font-size:.82rem;
        border-left:3px solid var(--line); padding:.6rem .8rem; margin-top:.8rem; overflow-x:auto; }
 .note { font-size:.85rem; opacity:.75; margin:.4rem 0; }
 .warnbox { border-left:3px solid var(--warn); padding:.4rem .8rem; margin:.5rem 0; font-size:.87rem; }
</style>
<h1>DVA simulator</h1>
<p class="sub">Drives the client aimed scenarios by hand. The cards are read from the built
TestScripts, so they always say what the engine expects.</p>

<fieldset>
 <legend>Setup</legend>
 <label>Destination base URL, from the Test setup screen in Conformancelab</label>
 <input id="endpoint" placeholder="https://gupz.proxy.interoplab.eu/q/.../gupz/stu3/fhir">
 <div class="row">
  <div><label>Token</label>
   <select id="tokenmode">
     <option value="mint">mint one with jwtcli</option>
     <option value="prescribed">use the token the script prescribes</option>
     <option value="own">paste one below</option>
   </select></div>
  <div><label>Patient, when minting</label>
   <select id="patient"><option>baltus</option><option>schulte</option></select></div>
  <div><label>Send it wrong on purpose</label>
   <select id="flavour">
     <option value="valid">no, send it correctly</option>
     <option value="none">leave out the Authorization header</option>
     <option value="no-bearer">drop the Bearer prefix</option>
     <option value="signed-only">send the inner JWS, not the JWE</option>
     <option value="garbled">damage the token</option>
   </select></div>
 </div>
 <label>Your own token</label>
 <input id="token" placeholder="paste a token here if you picked that above">
 <label><input type="checkbox" id="bsn" style="width:auto"> also put the BSN in the url, which the specification forbids</label>
</fieldset>

<div id="cards">loading...</div>

<script>
const $ = s => document.querySelector(s);
const esc = s => (s||"").replace(/[&<>]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));

fetch('/api/scenarios').then(r => r.json()).then(list => {
  $('#cards').innerHTML = list.map((s, i) => {
    const req = s.steps.find(x => x.kind === 'request');
    const stub = s.steps.find(x => x.kind === 'stub');
    const asserts = s.steps.filter(x => x.kind === 'assert');
    let body = '';
    if (req) {
      body += `<label>Request to send</label><input class="path" value="${esc(req.path)}">`;
      if (req.unresolved) body += `<div class="warnbox">This path holds a variable the engine
        resolves at run time. Fill in a real value before sending.</div>`;
      if (req.prescribed_token) body += `<p class="note">The script prescribes a fixed token.
        Pick "use the token the script prescribes" above to send that one.</p>`;
    } else if (stub) {
      body += `<label>Request to send</label><input class="path" value="DocumentReference?status=current">
        <p class="note">${esc(stub.note)}</p>`;
    }
    return `<div class="card" data-i="${i}">
      <div class="tag">${esc(s.standard)} &middot; ${esc(s.script)}</div>
      <h2>${esc(s.name)}</h2>
      <p class="desc">${esc(s.description)}</p>
      <div class="tag">What is judged</div>
      <ul class="steps">${asserts.map(a =>
        `<li class="${a.weight}">${esc(a.text)}</li>`).join('')}</ul>
      ${body}
      <p><button onclick="go(${i}, this)">Send</button></p>
      <div class="out" hidden></div></div>`;
  }).join('');
  window._list = list;
});

function go(i, btn) {
  const card = btn.closest('.card');
  const out = card.querySelector('.out');
  const path = card.querySelector('.path');
  out.hidden = false; out.textContent = 'sending...';
  fetch('/api/send', {method:'POST', headers:{'Content-Type':'application/json'},
    body: JSON.stringify({
      endpoint: $('#endpoint').value.trim(),
      path: path ? path.value : '',
      flavour: $('#flavour').value,
      tokenmode: $('#tokenmode').value,
      token: $('#token').value.trim(),
      prescribed: (window._list[i].steps.find(x => x.kind === 'request')||{}).prescribed_token || '',
      patient: $('#patient').value,
      bsn_in_url: $('#bsn').checked
    })})
   .then(r => r.json())
   .then(d => { out.textContent = d.text; })
   .catch(e => { out.textContent = 'failed: ' + e; });
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

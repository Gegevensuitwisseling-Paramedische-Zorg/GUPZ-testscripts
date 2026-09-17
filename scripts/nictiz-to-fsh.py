"""Convert an imported Nictiz TestScript (XML) into FSH.

A conversion aid, not a translator. It recognises the blocks that are identical
across scripts and emits an `insert` for them; everything else is written out
literally. Escaping of FHIRPath expressions is done here rather than by hand,
because those expressions contain backslashes that are easy to get wrong.

The output is a starting point. Always verify the built result against the
original with scripts/compare-testscript.py before deleting the XML.

Usage:
    python3 scripts/nictiz-to-fsh.py <script-json.xml> [...]

Each input file produces one FSH file on stdout, containing a parameterised
RuleSet for the parts that differ between the JSON and the XML variant, a
non-parameterised RuleSet for the rest, and the two Instances. Parts that
differ per variant are kept out of the non-parameterised RuleSet on purpose:
SUSHI substitutes anything in braces inside a parameterised RuleSet, which
would corrupt Conformancelab placeholders such as ${UUID} and regex quantifiers
such as {8} inside FHIRPath.
"""

import re
import sys
import xml.etree.ElementTree as ET

F = "{http://hl7.org/fhir}"

# Deliberate deviation from the imported scripts: Nictiz declares its Groovy
# rules with the Touchstone extensions, Conformancelab defines its own. The two
# are structurally the same, so only the url changes. Confirmed by Interoplab on
# 14 August 2026.
EXTENSION_URLS = {
    "http://touchstone.aegis.net/touchstone/fhir/testing/StructureDefinition/testscript-rule":
        "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-rule",
    "http://touchstone.aegis.net/touchstone/fhir/testing/StructureDefinition/testscript-assert-rule":
        "http://fhir.interoplab.eu/fhir/StructureDefinition/Interoplab-CL-ext-assert-rule",
}


def extension_url(url):
    return EXTENSION_URLS.get(url, url)

# The seventeen asserts that every searchset scenario shares, identified by the
# description of the first and last one. Verified identical across scenarios
# 1.1, 1.2, 1.4, 2.1 and 2.5.
CORE_FIRST = "Confirm that the returned resource type is Bundle."
CORE_LAST = "Confirm that the parameters in the request URL are all handled by the server"
CORE_LEN = 17


def val(elem, tag):
    child = elem.find(F + tag)
    return child.get("value") if child is not None else None


def fsh(text):
    """Quote a string for FSH, escaping backslashes and quotes."""
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def code(text):
    return "#" + text


def emit_assert(a, out, indent="* "):
    """Write one assert as explicit FSH rules."""
    out.append(f"{indent}test[=].action[+].assert")
    for child in a:
        tag = child.tag.replace(F, "")
        if tag == "extension":
            url = extension_url(child.get("url"))
            out.append(f"  * extension[+].url = {fsh(url)}")
            for sub in child:
                sub_tag = sub.get("url")
                out.append(f"  * extension[=].extension[+].url = {fsh(sub_tag)}")
                out.append(f"  * extension[=].extension[=].valueId = {fsh(sub[0].get('value') if len(sub) else sub.get('value'))}")
            continue
        value = child.get("value")
        if tag in ("direction", "operator", "requestMethod"):
            out.append(f"  * {tag} = {code(value)}")
        elif tag in ("stopTestOnFail", "warningOnly"):
            out.append(f"  * {tag} = {value}")
        else:
            out.append(f"  * {tag} = {fsh(value)}")


def emit_operation(op, out):
    """Write one operation, leaving accept to the Instance."""
    otype = op.find(F + "type")
    if otype is not None:
        out.append(
            f"* test[=].action[+].operation.type = {val(otype, 'system')}#{val(otype, 'code')}"
        )
    else:
        out.append("* test[=].action[+].operation.description = \"\"  // TODO no type")
    # accept is deliberately absent here: it differs per variant and is set on
    # the Instance. Everything else that the Nictiz scripts use is covered.
    for tag in ("resource", "label", "description", "params", "url",
                "requestId", "responseId", "sourceId", "targetId"):
        v = val(op, tag)
        if v is not None:
            out.append(f"* test[=].action[=].operation.{tag} = {fsh(v)}")
    # contentType is a code, not a string. Only scenario 2.5 sets it, which is
    # why this went unnoticed until that script was converted.
    v = val(op, "contentType")
    if v is not None:
        out.append(f"* test[=].action[=].operation.contentType = #{v}")
    for tag in ("destination", "origin"):
        v = val(op, tag)
        if v is not None:
            out.append(f"* test[=].action[=].operation.{tag} = {v}")
    v = val(op, "encodeRequestUrl")
    if v is not None:
        out.append(f"* test[=].action[=].operation.encodeRequestUrl = {v}")
    known = {"type", "accept", "requestHeader", "resource", "label", "description",
             "params", "url", "contentType", "requestId", "responseId", "sourceId",
             "targetId", "destination", "origin", "encodeRequestUrl"}
    for child in op:
        tag = child.tag.replace(F, "")
        if tag not in known:
            raise SystemExit(f"operation element not handled by the generator: {tag}")
    headers = [(val(h, "field"), val(h, "value")) for h in op.findall(F + "requestHeader")]
    fields = [h[0] for h in headers]
    # The imported scripts send three headers, of which only Authorization
    # survives on this interface; the MedMij tracing headers are dropped. See
    # decision D-08. The Bearer prefix may or may not be present in
    # the source, so the patient is read out of the variable name itself.
    if fields == ["Authorization", "MedMij-Request-ID", "X-Correlation-ID"]:
        m = re.search(r"\$\{patient-token-XXX_(\w+)\}", headers[0][1])
        if m is None:
            raise SystemExit(
                f"Authorization header not recognised by the generator: {headers[0][1]}"
            )
        out.append(f"* insert requestHeaders{m.group(1)}")
    else:
        for field, value in headers:
            out.append(f"* test[=].action[=].operation.requestHeader[+].field = {fsh(field)}")
            out.append(f"* test[=].action[=].operation.requestHeader[=].value = {fsh(value)}")


def convert(path):
    root = ET.parse(path).getroot()
    script_id = val(root, "id")
    # Server aimed scripts come in a JSON and an XML variant that differ only in
    # id, url, name, title and accept. Client aimed scripts have one variant.
    two_variants = script_id.endswith("-json")
    base_id = script_id[: -len("-json")] if two_variants else script_id
    name = val(root, "name")
    title = val(root, "title")
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", base_id).strip("-")

    head = [
        f"// Generated from {path.split('/')[-1]} with scripts/nictiz-to-fsh.py",
        "// and verified against the original with scripts/compare-testscript.py.",
        "",
    ]
    if two_variants:
        head += [
            f"RuleSet: {slug}-meta(format, formatLabel)",
            f"* insert metadata({base_id}-{{format}})",
            f"* name = {fsh(name.replace('_json', '_{format}'))}",
            f"* title = {fsh(title.replace('JSON Format', '{formatLabel} Format'))}",
        ]
    else:
        head += [
            f"RuleSet: {slug}-meta",
            f"* insert metadata({base_id})",
            f"* name = {fsh(name)}",
        ]
        # Not every imported script carries a title; the provisioning script
        # does not.
        if title is not None:
            head.append(f"* title = {fsh(title)}")
    description = val(root, "description")
    if description:
        head.append(f"* description = {fsh(description)}")

    known_root = {"id", "extension", "url", "version", "name", "title", "status",
                  "publisher", "contact", "description", "origin", "destination",
                  "profile", "variable", "fixture", "test", "setup", "teardown"}
    for child in root:
        tag = child.tag.replace(F, "")
        if tag not in known_root:
            raise SystemExit(f"root element not handled by the generator: {tag}")

    body = ["", f"RuleSet: {slug}-body"]

    # Touchstone rule declarations at TestScript level, kept verbatim.
    # Absolute paths on purpose: an indented rule inherits the path of the rule
    # above it, which would nest the sub extensions under .url.
    for ext in root.findall(F + "extension"):
        body.append(f"* extension[+].url = {fsh(extension_url(ext.get('url')))}")
        for sub in ext:
            body.append(f"* extension[=].extension[+].url = {fsh(sub.get('url'))}")
            child = sub[0]
            key = child.tag.replace(F, "")
            body.append(f"* extension[=].extension[=].{key} = {fsh(child.get('value'))}")

    sut = root.find(F + "origin").find(F + "extension").find(F + "valueBoolean").get("value")
    body.append("* insert clientAimed" if sut == "true" else "* insert serverAimed")

    for prof in root.findall(F + "profile"):
        body.append(f"* insert profileToValidate({prof.get('id')}, {prof.get('value')})")

    for fix in root.findall(F + "fixture"):
        body.append(f"* fixture[+].id = {fsh(fix.get('id'))}")
        for tag in ("autocreate", "autodelete"):
            v = val(fix, tag)
            if v is not None:
                body.append(f"* fixture[=].{tag} = {v}")
        resource = fix.find(F + "resource")
        if resource is not None:
            body.append(
                f"* fixture[=].resource.reference = {fsh(val(resource, 'reference'))}"
            )

    for var in root.findall(F + "variable"):
        vname = val(var, "name")
        if vname.startswith("patient-token-"):
            # The default is dropped on purpose: the imported scripts default to
            # a MedMij qualification token, which no GUPZ platform accepts. The
            # token is operator input. See decision D-11.
            patient = vname.replace("patient-token-", "")
            body.append(f"* insert variablePatientToken({patient})")
        elif vname == "X-Correlation-ID":
            # Skipped: the MedMij tracing headers are not sent on this
            # interface, so the variable has nothing left to fill.
            continue
        else:
            body.append(f"* variable[+].name = {fsh(vname)}")
            for tag in ("defaultValue", "description", "expression", "sourceId", "headerField", "path"):
                v = val(var, tag)
                if v is not None:
                    body.append(f"* variable[=].{tag} = {fsh(v)}")

    for test in root.findall(F + "test"):
        body.append("")
        tid = test.get("id") or val(test, "id")
        body.append(f"* test[+].id = {fsh(tid)}")
        for tag in ("name", "description"):
            v = val(test, tag)
            if v is not None:
                body.append(f"* test[=].{tag} = {fsh(v)}")
        actions = test.findall(F + "action")
        i = 0
        while i < len(actions):
            op = actions[i].find(F + "operation")
            if op is not None:
                emit_operation(op, body)
                i += 1
                continue
            a = actions[i].find(F + "assert")
            descriptions = []
            for j in range(i, min(i + CORE_LEN, len(actions))):
                nxt = actions[j].find(F + "assert")
                descriptions.append(val(nxt, "description") if nxt is not None else None)
            if (
                len(descriptions) == CORE_LEN
                and descriptions[0] == CORE_FIRST
                and descriptions[-1]
                and descriptions[-1].startswith(CORE_LAST)
            ):
                body.append("* insert assertsBundleSearchsetCore")
                i += CORE_LEN
                continue
            emit_assert(a, body)
            i += 1

    accept_paths = []
    for t_index, test in enumerate(root.findall(F + "test")):
        for a_index, action in enumerate(test.findall(F + "action")):
            op = action.find(F + "operation")
            if op is not None and val(op, "accept"):
                accept_paths.append((t_index, a_index, val(op, "accept")))

    tail = [""]
    variants = (("json", "JSON"), ("xml", "XML")) if two_variants else ((None, None),)
    for fmt, label in variants:
        tail.append(f"Instance: {base_id}-{fmt}" if fmt else f"Instance: {base_id}")
        tail.append("InstanceOf: TestScript")
        tail.append("Usage: #definition")
        tail.append(f"* insert {slug}-meta({fmt}, {label})" if fmt else f"* insert {slug}-meta")
        tail.append(f"* insert {slug}-body")
        for t_index, a_index, original in accept_paths:
            tail.append(
                f"* test[{t_index}].action[{a_index}].operation.accept = #{fmt or original}"
            )
        tail.append("")

    return "\n".join(head + body + tail)


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        print(convert(arg))

"""Compare a FHIR TestScript in XML with the same resource in JSON.

Both sides are flattened to path -> value. A single value and an array are
treated the same way (everything gets an index), so the difference in FHIR
serialisation between XML and JSON does not show up as noise. Underscore keys
in JSON (_profile) are merged with their regular counterpart.
"""
import json
import sys
import xml.etree.ElementTree as ET

FHIR = "{http://hl7.org/fhir}"


def flatten_xml(elem, prefix=""):
    out = {}
    counts = {}
    for child in elem:
        tag = child.tag.replace(FHIR, "")
        if tag is ET.Comment:
            continue
        idx = counts.get(tag, 0)
        counts[tag] = idx + 1
        path = f"{prefix}{tag}[{idx}]"
        if "value" in child.attrib:
            out[path] = child.attrib["value"]
        # attributes get the same [0] notation as the JSON side
        if "id" in child.attrib:
            out[f"{path}.id[0]"] = child.attrib["id"]
        if "url" in child.attrib:
            out[f"{path}.url[0]"] = child.attrib["url"]
        out.update(flatten_xml(child, path + "."))
    return out


def flatten_json(obj, prefix=""):
    out = {}
    if isinstance(obj, dict):
        merged = {}
        for key, value in obj.items():
            plain = key[1:] if key.startswith("_") else key
            merged.setdefault(plain, []).append(value)
        for key, values in merged.items():
            if key == "resourceType":
                continue
            for value in values:
                items = value if isinstance(value, list) else [value]
                for i, item in enumerate(items):
                    path = f"{prefix}{key}[{i}]"
                    if isinstance(item, (dict, list)):
                        out.update(flatten_json(item, path + "."))
                    elif item is not None:
                        out[path] = item
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            out.update(flatten_json(item, f"{prefix}[{i}]"))
    return out


def normalise(flat):
    return {k: (str(v).lower() if isinstance(v, bool) else str(v)) for k, v in flat.items()}


xml_flat = normalise(flatten_xml(ET.parse(sys.argv[1]).getroot()))
json_flat = normalise(flatten_json(json.load(open(sys.argv[2]))))

only_xml = {k: v for k, v in xml_flat.items() if json_flat.get(k) != v}
only_json = {k: v for k, v in json_flat.items() if xml_flat.get(k) != v}

if not only_xml and not only_json:
    print(f"IDENTICAL ({len(xml_flat)} elements compared)")
    sys.exit(0)

print(f"DIFFERENCES ({len(xml_flat)} in XML, {len(json_flat)} in JSON)\n")
for key in sorted(set(only_xml) | set(only_json)):
    print(f"  {key}")
    print(f"    XML : {only_xml.get(key, '<absent>')}")
    print(f"    JSON: {only_json.get(key, '<absent>')}")
sys.exit(1)

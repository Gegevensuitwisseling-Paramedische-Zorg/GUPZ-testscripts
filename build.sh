#!/bin/bash
#
# Builds output/ from input/. Everything under output/ is derived, so the whole
# directory is thrown away and rebuilt on every run. Do not edit anything there;
# the next build overwrites it without warning.
#
# Two kinds of input:
#
#   input/fsh/     TestScripts, written in FSH and built with SUSHI
#   input/static/  files that are copied verbatim, mirroring the output tree:
#                  the Test Set properties, the fixtures under _reference, the
#                  Groovy rule. No TestScript lives there; they all come from
#                  input/fsh/
#
# One file is not copied verbatim. Conformancelab treats every directory holding
# a properties.json as a Test Set, and it scans the whole repository, so a
# properties.json under input/ is picked up as a second, broken copy of the set.
# They are therefore called src-properties.json in input/ and renamed on the way
# out. This follows what Nictiz does for the same reason.
#
# Why the fixtures are not written in FSH: SUSHI supports R4 and later while the
# fixtures are STU3, and they contain Conformancelab placeholders such as
# ${DATE, T, D, -355} in typed fields, which any tool that type checks rejects.
# See the README.

set -e

SRC="./fsh-generated/resources"
OUT="./output"

echo "=== 1/4 Emptying output/"
rm -rf "$OUT"

echo "=== 2/4 Copying the static files"
mkdir -p "$OUT"
cp -R input/static/. "$OUT"/
for f in $(find "$OUT" -name src-properties.json); do
  mv "$f" "$(dirname "$f")/properties.json"
done
echo "  $(find "$OUT" -type f | wc -l | tr -d ' ') files, of which $(find "$OUT" -name properties.json | wc -l | tr -d ' ') Test Set properties"

echo "=== 3/4 SUSHI"
sushi build .

echo "=== 4/4 Installing the TestScripts"
shopt -s nullglob
count=0
for f in "$SRC"/TestScript-*.json; do
  name=$(basename "$f")
  case "$name" in
    TestScript-xis-*)  dest="$OUT/STU3/PDFA-3-0/GUPZ/Test/Dataplatform" ;;
    TestScript-phr-*)  dest="$OUT/STU3/PDFA-3-0/GUPZ/Test/DVA" ;;
    TestScript-auth-*) dest="$OUT/STU3/Auth/GUPZ/Test/Dataplatform" ;;
    TestScript-dva-*)  dest="$OUT/STU3/Auth/GUPZ/Test/DVA" ;;
    TestScript-resources-*) dest="$OUT/STU3/PDFA-3-0/GUPZ/Test/_LoadResources" ;;
    *)
      echo "ERROR: no destination known for $name" >&2
      echo "Add a branch to the case statement in build.sh." >&2
      exit 1
      ;;
  esac
  cp "$f" "$dest/"
  count=$((count + 1))
done

echo "  $count TestScript(s)"
echo "Done."

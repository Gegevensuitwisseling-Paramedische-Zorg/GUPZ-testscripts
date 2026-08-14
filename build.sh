#!/bin/bash
#
# Builds the TestScripts from input/fsh and installs them into output/, where
# Conformancelab reads them.
#
# Not part of this build: _reference/ (fixtures and Groovy rules) and the
# properties.json files. Those are maintained by hand in output/, the same way
# Interoplab does it in ntv-testscripts. Reason: the fixtures add up to more
# than 12 MB and would otherwise be stored in the repository twice.

set -e

SRC="./fsh-generated/resources"
BASE="./output/STU3/PDFA-3-0/GUPZ/Test"
AUTH="./output/STU3/Auth/GUPZ/Test/Dataplatform"

echo "=== 1/3 SUSHI"
sushi build .

echo "=== 2/3 Removing previously generated TestScripts"
# Only files produced by this build; the Nictiz scripts that have not been
# converted yet are named medmij-pdfa-*.xml and are left alone.
find "$BASE" "$AUTH" -type f -name "TestScript-*.json" -delete

echo "=== 3/3 Installing new TestScripts"
shopt -s nullglob
count=0
for f in "$SRC"/TestScript-*.json; do
  name=$(basename "$f")
  case "$name" in
    TestScript-xis-*) dest="$BASE/Dataplatform" ;;
    TestScript-phr-*) dest="$BASE/DVA-Client" ;;
    TestScript-auth-*) dest="$AUTH" ;;
    *)
      echo "ERROR: no destination known for $name" >&2
      echo "Add a branch to the case statement in build.sh." >&2
      exit 1
      ;;
  esac
  cp "$f" "$dest/"
  echo "  $name -> ${dest#./output/}"
  count=$((count + 1))
done

echo "Done, installed $count TestScript(s)."

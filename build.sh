#!/bin/bash
#
# Bouwt de TestScripts uit input/fsh en plaatst ze in output/, waar
# Conformancelab ze leest.
#
# Niet in deze build: _reference/ (fixtures en Groovy-rules) en de
# properties.json bestanden. Die worden met de hand in output/ onderhouden,
# net als in de ntv-testscripts van Interoplab. Reden: de fixtures zijn samen
# ruim 12 MB en zouden anders twee keer in de repository staan.

set -e

SRC="./fsh-generated/resources"
BASE="./output/STU3/PDFA-3-0/GUPZ/Test"

echo "=== 1/3 SUSHI"
sushi build .

echo "=== 2/3 Eerder gegenereerde TestScripts opruimen"
# Alleen bestanden die deze build zelf maakt; de nog niet omgezette
# Nictiz-scripts heten medmij-pdfa-*.xml en blijven staan.
find "$BASE" -type f -name "TestScript-*.json" -delete

echo "=== 3/3 Nieuwe TestScripts plaatsen"
shopt -s nullglob
count=0
for f in "$SRC"/TestScript-*.json; do
  name=$(basename "$f")
  case "$name" in
    TestScript-xis-*) dest="$BASE/Dataplatform" ;;
    TestScript-phr-*) dest="$BASE/DVA-Client" ;;
    *)
      echo "FOUT: geen bestemming bekend voor $name" >&2
      echo "Voeg een regel toe aan de case in build.sh." >&2
      exit 1
      ;;
  esac
  cp "$f" "$dest/"
  echo "  $name -> ${dest#./output/}"
  count=$((count + 1))
done

echo "Klaar, $count TestScript(s) geplaatst."

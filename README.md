# GUPZ-testscripts

FHIR TestScripts voor het testen van het GUPZ dataplatform op
[Conformancelab](https://fhir.interoplab.eu/ig/), de TestScript-engine van
Interoplab. Eerste doel is de connectathon van 22 september 2026.

## Authoring in FSH

De TestScripts worden geschreven in [FHIR Shorthand](https://fshschool.org) en
met SUSHI gebouwd. `input/fsh` is de bron, `output/` is gegenereerd en is wat
Conformancelab leest.

```
sushi-config.yaml    SUSHI-configuratie, FHIR R5, FSHOnly
build.sh             sushi build en de resultaten naar output/
input/fsh/
  aliases.fsh
  components/        herbruikbare RuleSets
  Dataplatform/      per scenario één bestand, dat de JSON- en XML-variant maakt
scripts/             hulpmiddelen, zie hieronder
```

Bouwen met `./build.sh`. Dat draait SUSHI, ruimt eerder gegenereerde
`TestScript-*.json` op en plaatst de nieuwe in de juiste Test Set op basis van
het id van de Instance.

De TestScript-resources zijn **R5**, ook al testen ze STU3-materiaal. Dat is
losgekoppeld: Conformancelab ondersteunt officieel alleen TestScript R5. De
FHIR-versie van het materiaal onder test staat in `properties.json`.

Niet in de build: `_reference/` (fixtures en Groovy-rules) en de
`properties.json` bestanden. Die worden met de hand in `output/` onderhouden,
zoals ook in de ntv-testscripts van Interoplab gebeurt. De fixtures zijn samen
ruim 12 MB en zouden anders twee keer in de repository staan.

### Omzetting van de Nictiz-scripts

De omzetting van de overgenomen XML naar FSH gebeurt per scenario. Als steiger
is [GoFSH](https://fshschool.org/docs/gofsh/) bruikbaar:

```
gofsh <map-met-xml> -t xml-only -u 5.0.0 --indent -o <uitvoermap>
```

GoFSH is daarbij een hulpmiddel en geen vertaalmachine: het laat op deze
bestanden aantoonbaar twee dingen vallen. `stopTestOnFail` verdwijnt volledig,
ook waar de waarde `false` is (dat valt op, want in R5 is het element 1..1 en
weigert SUSHI de build), en bij een `profile` met een element-id blijft alleen
het id over en verdwijnt de canonical (dat valt niet op). Controleer daarom elk
omgezet script tegen het origineel:

```
python3 scripts/compare-testscript.py <origineel.xml> fsh-generated/resources/TestScript-<id>.json
```

Dat script slaat beide kanten plat tot pad en waarde en negeert het verschil
tussen enkelvoud en array, zodat alleen echte inhoudelijke verschillen
overblijven.

## Indeling

Conformancelab zoekt in de repository naar mappen met een `properties.json`.
Zo'n map is een Test Set: een groep TestScripts voor een rol binnen een
informatiestandaard. De mapnaam boven de Test Set is vrij; de inhoud van
`properties.json` bepaalt wat er in de gebruikersinterface verschijnt.

```
output/STU3/PDFA-3-0/GUPZ/Test/
  Dataplatform/      server-aimed: het dataplatform is het systeem onder test
  DVA-Client/        client-aimed: de aanroepende partij is het systeem onder test
  _reference/        fixtures (resources) en Groovy-rules
  _LoadResources/    provisioningscript om de fixtures klaar te zetten
```

TestScripts verwijzen naar `../_reference/...`, dus een Test Set-map moet één
niveau onder `_reference` blijven staan.

Alleen de default branch (`main`) is voor gewone gebruikers zichtbaar in
Conformancelab; andere branches zijn alleen voor beheerders. Om deze repository
aan een Conformancelab-instantie toe te voegen loopt het verzoek via Interoplab.

## Herkomst

De PDF/A scripts zijn overgenomen uit de kwalificatiematerialen van Nictiz en
daarna aangepast voor GUPZ. Zie [UPSTREAM.md](UPSTREAM.md) voor de exacte bron,
de commit waarvan is overgenomen, de licentiesituatie en de manier waarop
wijzigingen van Nictiz zijn over te nemen of aan Nictiz zijn terug te leveren.

## Over deze documentatie

De documentatie in deze repository wordt met behulp van AI geschreven. Elke
tekst wordt voor het samenvoegen door een mens gelezen en waar nodig
gecorrigeerd; de inhoudelijke verantwoordelijkheid ligt bij de auteurs. Kom je
toch een fout tegen, meld die dan als issue.

## Werkwijze

Wijzigingen via een branch en een pull request, niet rechtstreeks op `main`.
Branchnaam: issuenummer plus korte beschrijving in kebab-case, of `noref-` als
er geen issue is.

De licentie van deze repository (CC0 1.0) geldt voor het eigen werk van GUPZ,
niet voor de overgenomen Nictiz-bestanden.

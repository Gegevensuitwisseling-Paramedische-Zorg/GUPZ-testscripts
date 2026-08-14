# GUPZ-testscripts

FHIR TestScripts voor het testen van het GUPZ dataplatform op
[Conformancelab](https://fhir.interoplab.eu/ig/), de TestScript-engine van
Interoplab. Eerste doel is de connectathon van 22 september 2026.

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

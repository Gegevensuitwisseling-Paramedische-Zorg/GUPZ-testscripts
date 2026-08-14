# Herkomst van de overgenomen TestScripts

De PDF/A TestScripts in deze repository zijn overgenomen uit de
kwalificatiematerialen van Nictiz. Dit bestand legt vast wat er precies is
overgenomen, zodat onze wijzigingen altijd te scheiden zijn van het origineel en
we later kunnen bijwerken of terugleveren.

## Wat is overgenomen

| Kenmerk | Waarde |
|---|---|
| Bron | <https://github.com/Nictiz/Nictiz-testscripts> |
| Pad | `output/STU3/PDFA-3-0/MedMij/Cert` |
| Commit | `0b6d8975441ab2a429dc907b55ae6adfb04f0d37` (`main`, 21 juli 2026) |
| Release | patchrelease 2026.30 |
| Overgenomen op | 14 augustus 2026 |
| Omvang | 64 bestanden, ongeveer 13 MB |

Overgenomen submappen:

- `XIS-Server-NoManifest` - server-aimed scripts voor servers zonder
  DocumentManifest-ondersteuning; dit is de variant die voor GUPZ van toepassing
  is (zie open-GUPZ issue #61)
- `PHR-Client` - client-aimed scripts
- `_reference` - fixtures (Binary, Bundle, DocumentReference, DocumentManifest,
  Patient) en de Groovy-rule `assert_response_queryParamsInSelfLink.groovy`
- `_LoadResources` - provisioningscript om de fixtures op een server te zetten

Bewust niet overgenomen: de map `Test` (een exact duplicaat van `Cert`) en de
varianten `XIS-Server` en `XIS-Server-Nictiz-intern`. Die zijn alsnog op te
halen via de remote hieronder.

## Licentie

Nictiz-testscripts heeft geen licentiebestand. De repository is openbaar en
forken staat aan, maar formeel zijn alle rechten voorbehouden. De CC0-licentie
van deze repository geldt daarom **niet** voor de bestanden onder
`output/STU3/PDFA-3-0/MedMij/`, alleen voor het eigen werk van GUPZ. Afstemming
met Nictiz over hergebruik en over het terugleveren van wijzigingen loopt via
het GUPZ programma.

## Werkwijze: onze wijzigingen apart houden

De eerste commit met deze bestanden is een ongewijzigde kopie. Daardoor levert

```
git diff <sha-van-die-commit> HEAD -- output/STU3/PDFA-3-0/
```

altijd precies de GUPZ-wijzigingen op, en dat is meteen de patch die aan Nictiz
kan worden aangeboden. Houd die eigenschap in stand: geen opschoonacties in de
vendor-commit achteraf.

## Bijwerken vanaf Nictiz

De bron staat als read-only remote geconfigureerd:

```
git remote add nictiz https://github.com/Nictiz/Nictiz-testscripts.git   # eenmalig
git fetch nictiz main
git diff <onze-vendor-sha> nictiz/main -- output/STU3/PDFA-3-0/MedMij/Cert
```

Let op: de map `output/` bij Nictiz is **gegenereerd** uit `src/PDFA-3-0/`, waar
de scripts DRY zijn opgeschreven met `nts:include`-macro's en waar met
`nts:in-targets` de varianten (`#default`, `NoManifest`, `Nictiz-intern`) uit
een bronbestand worden afgeleid. Nictiz herschrijft de hele output bij elke
patchrelease. Twee gevolgen:

1. Een update overnemen is een gerichte vergelijking, geen merge.
2. Wijzigingen die we structureel willen terugleveren aan Nictiz horen in hun
   `src/`, niet in hun `output/`.

# Milestone 3 – Emergency Types og offline templates

## Status

Milestone 3 er implementert, bygget og testet. Milestone 4 er ikke startet.

## Filer lagt til

- `Disaster Ready/Data/EmergencyTemplateCatalog.swift`
- `Disaster Ready/Resources/EmergencyLocalizationResources.swift`
- `MILESTONE_3_REPORT.md`

## Filer endret

- `Disaster Ready/Models/EmergencyPlanningModels.swift`
- `Disaster Ready/Data/NorwayEmergencyTemplates.swift`
- `Disaster Ready/Views/EventAwarePlanSections.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

Ingen eksisterende SwiftData-modeller eller persistente egenskaper er fjernet, omdøpt eller endret destruktivt.

## EmergencyType-identifikatorer

Følgende stabile identifikatorer brukes:

- `powerOutage`
- `flood`
- `extremeWeather`
- `landslide`
- `wildfire`
- `houseFire`
- `waterOutage`
- `evacuation`
- `hazardousRelease`
- `warOrSecurityIncident`

Testene låser både rekkefølgen, stavemåten og unikheten til identifikatorene.

## Mapping fra PreparednessScenario

| Eksisterende identifikator | EmergencyType | Kompatibilitetsregel |
|---|---|---|
| `brownout` | `powerOutage` | Direkte funksjonell erstatning |
| `flood` | `flood` | Identifikatoren beholdes |
| `storm` | `extremeWeather` | Utvidet hendelseskategori |
| `landslide` | `landslide` | Identifikatoren beholdes |
| `invasion` | `warOrSecurityIncident` | Bredere sikkerhetskategori |
| `earthquake` | `evacuation` | Eksplisitt kompatibilitetstilfelle; gammel råverdi beholdes |
| `volcano` | `evacuation` | Eksplisitt kompatibilitetstilfelle; gammel råverdi beholdes |

Mappingen er kun en oppslagstabell. Eksisterende `scenarioIdentifier` blir ikke omskrevet.

## Template-arkitektur

`EmergencyPlanTemplate` inneholder:

- stabil template-ID
- `EmergencyType`
- lokalisert tittel- og sammendragsnøkkel
- strukturerte `PreparednessAction`-elementer
- strukturerte `ShelterGuidance`-elementer
- prioriteringer for hjemmeberedskap
- prioriteringer for evakuering/grab-liste
- stabile `sourceIDs`

Alt template-innhold er innebygd i appen og fungerer uten nettverk. Kildene refereres med ID; metadata og nettjenester dupliseres ikke i templatene.

`EmergencyTemplateProviding` og `EmergencyTemplateCatalog` skiller landtilpasningen fra `EmergencyType`. Nye land kan derfor få egne providers uten å endre hendelsestypene.

## Norge

`NorwayEmergencyTemplates` leverer ett sporbart template for hver støttet hendelsestype.

Stedsveiledningen følger disse reglene:

- Flom, skred og skogbrann foreslår en type sted utenfor risiko-/hendelsesområdet og viser til myndighetenes instrukser.
- Boligbrann foreslår et forhåndsavtalt utendørs møtested på trygg avstand.
- Evakuering skiller familie, venner eller sekundærbolig fra et offisielt evakueringssenter.
- Krig/sikkerhet sier at gjeldende myndighetsinstrukser avgjør om brukeren skal søke dekning, evakuere eller bruke tilfluktsrom.
- Alle template-genererte steder har `isOfficialLocation == false` og den obligatoriske sikkerhetsmerknaden.

## Gass

For norske husholdninger blir gassrelatert template-innhold bare lagt til når `HouseholdProfile.hasGasInstallation == true`.

- Ingen gassveiledning gis for standardprofilen.
- `gasShutoffNote` brukes ikke til å utlede gassinstallasjon.
- Eksisterende `gasShutoffNote` beholdes uendret.
- Gassrådet gjelder planlegging og henviser til nødetater eller kvalifisert fagperson; det instruerer ikke brukeren om å manipulere installasjonen under en hendelse.

## Lokalisering

57 nye semantiske String Catalog-nøkler er lagt til for:

- hendelsestitler og sammendrag
- forberedelseshandlinger
- myndighetsinstrukser
- gassforberedelser
- steds- og sikkerhetsveiledning

Alle nye nøkler har engelsk kildetekst og oversettelser til norsk bokmål og thai.

Verifisert katalogstatus:

- Norsk bokmål: 0 manglende, 0 trenger gjennomgang
- Thai: 0 manglende, 0 trenger gjennomgang

Sikkerhetsveiledningen leses nå fra lokaliseringsressurser i stedet for hardkodet Swift-tekst.

## Migrering og datakompatibilitet

- SwiftData-skjemaet og modellcontaineren er uendret.
- Alle eksisterende `HouseholdPlan`-felter beholdes uendret.
- Mapping leser gammel identifikator uten å skrive en ny råverdi tilbake.
- Utypede eldre planer får ikke lenger identifikatoren endret automatisk.
- Nye manglende hendelsesplaner opprettes tomme; brukerens eksisterende plan brukes ikke som template og kopieres ikke inn i andre hendelser.
- Offline templates er separate verdityper og skriver aldri over brukerredigerte planer.
- Eksisterende kontakter, forsyninger, medisinske opplysninger, kjæledyropplysninger og familiemeldinger berøres ikke.
- Backup schema version 1 og Milestone 2-profilpersistens er fortsatt kompatible og dekket av regresjonstester.

## Advarsler

De tidligere Swift-isolasjonsadvarslene er rettet konservativt:

- `NorwayEmergencyTemplates.swift`: funksjonsreferansen i `map` er erstattet med en eksplisitt closure.
- `EmergencyPlanningModels.swift`: funksjonsreferansen i `compactMap` er erstattet med en eksplisitt closure.

Sluttbygget rapporterer 0 advarsler.

## Bygg og tester

Build for testing:

```text
Build succeeded
0 errors
0 warnings
```

Målrettede enhetstester for Milestone 1–3-kompatibilitet og Milestone 3-sikkerhet:

```text
19 tests
19 passed
0 failed
0 skipped
```

Testene dekker:

1. Komplett og eksplisitt PreparednessScenario-mapping.
2. Bevaring av alle brukerfelter under mapping.
3. Ingen overskriving fra templates.
4. Stabile og unike EmergencyType-identifikatorer.
5. Offline og landsspesifikk Norge-provider.
6. Korrekt template for alle hendelsestyper.
7. Ingen norsk gassveiledning uten eksplisitt gassvalg.
8. Relevant gassveiledning når gass er aktivert.
9. Ingen template-generert offisiell sikker adresse.
10. Lesing av 1.0.1-formede backups og full feltbevaring.
11. Fortsatt persistens og sikker dekoding av HouseholdProfile.
12. Codable round-trip av templates og source-ID-er.

## Gjenværende risiko og senere TODO

- Kun Norge har en landsspesifikk template-provider. Andre land returnerer foreløpig ingen landstilpasset provider.
- `sourceIDs` er forberedt for kilderegisteret i en senere milepæl; ingen live nettverkstjeneste er innført i Milestone 3.
- `earthquake` og `volcano` er dokumenterte kompatibilitetstilfeller under den bredere `evacuation`-typen. De opprinnelige råverdiene og planinnholdet beholdes.
- Event-aware My Plan-flyten hører til Milestone 4 og er ikke videreutviklet her.

Milestone 3 stopper her og avventer gjennomgang.

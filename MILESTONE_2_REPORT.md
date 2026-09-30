# Milestone 2 – Implementeringsrapport

## Status

Milestone 2 – Household Profile er implementert og testet. Milestone 3 er ikke startet.

## Implementert funksjonalitet

Household Profile støtter:

- Land, med standardverdi fra enhetens region
- Manuell endring av land
- Valgfri kommune
- Husstandsstørrelse
- Barn
- Kjæledyr
- Elektrisk oppvarming
- Vedovn
- Gassinstallasjon
- Alternativ oppvarming
- Bil
- Elbil
- Behov for særskilt hjelp
- Kjennskap til hovedstoppekran
- Kjennskap til hovedsikringsskap

Profilredigering er tilgjengelig fra Settings. Det samles ikke inn adresse eller andre unødvendige personopplysninger.

Engelsk, norsk bokmål og thai er støttet.

## Persistens og migrering

Household Profile er implementert additivt og lagres separat i UserDefaults med nøkkelen `householdProfile.v1`.

Ved første opprettelse:

- `householdSize` hentes fra eksisterende `householdMemberCount`.
- Nye boolske verdier får konservativ standardverdi `false`.
- `hasGasInstallation` settes til `false`.
- Eksisterende profil overskrives ikke.
- Endret husstandsstørrelse synkroniseres tilbake til den eksisterende `householdMemberCount`-nøkkelen.

Ingen eksisterende SwiftData-modeller eller lagrede egenskaper er fjernet, omdøpt eller destruktivt endret.

## Gassdata

Eksisterende `HouseholdPlan.gasShutoffNote` beholdes uendret.

Denne teksten brukes ikke til å anta at husstanden har gass. For Norge vises gasspesifikk veiledning bare når brukeren uttrykkelig har aktivert `hasGasInstallation == true`.

## Backup-kompatibilitet

Backup-støtten er utvidet med en valgfri `householdProfile`.

- Backup schema version er fortsatt `1`.
- Gamle backups uten Household Profile kan fortsatt importeres.
- Manglende profil i en gammel backup tolkes ikke som en feil.
- Eksisterende `householdMemberCount` brukes som fallback.
- Eksisterende `gasShutoffNote` og øvrige 1.0.1-data bevares.

## Filer

Lagt til som del av Milestone 2:

- `Disaster Ready/Models/HouseholdProfile.swift`
- `Disaster Ready/Data/HouseholdProfileStore.swift`
- `Disaster Ready/Views/HouseholdProfileEditor.swift`

Endret:

- `Disaster Ready/BackupSupport.swift`
- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Views/DashboardSections.swift`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

Den eksisterende SwiftData-modellcontaineren er ikke endret.

## Testresultater

Bygging med testmål:

```text
Build succeeded
```

Målrettede enhetstester:

```text
8 tester kjørt
8 bestått
0 feilet
0 hoppet over
```

Testene verifiserte:

- Migrering fra `householdMemberCount`
- Standardverdi `hasGasInstallation == false`
- Norsk husstand uten gass
- Husstand med gass aktivert
- Persistens av profilendringer
- Sikre standardverdier ved dekoding
- Backup round-trip med Household Profile
- Import og bevaring av eksisterende 1.0.1-data

## Advarsler

Ingen bygge- eller testfeil ble funnet.

Bygget rapporterte to eksisterende Swift-isolasjonsadvarsler utenfor Milestone 2:

- `NorwayEmergencyTemplates.swift:5`
- `EmergencyPlanningModels.swift:42`

Milestone 2 er ferdig og avventer gjennomgang. Milestone 3 er ikke startet.

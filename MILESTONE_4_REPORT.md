# Milestone 4 – Event-aware My Plan

## Status

Milestone 4 er implementert, bygget, testet og manuelt kontrollert i simulator. Milestone 5 er ikke startet.

## Filer lagt til

- `Disaster Ready/Data/MyPlanCompatibility.swift`
- `Disaster Ready/Views/EventAwareMyPlanView.swift`
- `Disaster Ready/Resources/MyPlanLocalizationResources.swift`
- `MILESTONE_4_REPORT.md`

## Filer endret

- `Disaster Ready/DisasterDashboardView.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

Ingen eksisterende SwiftData-modeller, lagrede egenskaper eller backupfelt er fjernet, omdøpt eller endret destruktivt.

## UI-struktur

Planfanen bruker en guidet, rullbar flyt:

1. Velg hendelse.
2. Se hva husstanden kan gjøre nå, hva som gjelder under en faktisk hendelse, og hva som krever oppdatert myndighetsinformasjon.
3. Se offline veiledning om type oppholdssted med obligatorisk sikkerhetsmerknad.
4. Rediger personlige møte- og oppholdssteder.
5. Se en skrivebeskyttet forhåndsvisning av template-prioriterte hjemme- og evakueringsforsyninger.
6. Se og åpne eksisterende kontakter.
7. Lagre eller oppdatere planen eksplisitt på enheten.

Kortene bruker nummererte overskrifter, systemikoner, Dynamic Type-stiler og standard SwiftUI-kontroller. Flyten ligger i den eksisterende `ScrollView`-baserte planfanen.

Representative simulatorbilder:

- Flom uten gass: `Verify Milestone 4 My Plan-18_39_02_697-screenshot.png`
- Husbrann med gass: `Verify Milestone 4 My Plan-18_43_16_084-screenshot.png`
- Evakueringsfelter: `Verify Milestone 4 My Plan-18_44_12_337-screenshot.png`
- Krig/sikkerhet: `Verify Milestone 4 My Plan-18_47_22_812-screenshot.png`
- Lagringsbekreftelse: `Verify Milestone 4 My Plan-18_38_44_403-screenshot.png`

Bildene ligger i Xcodes `ActionArtifacts/DeviceInteractionSynthesize`-område for denne kjøringen.

## Mapping av gamle HouseholdPlan-felt

`MyPlanLocationDraft` gir et additivt kompatibilitetslag uten å endre SwiftData-skjemaet.

| Eksisterende felt | My Plan-betydning | Bevaring |
|---|---|---|
| `reunionPoint` | Household meeting point | Direkte toveis binding |
| `evacuationDestination` | Existing evacuation destination | Direkte toveis binding; aldri skjult eller slettet |
| `shelterZone` | Existing shelter or safe-place note | Direkte toveis binding; aldri presentert som offisiell |
| `alternativeAccommodation` | Alternative accommodation | Additivt valgfritt felt |
| `familyFriendLocation` | Family/friend location | Additivt valgfritt felt |
| `secondaryHome` | Cabin/secondary home | Additivt valgfritt felt |
| `safePlaceNote` | Personal safe-place note | Additivt valgfritt felt |

Å åpne og lagre planen uten redigering gir identiske verdier. `gasShutoffNote`, medisinsk informasjon, kjæledyrinformasjon, familiemelding, vannstoppekran, sikringsskap og `scenarioIdentifier` berøres ikke av kompatibilitetslaget.

## Personlig, forberedelse og offisiell informasjon

UI-en forklarer tre separate kategorier før planstegene:

- **Personal planning location:** brukerens eget notat; ikke verifisert eller offisielt godkjent.
- **Preparedness guidance:** statisk offline veiledning for planlegging før en hendelse.
- **Official current information:** oppdatert informasjon som må hentes fra nødetater eller myndigheter; planen vises uttrykkelig ikke som et live-varsel.

Alle template-steder beholder `isOfficialLocation == false` og den obligatoriske sikkerhetsmerknaden. Evakueringsfeltene for familie, venner og hytte er visuelt og semantisk adskilt fra et offisielt evakueringssenter. Krig/sikkerhet sier at gjeldende myndighetsinstrukser avgjør om brukeren skal søke dekning, evakuere eller bruke tilfluktsrom.

## HouseholdProfile-integrasjon

- Landkoden velger provider gjennom `EmergencyTemplateCatalog`.
- Norge bruker `NorwayEmergencyTemplateProvider`.
- Husstandsprofilen sendes til provideren for hver valgt hendelse.
- Gassveiledning vises bare når `hasGasInstallation == true`.
- `gasShutoffNote` brukes aldri til å utlede om husstanden har gass.
- Eksisterende profilpersistens og konservative standardverdier er regresjonstestet.

## Kontakter og forsyninger

- My Plan viser eksisterende `FamilyContact`- og `ImportantNumber`-poster direkte og åpner den eksisterende kontaktfanen for redigering.
- Ingen kontakter kopieres, migreres eller slettes.
- Forsyningsvisningen er skrivebeskyttet og bruker `EmergencyPlanTemplate.supplyPriorities` og `evacuationItems`.
- Eksisterende `SupplyItem`-poster endres ikke. Full smart forsyningsfunksjon er fortsatt avgrenset til Milestone 5.

## Offline-adferd

Hendelsesvalg, actions, shelter guidance, stedsredigering, forsyningsforhåndsvisning, kontakter og lagring bruker bare lokale templates, SwiftData og UserDefaults. My Plan starter ingen nettverksforespørsler.

Simulatorverktøyet kunne ikke slå flymodus fysisk av/på. Flyten ble likevel kjørt uten nettverksavhengig kode, og både template-visning og lokal lagring fungerte. En faktisk flymodustest gjenstår som manuell enhetssjekk før release.

## Lokalisering

38 nye semantiske My Plan-nøkler er lagt til i String Catalog for:

- informasjonskategorier og sikkerhetsforklaringer
- alle guidede steg
- personlige stedsfelt
- kontakt- og forsyningsforhåndsvisning
- lokal lagring og feilstatus

Status etter kontroll:

- Engelsk kildetekst: komplett
- Norsk bokmål: 0 manglende, 0 trenger gjennomgang
- Thai: 0 manglende, 0 trenger gjennomgang

Ingen ny sikkerhetskritisk tekst er hardkodet i My Plan-visningen.

## Tilgjengelighet

### VoiceOver: PASS

- Standard `Picker`, `TextField` og `Button` gir korrekte roller.
- Overskrifter bruker `.accessibilityHeading(.h2)`.
- Relaterte forklaringer kombineres i logiske VoiceOver-elementer.
- SF Symbols ligger i tekstmerkede `Label`-kontroller.
- Viktige kontroller har unike identifikatorer: `emergencyTypePicker`, `householdMeetingPointField`, `evacuationDestinationField`, `shelterZoneField`, `personalSafePlaceNoteField`, `openMyPlanContactsButton` og `saveMyPlanButton`.
- En arvet duplikatidentifikator oppdaget under simulatorprøven ble fjernet og kontrollert på nytt.

### Dynamic Type: PASS

- All tekst bruker skalerende systemstiler som `.body`, `.headline`, `.subheadline`, `.footnote` og `.title3`.
- Ingen faste tekststørrelser eller faste høyder brukes.
- Vertikale kort og rullbar skjerm lar tekst brytes og vokse.

## Bygg og automatiske tester

```text
Build for testing: succeeded
Errors: 0
Warnings: 0
```

Målrettede Milestone 1–4-tester:

```text
23 tests
23 passed
0 failed
0 skipped
```

Testene dekker blant annet alle EmergencyType-valg, offline provider, gassfiltrering, legacy mapping, uendret lagring, personlige/ikke-offisielle steder, kontakter, HouseholdProfile og 1.0.1-backupkompatibilitet.

## Manuelle simulatorresultater

| Scenario | Resultat | Merknad |
|---|---|---|
| A. Norge uten gass → Flood | PASS | Riktig template, risikoområde- og myndighetsbudskap, ingen gassveiledning |
| B. Norge uten gass → Power outage | PASS | Riktig offline template lastet |
| C. Norge med gass → House fire | PASS | Gassveiledning kom først etter eksplisitt aktivering |
| D. House fire → meeting point | PASS | Utendørs møtepunkt på trygg avstand og redigerbart husholdningsfelt |
| E. Evacuation → familie/venn/hytte | PASS | Alle personlige alternativer og gamle felt synlige |
| F. War/security → authority first | PASS | Ingen instruks om å reise til tilfluktsrom; myndighetene avgjør |
| G. Airplane mode | DELVIS | Ingen nettverkskode brukt og lokal lagring besto; verktøyet kunne ikke aktivere fysisk flymodus |
| H. Oppgradert 1.0.1-plan | IKKE MANUELT VERIFISERT | Simulatorfixture manglet eksisterende stedsverdier; automatisk round-trip- og backupregresjon besto |
| Kontakter | PASS | Eksisterende kontakter åpnet uten kopier |
| Forsyningspreview | PASS | Begge template-lister vist uten endring av lagrede forsyninger |
| Save/update | PASS | Synlig lokal lagringsbekreftelse |

Ingen krasj, overlapping eller tydelig tekstklipping ble observert.

## Gjenværende risiko og TODO

- Gjenta scenario G på fysisk enhet med flymodus aktivert.
- Gjenta scenario H med en faktisk oppgradert App Store 1.0.1-database før TestFlight.
- Andre land enn Norge mangler fortsatt egne template-providers og får en tydelig melding om manglende landstilpasset offline veiledning.
- Full smart forsyningslogikk skal først implementeres i Milestone 5.
- My Plan viser eksisterende roller, meldingsmaler og øvelser under den nye guidede flyten for bakoverkompatibilitet; eventuell ytterligere informasjonsarkitektur bør vurderes uten å slette funksjonene.

Milestone 4 stopper her og avventer gjennomgang.

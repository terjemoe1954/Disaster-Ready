# Milestone 7 Report — Official Source Architecture

Date: 2026-10-01

## Result

Milestone 7 adds a centralized, bundled source registry and reusable source-attribution UI. No live alert, shelter lookup, NVE integration, web-page cache, or other network service was added. The feature performs no network request when resolving metadata.

## Files added

- `Disaster Ready/Resources/SourceLocalizationResources.swift`

## Files modified

- `Disaster Ready/Data/GuidanceSourceRegistry.swift`
- `Disaster Ready/Localizable.xcstrings`
- `Disaster Ready/Views/EventAwareMyPlanView.swift`
- `Disaster Ready/Views/OfficialSourcesSection.swift`
- `Disaster Ready/Views/PaymentPreparednessSection.swift`
- `Disaster ReadyTests/Disaster_ReadyTests.swift`

`Models/GuidanceSource.swift` already contained the required additive `Codable`, `Identifiable`, `Equatable`, and `Sendable` value type, so no persistence model change was needed.

## GuidanceSource architecture

`GuidanceSourceRegistry` is the single owner of source authority, official title, HTTPS URL, country code, and review date. Templates and features continue to carry only stable source IDs. Resolution is deterministic and entirely in memory from bundled data.

The registry also contains explicit compatibility aliases. This allows previously shipped source IDs to resolve without modifying the approved Milestone 3 template IDs. `resolvedSources(for:)` filters unknown IDs and de-duplicates aliases, preventing broken source buttons.

Source metadata is deliberately not stored in SwiftData and is not added to backup data.

## Registered source-ID table

| Source ID | Authority | Official title | URL | Country | Reviewed |
|---|---|---|---|---|---|
| `dsb-self-preparedness` | Direktoratet for samfunnssikkerhet og beredskap (DSB) | Egenberedskap | https://www.dsb.no/sikkerhverdag/egenberedskap/ | NO | 2026-10-01 |
| `dsb-flood-preparedness` | Direktoratet for samfunnssikkerhet og beredskap (DSB) | Slik forbereder du deg på flom | https://www.dsb.no/sikkerhverdag/produkter-utstyr-og-fritid/slik-forbereder-du-deg-pa-flom/ | NO | 2026-10-01 |
| `dsb-crisis-locations` | Direktoratet for samfunnssikkerhet og beredskap (DSB) | Oppholdssteder i kriser | https://www.dsb.no/sikkerhverdag/egenberedskap/oppholdssteder-i-kriser/ | NO | 2026-10-01 |
| `dsb-civil-defence-shelters` | Direktoratet for samfunnssikkerhet og beredskap (DSB) | Verdt å vite om tilfluktsrom | https://www.dsb.no/sikkerhverdag/egenberedskap/verdt-a-vite-om-tilfluktsrom/ | NO | 2026-10-01 |
| `met-weather-warnings` | Meteorologisk institutt (MET) | Ekstremværvarsler og andre farevarsler | https://www.met.no/vaer-og-klima/ekstremvaervarsler-og-andre-farevarsler | NO | 2026-10-01 |
| `nve-hazard-information` | Norges vassdrags- og energidirektorat (NVE) | Naturfare | https://www.nve.no/naturfare/ | NO | 2026-10-01 |
| `no.payment-preparedness-guidance` | Norges Bank / Direktoratet for samfunnssikkerhet og beredskap (DSB) | Eigenberedskap for betalinger | https://www.dsb.no/sikkerhverdag/egenberedskap/eigenberedskap-for-betalingar/ | NO | 2026-10-01 |

## Compatibility aliases

| Existing ID | Resolves to |
|---|---|
| `dsb-preparedness` | `dsb-self-preparedness` |
| `dsb-evacuation` | `dsb-crisis-locations` |
| `nve-natural-hazards` | `nve-hazard-information` |

## Review-date semantics

`lastReviewed` means the date Disaster Ready checked its bundled guidance against the official page. It is not an authority publication date and is not a live-update timestamp. The source card states this explicitly and tells users to follow current public-authority instructions during an emergency.

## EmergencyTemplate integration

All source IDs currently emitted by `NorwayEmergencyTemplates` resolve through the registry. The template source arrays were not changed. `EventAwareMyPlanView` now resolves and displays the selected template's official sources. Unknown IDs are omitted safely instead of producing a link.

## Payment Preparedness integration

`no.payment-preparedness-guidance` resolves to the verified DSB page publishing Norges Bank's payment-preparedness advice. `PaymentPreparednessSection` displays the same reusable attribution card. Checklist rules and completion persistence were not changed.

## Source UI and accessibility

`SourceAttributionCard` displays:

- official guidance title
- authority
- localized source-review label and date
- an HTTPS link opened with the system `Link`/openURL behavior
- the static-versus-live safety explanation

The link has a localized VoiceOver label, stable accessibility identifier, and a minimum 44-point tap height. Text uses semantic SwiftUI fonts and supports Dynamic Type. `TemplateSourceAttributionSection` renders nothing when no source resolves.

## Offline behavior

Authority, title, review date, and URL are bundled and resolve without network access. The official page itself is not cached; opening the link while offline may fail naturally. The app does not claim the page is available offline.

## Localization

Seven new `source.*` keys were added for English, Norwegian Bokmål, and Thai. Xcode String Catalog verification reported zero new/untranslated keys and zero keys needing review for Bokmål and Thai. Official authority names and official Norwegian page titles remain unchanged.

## Automated tests

Six focused source-architecture tests were added, covering:

- unique stable registered IDs, HTTPS URLs, country codes, review dates, and Codable round-trip
- resolution or explicit pending status for every Norway template source ID
- Payment Preparedness source resolution
- safe failure/no presentation for unknown IDs
- compatibility aliases without changing template source IDs
- bundled/offline metadata and non-live review wording

The project contains 68 enabled unit tests and 8 enabled UI/launch tests (76 total discovered by Xcode). A complete result count could not be produced in this run because `Run All Tests` entered a stuck UI-test run and left Xcode reporting `Tests are already running`. A direct unit-test retry then failed when CoreSimulatorService disconnected (`CoreSimulatorService connection became invalid`, no iPhone 17 Pro destination available). No test assertion failure was reported before the infrastructure failure.

## Build result

- Full Xcode build before localization: succeeded, 0 reported errors.
- Full Xcode build after implementation/localization: succeeded, 0 reported errors.
- File-level diagnostics for all modified/new Swift source files: no issues.

## Manual UI results

Manual simulator verification started successfully before CoreSimulatorService disconnected:

- Norwegian My Plan → Extreme weather displayed two resolved DSB source cards.
- Authority, the titles `Egenberedskap` and `Oppholdssteder i kriser`, and review date `1. okt. 2026` were visible.
- VoiceOver link labels included the authority name.
- The explanatory text explicitly said the date was not a real-time update and directed users to current public-authority instructions.
- No overlap or truncation was visible at 402 × 874 points at the default Dynamic Type size.
- Payment Preparedness itself remained visible and functional.

Opening the links, airplane-mode behavior, explicit unresolved-source UI, the Payment source card, and English/Thai layouts were not completed because of the simulator-service failure. The device verification session was ended cleanly.

## Warnings and errors

- Build warnings from project code: none reported by Xcode build.
- Test infrastructure: stuck Xcode test state (`Tests are already running`).
- Simulator infrastructure: CoreSimulatorService connection invalid; `simdiskimaged` unavailable; direct test command exited 70 because the iPhone 17 Pro simulator destination disappeared.
- The command-line Xcode process also emitted Xcode-internal property-list type-detection warnings. These were toolchain warnings, not app compiler diagnostics.

## Unresolved source IDs

None among the source IDs currently emitted by `NorwayEmergencyTemplates`. `pendingSourceIDs` is intentionally empty. Future unverified IDs fail closed and display no source link.

## Compatibility and data safety

- No SwiftData model or persisted property changed.
- No migration was added or required.
- No `HouseholdPlan`, `HouseholdProfile`, `SupplyItem`, contact, or Payment Preparedness state is read or modified by source resolution.
- Existing template source IDs remain unchanged and are supported through explicit aliases where needed.
- Backup schema and version-1 import behavior are unchanged; source metadata is not exported.

## Remaining risks / TODOs

- Re-run all 68 unit tests after Xcode/Device Hub restores CoreSimulatorService.
- Complete manual checks A–J after the simulator is healthy, especially opening an official link and inspecting English, Bokmål, and Thai layouts.
- Review dates are bundled release metadata and must be deliberately updated only after a future source review.
- Milestone 8 may consume this registry, but must not reinterpret review dates as live-data timestamps.

Milestone 8 has not been started.

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

Final verification on 2026-10-01 ran all 68 enabled unit tests on the manually started iPhone 17 Pro simulator:

- Tests run: 68
- Passed: 68
- Failed: 0
- Skipped: 0
- Expected failures: 0
- Not run: 0

The source-registry tests confirm that every source ID currently emitted by `NorwayEmergencyTemplates` resolves or is explicitly pending. All current IDs resolve; `pendingSourceIDs` remains empty. Compatibility, migration, backup, HouseholdProfile, Payment Preparedness, Smart Supply, and legacy-data tests also passed in the same run.

## Build result

- Final complete Xcode build: succeeded.
- App compiler errors: 0.
- App compiler warnings: 0.
- Xcode warning-level build-log entries: 0.
- File-level diagnostics for all modified/new Swift source files: no issues.

## Manual UI results

Final simulator verification completed on the latest build without resetting, stopping, or rebooting the simulator:

| Check | Result | Evidence |
|---|---|---|
| A. Open resolved DSB link | Pass | `Egenberedskap` opened on the official DSB page in Safari; returning preserved app state. |
| B. Payment Preparedness attribution | Pass | Displayed `Eigenberedskap for betalinger`, `Norges Bank / Direktoratet for samfunnssikkerhet og beredskap (DSB)`, review date 1 October 2026, and a working official link. |
| C. Unknown source ID | Pass, code/test-backed | There is no user route for injecting an unknown ID. The passing `unknownSourceIDsFailSafelyWithoutBrokenPresentation` test confirms an unknown ID resolves to `nil`/an empty presentation, and runtime inspection showed no broken source button. |
| D. Offline bundled metadata | Pass, code/test-backed | Metadata appeared immediately with no loading state or metadata network request and remained visible after returning from Safari. Network was not disabled globally because no safe simulator control was available during the session. Registry metadata is bundled and the offline-resolution test passed. |
| E. Review-date meaning | Pass | English UI explicitly states that Disaster Ready reviewed the guidance on the displayed date, that it is not a live-update time, and that current authority instructions take priority. Bokmål and Thai communicate the same distinction. |
| F. English source UI | Pass | All source labels and safety text were translated; no raw `source.*` keys, clipping, or overlap. |
| G. Norwegian Bokmål source UI | Pass | `Kilde`, `Kilden ble gjennomgått:`, `Vis offisielle råd`, and the non-live explanation displayed correctly. |
| H. Thai source UI | Pass | `แหล่งข้อมูล`, `วันที่ตรวจสอบแหล่งข้อมูล:`, `ดูคำแนะนำอย่างเป็นทางการ`, and the non-realtime explanation displayed without source-card layout defects. |
| I. Not a live warning | Pass | Source cards use neutral book/source styling and explanatory attribution wording; they do not resemble live emergency alerts. |

The device-interaction session ended cleanly.

## Warnings and errors

- Final app build: 0 compiler errors and 0 compiler warnings.
- Final unit-test run: 0 failures, 0 skipped tests, and no reported test errors.
- Source UI: no visual or functional defects found in English, Bokmål, or Thai.
- The adjacent English My Plan localization issue was corrected before Milestone 8. Explicit English values were added for the existing Emergency, My Plan, shelter, Smart Supply, and supply keys; no logic or non-English translations changed. Final simulator verification found no raw semantic keys in the six required scenarios.

## Unresolved source IDs

None among the source IDs currently emitted by `NorwayEmergencyTemplates`. `pendingSourceIDs` is intentionally empty. Future unverified IDs fail closed and display no source link.

## Compatibility and data safety

- No SwiftData model or persisted property changed.
- No migration was added or required.
- No `HouseholdPlan`, `HouseholdProfile`, `SupplyItem`, contact, or Payment Preparedness state is read or modified by source resolution.
- Existing template source IDs remain unchanged and are supported through explicit aliases where needed.
- Backup schema and version-1 import behavior are unchanged; source metadata is not exported.

## Remaining risks / TODOs

- Review dates are bundled release metadata and must be deliberately updated only after a future source review.
- Milestone 8 may consume this registry, but must not reinterpret review dates as live-data timestamps.

Milestone 8 has not been started.
